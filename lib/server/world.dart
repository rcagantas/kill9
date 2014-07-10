part of gglserver;

class World {
  Grid grid;
  Map _objects = new Map();
  List _removals = new List();
  Map _listeners = new Map();
  Map<int, Frame> _playerFrames = new Map();
  BulletFactory bullets = new BulletFactory(1000);

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

  Actor addPlayerandGetReference() {
    var newPlayer = new Actor();
    addObject(newPlayer);
    return newPlayer;
  }

  int addPlayer() {
    var newPlayer = new Actor();
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
        var visiObj = obj is Actor?
            new ActorInFrame() :
            new BulletInFrame();
        visiObj.x = obj.x;
        visiObj.y = obj.y;
        visiObj.orientation = obj.orientation;
        visiObj.id = obj.hashCode;
        if (obj is Actor) {
          visiObj.lifeRatio = (obj.life * 100)/Actor.MAX_LIFE;
          visiObj.damageFrom = obj.damageFrom;
          visiObj.isFiring = obj.weapon.isFiring;
          visiObj.isMoving = obj.isMoving();
        }
        frame.visibleObjects.add(visiObj);
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
