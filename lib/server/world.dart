part of gglserver;

class World {
  Grid grid;
  Map _objects = new Map();
  List _removals = new List();
  Map _listeners = new Map();
  Map<int, Frame> _playerFrames = new Map();

  int _tileWidth;
  int _worldWidth;
  int _worldHeight;
  Timer _timer = null;

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

  WorldActor addPlayer() {
    var newPlayer = new WorldActor();
    addObject(newPlayer);
    return newPlayer;
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
    frame.playerLife = 100;
    frame.x = player.x;
    frame.y = player.y;

    frame.topX = player.x - (WorldConst.viewPortWidth/2);
    frame.topY = player.y - (WorldConst.viewPortHeight/2);

    _objects.forEach((id,object) {
      WorldObject obj = object;
      if (id != playerId  && obj.isInView(frame.topX, frame.topY,
          frame.topX + WorldConst.viewPortWidth, frame.topY + WorldConst.viewPortHeight)) {
        var visibleObject = new ObjectInFrame();
        visibleObject.x = obj.x;
        visibleObject.y = obj.y;
        visibleObject.orientation = obj.orientation;
        visibleObject.id = obj.hashCode;
        if (frame.visibleObjects.length > 0) {
          frame.visibleObjects.removeRange(0,frame.visibleObjects.length-1);
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

    // individal object updates
    _objects.forEach((k,v)=>v.update(elapsed));

    // objects for removal
    _removals.forEach((obj)=>_objects.remove(obj.hashCode));

    //generate frame for each player
    _listeners.forEach((playerId,listener){
      var playerFrame = getFrameDetail(playerId);
      listener(playerFrame);
    });
  }

  void _goRound(Timer timer) {

    // redo this for actual time elapsed calculation
    num elapsed = 0.01;

    _processInput();
    _update(elapsed);
  }
}

class ObjectInFrame {
  int id;
  int objectType;
  int objectState;
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

