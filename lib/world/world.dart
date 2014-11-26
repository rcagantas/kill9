part of gglworld;

class World {
  Grid grid;
  Map _objects = new Map();
  List _removals = new List();
  Map _listeners = new Map();
  List<Actor> actors = new List();
  Map<int, Frame> _playerFrames = new Map();
  Map<int, AmmoBehavior> _bulletBehaviors = new Map();
  BulletFactory bullets;
  Function onReady;
  static const int MAX_PLAYERS = 10;
  WeaponDrop _weaponDrop;

  int _tileWidth;
  int _worldWidth;
  int _worldHeight;
  Timer _timer = null, _readyTimer = null,
      _weaponDropTimer = null, _lobbyTimer = null;
  Stopwatch watch = new Stopwatch();
  List<RandomWalker> bots = [];

  World.size(num height, num width) {
    List<num> surface = MapGenerator.createSimpleRandomSurface(width, height);
    grid = new Grid.surface(width, height, 100, surface);
    _init();
  }

  World(grid) {
    this.grid = grid;
    _init();
  }

  void _init() {
    _worldWidth = grid.width() * grid.tileWidth();
    _worldHeight = grid.height() * grid.tileWidth();

    _bulletBehaviors[BulletType.BULLET] = new BulletBehavior();
    _bulletBehaviors[BulletType.GRENADE] = new GrenadeBehavior();
    _bulletBehaviors[BulletType.ROCKET] = new RocketBehavior();

    bullets = new BulletFactory(200, _bulletBehaviors);
    _readyTimer = new Timer.periodic(new Duration(milliseconds: 10), (timer) {
      if (actors.length == MAX_PLAYERS) {
        if (onReady != null) onReady();
        _readyTimer.cancel();
      }
    });

    _weaponDrop = new WeaponDrop(this);
  }

  void start() {
    if (_timer == null && actors.length == MAX_PLAYERS) {
      //initializations
      _weaponDropTimer = new Timer.periodic(new Duration(seconds: 5), (timer) {
        _weaponDrop.spawn(this);
      });

      //start game
      _timer = new Timer.periodic(new Duration(milliseconds: 10), this._goRound);
      for (RandomWalker bot in bots) {
        bot.start();
      }
    }
  }

  void stop() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  void addObject(WorldObject object) {
    _objects[object.hashCode] = object;
    object.myWorld = this;
  }

  void addPlayerFrameListener(int playerId, void listener(Frame pf)) {
    if (_objects.containsKey(playerId)) {
      _listeners[playerId] = listener;
    }
  }

  Actor addPlayerandGetReference() {
    if (actors.length >= MAX_PLAYERS)
      return null;

    var newPlayer = new Actor();
    addObject(newPlayer);
    actors.add(newPlayer);
    spawnRandomly(newPlayer);
    print("${actors.length} ${newPlayer.hashCode}");

    // start the lobby timer once you add a real player
    _lobbyTimer = new Timer.periodic(new Duration(seconds: 1), (timer) {
      if (actors.length < MAX_PLAYERS) {
        bots.add(new RandomWalker(addPlayerandGetReference()));
        bots[bots.length - 1].player.name = Bots.names[bots.length - 1];
      } else {
        _lobbyTimer.cancel();
        start();
      }
    });

    return newPlayer;
  }

  int addPlayer() {
    Actor newPlayer = addPlayerandGetReference();
    return newPlayer.hashCode;
  }

  void spawnRandomly(WorldObject object) {
    math.Random rand = new math.Random();
    int loc;
    int count;
    do {
      count = 0;
      loc = rand.nextInt(grid.surfaceList.length);
      for (int y = 0; y < grid.height(); y++) {
        for (int x = 0; x < grid.width(); x++) {
          if (count == loc &&
              grid.surfaceList[loc] == Surface.PASSABLE) {
            object.x = x * grid.tileWidth() + grid.tileWidth()/2;
            object.y = y * grid.tileWidth() + grid.tileWidth()/2;
            return;
          }
          count++;
        }
      }
    } while (grid.surfaceList[loc] != Surface.PASSABLE);
  }

