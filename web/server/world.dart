part of giggl;

class World {
  Grid grid;
  Map _objects = new Map();
  List _removals = new List();
  Map _listeners = new Map();
  Map<int, PlayerFrame> _playerFrames = new Map();

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

  void addPlayerFrameListener(int playerId, void listener(PlayerFrame pf)) {
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

  PlayerFrame getFrameDetail(int playerId) {
    if (!_playerFrames.containsKey(playerId)) {
      _playerFrames[playerId] = new PlayerFrame();
    }

    var frame = _playerFrames[playerId];
    var player = _objects[playerId];
    updatePlayerFrame(player,frame);

    return frame;
  }

  void updatePlayerFrame(WorldActor player, PlayerFrame frame) {
    frame.player = player;
    frame.topX = player.x;
    frame.topY = player.y;
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

class PlayerFrame {

  // Player detail;
  WorldActor player;

  // Viewport
  num topX,topY;

  // Objects visible in the world
  List<WorldObject> objectsInView;

  String toString() {
    var stringBuffer = new StringBuffer()
    ..write("PlayerId: ${player.hashCode} topX: $topX topY $topY");
    return stringBuffer.toString();
  }
}

