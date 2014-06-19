import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'giggl_server.dart';

void main() {
  // real world stuff
  var canvas = html.querySelector('#stage');
  var stage = new Stage(canvas);
  var ball = new VisiBall(Color.Blue)
    ..x = 250
    ..y = 250;
  var renderLoop = new RenderLoop();
  var juggler = renderLoop.juggler;
  stage.addChild(ball);
  renderLoop.addStage(stage);
  

  // ggl server stuff
  var world = new World(50,50,10);
  
  var object1 = new WorldObject(250,250,0,10,100, 2);
  

  world.addObject(object1);

  // connect real world with ggl
  object1.eventMoved.addObserver(ball);
 
  // .. and presto!
  world.start();
  stage.focus = stage;
  stage.onKeyDown.listen((e) {
    if (e.keyCode == 37) {
      object1.turnLeft();
    }
    else if (e.keyCode == 38) {
      object1.moveForward();
    }
    else if (e.keyCode == 39) {
      object1.turnRight();
    }
    else if (e.keyCode == 40) {
      object1.moveBackward();
    }
    
  });
  
  stage.onKeyUp.listen((e) { 
      if (e.keyCode == 37 || e.keyCode == 39) {
        object1.stopTurn();
      }
      else if (e.keyCode == 38 || e.keyCode == 40) {
        object1.stopMove();
      }
    ;});
  
  stage.onEnterFrame.listen((EnterFrameEvent e) {
    html.querySelector('#detail').innerHtml = 'orientation: ${object1.orientation} xV: ${object1.xVelocity} yV: ${object1.yVelocity}';
  });
 }

class VisiBall extends Shape implements Observer
{
   VisiBall(num color)
   {
    this.graphics.ellipse(0, 0, 20, 40);
    this.graphics.circle(0, -15, 10);
    this.graphics.fillColor(color);
   }
  
  void onNotify (Object data, int event ) {
    if (event == GglEvent.ObjectMoved) {
      var object = data as WorldObject;
      
      this.x = object.xLocation;
      this.y = object.yLocation;
      this.rotation = object.orientation;
    }
  }
}  
