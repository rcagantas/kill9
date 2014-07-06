part of gglserver;

class World {
  Grid grid;
  Map _objects = new Map();
  List _removals = new List();
  Map _listeners = new Map();
  Map<int, Frame> _playerFrames = new Map();
  BulletFactory bullets = new BulletFactory(200);

  int _tileWidth;
  int _worldWidth;
  int _worldHeight;
  Timer _timer = null;
  Stopwatch watch = new Stopwatch();

  World (grid) {
    this.grid = grid;
    _worldWidth = grid.width() * grid.tileWidth();
    _worldHeight = grid.height() * grid.tileWidth();
  }

  void start() {
    if (_timer == null){
      _timer = new Timer.periodic(new Duration(milliseconds: 10), this._goRound);
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

  WorldActor addPlayerandGetReference() {
    var newPlayer = new WorldActor();
    addObject(newPlayer);
    return newPlayer;
  }

  int addPlayer() {
    var newPlayer = new WorldActor();
    addObject(newPlayer);
    return newPlayer.hashCode;
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
    WorldActor player = _objects[playerId];

    frame.playerId = playerId;
    frame.playerOrientation = player.orientation;
    frame.playerLife = player.life;
    frame.x = player.x;
    frame.y = player.y;

    frame.topX = player.x - (WorldConst.viewPortWidth/2);
    frame.topY = player.y - (WorldConst.viewPortHeight/2);

    frame.visibleObjects.clear();

    _objects.forEach((id,object) {
      WorldObject obj = object;
      if (id != playerId  && obj.isInView(frame.topX, frame.topY,
          frame.topX + WorldConst.viewPortWidth, frame.topY + WorldConst.viewPortHeight)) {
        var visibleObject = new ObjectInFrame();
        visibleObject.x = obj.x;
        visibleObject.y = obj.y;
        visibleObject.orientation = obj.orientation;
        visibleObject.id = obj.hashCode;
        if (obj is WorldActor) {
          visibleObject.life = obj.life;
        }
        frame.visibleObjects.add(visibleObject);
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

    // objects for removal
    _removals.forEach((obj)=>_objects.remove(obj.hashCode));
    _removals.clear();

    //generate frame for each player
    _listeners.forEach((playerId,listener){
      var playerFrame = getFrameDetail(playerId);
      listener(playerFrame);
    });
  }

  void _goRound(Timer timer) {

    watch.stop();

    num elapsed = watch.elapsedMilliseconds/1000;

    watch.reset();
    watch.start();

    _processInput();
    _update(elapsed);
  }
}

class ObjectInFrame {
  int id;
  int objectType;
  int objectState;
  int life;
  num x,y,orientation;
}

class Frame {

  // Player detail;
  int playerId;
  num playerOrientation;
  num x,y;
  num playerLife;

  // Weapon detail:
  int weaponType;
  int weaponAmmo;

  // Viewport
  num topX,topY;

  // Objects visible in the world
  List<ObjectInFrame> visibleObjects = new List();

  String toString() {
    var stringBuffer = new StringBuffer()
    ..write("PlayerId: $playerId topX: $topX topY $topY");
    return stringBuffer.toString();
  }
}

