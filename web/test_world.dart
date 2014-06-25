import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'giggl.dart';


void main() {

  ResourceHandler.init();
  resMgr.load().then((_) {

    var ball = new ListeningActor()
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
    
    var object1 = new WorldActor(40,200,2)
      ..x = 100
      ..y = 250;
    
    world.addObject(object1);
  
    
    // connect real world with ggl
    object1.movementEvent.addObserver(ball);
    object1.movementEvent.addObserver(circle);
   
    // .. and presto!
    world.start();
    stage.focus = stage;
    stage.onKeyDown.listen((e) {
      if (e.keyCode == 65) {
        object1.moveLeft();
      }
      else if (e.keyCode == 87) {
        object1.moveUp();
      }
      else if (e.keyCode == 68) {
        object1.moveRight();
      }
      else if (e.keyCode == 83) {
        object1.moveDown();
      }
      
    });
    
    stage.onKeyUp.listen((e) { 
        if (e.keyCode == 65 || e.keyCode == 68) {
          object1.stopLefRightMove();
        }
        else if (e.keyCode == 83 || e.keyCode == 87) {
          object1.stopTopDownMove();
        }
      ;});
    
    stage.onMouseMove.listen((e) { 
       object1.turnToPoint(e.stageX, e.stageY);
    });
    
    stage.onMouseClick.listen ((e) { 
       WorldObject bullet = object1.weapon.fire();
       
       var realbullet = new RealBullet()
        ..x = bullet.x
        ..y = bullet.y;
       
       stage.addChild(realbullet);
       bullet.movementEvent.addObserver(realbullet);
     });
        
    
    stage.onEnterFrame.listen((EnterFrameEvent e) {
      html.querySelector('#detail').innerHtml = 'orientation: ${object1.orientation} xV: ${object1.xVelocity} yV: ${object1.yVelocity}';
    });
    });
 }




class RealBullet extends Shape implements Observer
{
  RealBullet() {
    this.graphics.ellipse(0, 0, 3,10);
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

class ListeningActor extends Actor implements Observer
{
  
  ListeningActor():super();
  
  void onNotify (Object data, int event ) {
    if (event == GglEvent.ObjectMoved) {
      var object = data as WorldObject;
      
      this.move(object.x, object.y);
      this.rotation = object.orientation;
    }
  }
 }

class Circler extends Shape implements Observer
{
  Circler() {
    this.graphics.circle(0, 0, 40);
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