  void removeObject(WorldObject object) {
    _removals.add(object);
    object.myWorld = null;
  }

  Frame getFrameDetail(int playerId) {
    if (!_playerFrames.containsKey(playerId)) {
      _playerFrames[playerId] = new Frame();
    }

    var frame = _playerFrames[playerId];
    Actor player = _objects[playerId];

    frame.playerId = playerId;
    frame.topX = player.x - (WorldConst.VIEWPORT_WIDTH/2);
    frame.topY = player.y - (WorldConst.VIEWPORT_HEIGHT/2);

    frame.visibleObjects.clear();

    _objects.forEach((id,object) {
      WorldObject obj = object;
      if (obj.isInView(frame.topX, frame.topY,
          frame.topX + WorldConst.VIEWPORT_WIDTH,
          frame.topY + WorldConst.VIEWPORT_HEIGHT)) {
        var visiObj;

        if (obj is Actor)
          visiObj = new ActorInFrame();
        else if (obj is Bullet)
          visiObj = new BulletInFrame();
        else if (obj is WeaponDrop)
          visiObj = new WeaponDropInFrame();

        visiObj.x = obj.x;
        visiObj.y = obj.y;
        visiObj.orientation = obj.orientation;
        visiObj.id = obj.hashCode;
        if (obj is Actor) {
          visiObj.lifeRatio = (obj.life * 100)/Actor.MAX_LIFE;
          visiObj.damageFrom = obj.damageFrom;
          visiObj.isFiring = obj.weapon.isFiring;
          visiObj.isMoving = obj.isMoving();
          visiObj.weaponType = obj.weapon.weaponType;
          visiObj.weaponAmmo = obj.weapon.ammo;
          visiObj.name = obj.name;
        } else if (obj is Bullet) {
          visiObj.type = obj.type;
          visiObj.hitActor = obj.hitActor;
          visiObj.hitObject = obj.hitObject;
          visiObj.timedOut = obj.timedOut;
        } else if (obj is WeaponDrop) {
          visiObj.weaponType = obj.weaponType;
        }
        frame.visibleObjects.add(visiObj);
      }
      if (obj is Actor) {
        frame.killStats[obj.hashCode] = obj.killCount;
        frame.deathStats[obj.hashCode] = obj.deathCount;
      }
    });

    return frame;
  }

  void _processInput() {
    // process input
  }

  void _update(num elapsed) {

    // AI stuff

    // physics stuff (collision etc.)
    _objects.forEach((k,v)=>v.doPhysics(elapsed,_objects));
    // individal object updates
    _objects.forEach((k,v)=>v.update(elapsed));

    //generate frame for each player
    _listeners.forEach((playerId,listener){
      var playerFrame = getFrameDetail(playerId);
      listener(playerFrame);
    });

    // objects for removal
    _removals.forEach((obj)=>_objects.remove(obj.hashCode));
    _removals.clear();
  }

  void _goRound(Timer timer) {

    watch.stop();

    num elapsed = watch.elapsedMilliseconds/1000;

    watch.reset();
    watch.start();

    _processInput();
    _update(elapsed);
  }

  void action(Cmd c) {
    if (_timer == null) return;
    for (Actor a in actors) {
      if (a.hashCode == c.id) {
        if (c.moveX == -1) a.moveLeft();
        else if (c.moveX == 1) a.moveRight();
        else if (c.moveX == 0) a.stopLeftRightMove();

        if (c.moveY == -1) a.moveUp();
        else if (c.moveY == 1) a.moveDown();
        else if (c.moveY == 0) a.stopTopDownMove();

        if (c.rotate == -1) a.turnCounterClockwise();
        else if (c.rotate == 1) a.turnClockwise();
        else if (c.rotate == 0) a.stopTurn();

        if (c.fire) a.weapon.fire();
        else if (!c.fire) a.weapon.stop();

        if (c.swap) a.switchWeapon();

        if (c.mouseX != -1 && c.mouseY != -1) {
          a.turnToPoint(c.mouseX + a.x, c.mouseY + a.y);
        }

        if (c.name != a.name) { a.name = c.name; }
      }
    }
  }
}
