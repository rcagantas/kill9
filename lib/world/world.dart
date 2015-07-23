part of gglworld;

class World {
  Grid grid;
  Map _objects = new Map();
  List _removals = new List();
  List<Actor> actors = new List();
  Map<int, Frame> _playerFrames = new Map();
  Map<int, AmmoBehavior> _bulletBehaviors = new Map();
  Map<num, Function> _listeners = new Map<num, Function>();

  BulletFactory bullets;
  Function onReady;
  static const int MAX_PLAYERS = 10;
  WeaponDrop _weaponDrop;

  int _tileWidth;
  Timer _timer = null, _weaponDropTimer = null;
  Stopwatch watch = new Stopwatch();

  num totalTime = 0;
  bool worldEnded = false;
  List<Actor> topScore = new List<Actor>();
  List<String> chatLogs = new List<String>();
  String nextChat = "";

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
    _bulletBehaviors[BulletType.BULLET] = new BulletBehavior();
    _bulletBehaviors[BulletType.GRENADE] = new GrenadeBehavior();
    _bulletBehaviors[BulletType.ROCKET] = new RocketBehavior();
    
    bullets = new BulletFactory(200, _bulletBehaviors);
    while (actors.length < MAX_PLAYERS) {
      addPlayerAndGetReference(bot: true);
    }
    _weaponDrop = new WeaponDrop(this);
  }
    
  int removeActor(Actor a) {
    int index = actors.indexOf(a);
    actors.remove(a);
    removeObject(a);
    return index;
  }
    
  int indexOfBot() {
    for (Actor a in actors) {
      if (a is RandomWalker) return actors.indexOf(a);
    }
    return -1;
  }
  
  int countHumans() {
    int count = 0;
    for (Actor a in actors) {
      if (a is RandomWalker) count++;
    }
    return MAX_PLAYERS - count;
  }
  
  void removeActorAndReplaceWithBot(Actor a) {
    int i = removeActor(a);
    addPlayerAndGetReference(bot : true, index : i);
  }

  void start() {
    if (_timer == null && actors.length == MAX_PLAYERS) {
      //initializations

      _weaponDropTimer = new Timer.periodic(new Duration(seconds: 1), (timer) {
        if (!_objects.containsValue(_weaponDrop)) {
          _weaponDrop.spawn(this);
        }
      });
      
      //start game
      _timer = new Timer.periodic(new Duration(milliseconds: Frame.rate), this._goRound);
      for (Actor a in actors) {
        if (a is RandomWalker) a.start();
      }
    }
  }
  
  bool hasSpace() { return countHumans() != MAX_PLAYERS; }

  void stop() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
      print("[world ${this.hashCode}] stopped game");
    }

    if (_weaponDropTimer != null) {
      _weaponDropTimer.cancel();
      _weaponDropTimer = null;
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
  
  Actor addPlayerAndGetReference({bot:false,index:-1}) {
    index = index == -1? actors.length: index;

    int botIndex = indexOfBot();
    if (actors.length == MAX_PLAYERS) {
      if (botIndex == -1) {
        print("[world $hashCode] everyone is a player!");
        return null; // server full (no bots)
      } else {
        RandomWalker bot = actors[botIndex];
        bot.stop();
        removeActor(bot);
        print("[world $hashCode] attempt to replace bot $botIndex");
        index = botIndex;
      }      
    }
    
    var newPlayer;
    if (bot) { newPlayer = new RandomWalker(); newPlayer.start(); }
    else { newPlayer = new Actor(); }
    
    addObject(newPlayer);
    actors.insert(index, newPlayer);
    spawnRandomly(newPlayer);
    newPlayer.name = bot? "[$index]" + Bots.names[index]: "";
    print("[world ${this.hashCode}] added " + 
        (bot? "bot" : "actor") + 
        " ${actors.indexOf(newPlayer)}\t${newPlayer.hashCode}");
    
    if (actors.length == MAX_PLAYERS && countHumans() == 0) {
      print("[world $hashCode] no humans. stopping.");
      stop();
    }
    else start();

    return newPlayer;
  }

  int addPlayer() {
    Actor newPlayer = addPlayerAndGetReference();
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
          if (count >= loc &&
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
    object.myWorld = null;
    _removals.add(object);
    _objects.remove(object);
  }

  Frame getFrameDetail(int playerId) {
    if (!_objects.containsKey(playerId)) return null;
    if (!_playerFrames.containsKey(playerId)) {
      _playerFrames[playerId] = new Frame();
    }

    var frame = _playerFrames[playerId];
    Actor player = _objects[playerId];

    frame.playerId = playerId;
    frame.topX = player.x - (WorldConst.VIEWPORT_WIDTH/2);
    frame.topY = player.y - (WorldConst.VIEWPORT_HEIGHT/2);
    frame.time = 0;
    frame.kills = player.killCount;
    frame.chat = nextChat;

    frame.visibleObjects.clear();

    _objects.forEach((id,object) {
      WorldObject obj = object;
      if (obj.isInView(player.x, player.y, 100) ||
          obj is WeaponDrop ||
          (obj is Bullet &&
              obj.type != BulletType.BULLET &&
              obj.hitObject)) {
        var visiObj;

        if (obj is Actor)           visiObj = new ActorInFrame();
        else if (obj is Bullet)     visiObj = new BulletInFrame();
        else if (obj is WeaponDrop) visiObj = new WeaponDropInFrame();

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
          visiObj.index = actors.indexOf(obj);
          evaluateScore(obj);

        } else if (obj is Bullet) {
          visiObj.type = obj.type;
          visiObj.hitActor = obj.hitActor;
          visiObj.hitObject = obj.hitObject;
          visiObj.timedOut = obj.timedOut;
          visiObj.owner = obj.owner;
          obj.owner = -1;
        } else if (obj is WeaponDrop) {
          visiObj.weaponType = obj.weaponType;
        }
        frame.visibleObjects.add(visiObj);
      }

      num c = 0;
      frame.stats = "";
      for (Actor a in topScore) {
        if (c == 3) break;
        frame.stats += "${a.name}:\t\t${a.killCount}\n";
        c++;
      }
    });

    return frame;
  }

  void evaluateScore(Actor actor) {
    if (!topScore.contains(actor)) topScore.add(actor);
    topScore.sort((a, b) {
      return b.killCount.compareTo(a.killCount);
    });
  }

  void _update(num elapsed) {
    // physics stuff (collision etc.)
    _objects.forEach((k,v)=>v.doPhysics(elapsed,_objects));
    // individal object updates
    _objects.forEach((k,v)=>v.update(elapsed));

    nextChat = chatLogs.isNotEmpty? chatLogs.removeAt(0).replaceAll(";;;", ",") : "";
    
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
    //totalTime += elapsed;

    watch.reset();
    watch.start();

    //_checkWin();
    _update(elapsed);
  }

  /*
  void _checkWin() {
    bool reachedKillCount = false;
    actors.forEach((a) {
      if (a.killCount == WinConditions.KILLCOUNT)
        reachedKillCount = true;
    });

    if (totalTime > WinConditions.TIMELIMIT ||
        reachedKillCount) {
      stop();
      worldEnded = true;
    }
  }*/

  void action(CmdOld c) {
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

  void action2(Cmd c) {
    if (_timer == null) return;
    for (Actor a in actors) {
      if (a.hashCode == c.id) {
        if (c.moveX == -1) a.moveLeft();
        else if (c.moveX == 1) a.moveRight();
        else if (c.moveX == 0) a.stopLeftRightMove();

        if (c.moveY == -1) a.moveUp();
        else if (c.moveY == 1) a.moveDown();
        else if (c.moveY == 0) a.stopTopDownMove();

        if (c.moveR == -1) a.turnCounterClockwise();
        else if (c.moveR == 1) a.turnClockwise();
        else if (c.moveR == 0) a.stopTurn();

        if (c.fire == 1) a.weapon.fire();
        else if (c.fire == 0) a.weapon.stop();

        if (c.swap == 1) a.switchWeapon();

        if (c.mouseX != -1 && c.mouseY != -1) {
          a.turnToPoint(c.mouseX + a.x, c.mouseY + a.y);
        }

        if (c.name != a.name) { a.name = c.name; }
        if (c.chat != "") { chatLogs.add("${c.name}: ${c.chat}"); }
      }
    }
  }
}
