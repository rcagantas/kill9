import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'giggl.dart';


void main() {

  ResourceHandler.init();
  resMgr.load().then((_) {

    var ball = new ListeningActor()
      ..setWeapon("grenade")
      ..move(100, 250);
    var circle = new Circler()
      ..x=100
      ..y=250;
    var renderLoop = new RenderLoop();
    var juggler = renderLoop.juggler;
    stage.addChild(ball);
    stage.addChild(circle);
    renderLoop.addStage(stage);
    
  
    var grid = new Grid(5,5,100);
    var tile = new Tile(Surface.NotPassable);
    grid.set(0, 0, tile);
    grid.set(4, 4, tile);
    grid.set(2, 2, tile);
        
    for (int i = 0; i < grid.width(); i++) {
      for  (int j =0; j < grid.height(); j++) {
        var curTile = grid.get(i, j);
        
        if (curTile != null) {
          var block = new Shape()
            ..graphics.rect(0,0, 100, 100)
            ..graphics.fillColor(Color.Red)
            ..x = i * 100
            ..y = j * 100;
          stage.addChild(block);
        }
      }
    }
    
    var world = new World(grid);
    
    var object1 = new WorldActor(25,200,2)
      ..x = 100
      ..y = 250;
    
    world.addObject(object1);
  
    
    // connect real world with ggl
    object1.movementEvent.addObserver(ball);
    object1.movementEvent.addObserver(circle);
   
    // .. and presto!
    world.start();
    InputHandler io = new InputHandler();
    stage.onEnterFrame.listen((e) {
      num ix = 0, iy = 0, ih = 0, it = 0, inc = 2, rinc = 0.1;
      object1.stopLefRightMove();
      object1.stopTopDownMove();
      if (io.keyState[87]) { object1.moveUp(); }
      if (io.keyState[83]) { object1.moveDown(); }
      if (io.keyState[65]) { object1.moveLeft(); }
      if (io.keyState[68]) { object1.moveRight(); }
      if (io.keyState[37]) { object1.orientation -= rinc; }
      if (io.keyState[39]) { object1.orientation += rinc; }
      html.querySelector('#detail').innerHtml = 
          'orientation: ${object1.orientation} xV: ${object1.xVelocity} yV: ${object1.yVelocity}';
    });
    
    stage.onMouseMove.listen((e) { 
      object1.turnToPoint(e.stageX, e.stageY);
    });
    
    stage.onMouseDown.listen ((e) { 
      Grenade bullet = object1.weapon.fire();
       
      var realbullet = new RealGrenade()
        ..x = bullet.x
        ..y = bullet.y;
       
      stage.addChild(realbullet);
      bullet.movementEvent.addObserver(realbullet);
      bullet.expires.addObserver(realbullet);
    });
  });
}




class RealBullet extends Shape implements Observer
{
  RealBullet() {
    this.graphics.ellipse(0, 0, 3, 10);
    this.graphics.fillColor(Color.Blue);
   }
  
  void onNotify (Object data, int event ) {
    if (event == GglEvent.ObjectMoved) {
      var object = data as WorldObject;
      
      this.x = object.x;
      this.y = object.y;
      this.rotation = object.orientation;
    }
  }
}

class RealGrenade extends Shape implements Observer
{
  RealGrenade() {
    this.graphics.circle(0, 0, 5);
    this.graphics.fillColor(Color.Brown);
   }
  
  void onNotify (Object data, int event ) {
    if (event == GglEvent.ObjectMoved) {
      var object = data as WorldObject;
      
      this.x = object.x;
      this.y = object.y;
      this.rotation = object.orientation;
    } else if (event == GglEvent.GrenadeExpires) {
      var object = data as Grenade;
      object.expires.removeObserver(this);
      object.movementEvent.removeObserver(this);
      stage.removeChild(this);
    }
  }
}

class ListeningActor extends Actor implements Observer
{
  
  ListeningActor():super();
  
  void onNotify (Object data, int event ) {
    if (event == GglEvent.ObjectMoved) {
      var object = data as WorldObject;
      
      this.move(object.x, object.y);
      this.turn(object.orientation);
    }
  }
 }

class Circler extends Shape implements Observer
{
  Circler() {
    this.graphics.circle(0, 0, 25);
    this.graphics.strokeColor(Color.Black);
   }
  
  void onNotify (Object data, int event ) {
    if (event == GglEvent.ObjectMoved) {
      var object = data as WorldObject;
      
      this.x = object.x;
      this.y = object.y;
    }
  }
}

