part of giggl;

class World {
  Grid grid;
  List<WorldObject> _objects;
  
  int _tileWidth;
  int _worldWidth;
  int _worldHeight;
  Timer _timer = null;
 
  World (grid) {
    this.grid = grid;
    _worldWidth = grid.width() * grid.tileWidth();
    _worldHeight = grid.height() * grid.tileWidth();  
    _objects = new List();
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
    _objects.add(object);
    object.myWorld = this;
  }
  
  void removeObject(WorldObject object) {
    _objects.remove(object);
    object.myWorld = null;
  }
  
  void _processInput() {
    // process input
  }
  
  void _update(num elapsed) {
    
    // AI stuff 
    
    // physics stuff (collision etc.)
    
    // individal object updates
    var templist = _objects.toList();
    templist.forEach((object)=>object.update(elapsed));
  }
  
  void _goRound(Timer timer) {
    
    num elapsed = 0.01;
    
    _processInput();
    _update(elapsed);
  }
}
