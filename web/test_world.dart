import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'package:giggl/gglclient.dart';
import 'package:giggl/gglserver.dart';

void main() {

  ResourceHandler.init();

  resMgr.load().then((_) {

    var actor1 = new Player()
      ..setWeapon("grenade")
      ..move(-100, -100);

    var renderLoop = new RenderLoop();
    var juggler = renderLoop.juggler;
    stage.addChild(actor1);
    renderLoop.addStage(stage);


    var grid = new Grid(20,20,100);
    var tile = new Tile(Surface.NotPassable);
    grid.set(0, 0, tile);
    grid.set(4, 4, tile);
    grid.set(10, 0, tile);
    grid.set(10, 1, tile);
    grid.set(10, 2, tile);
    grid.set(10, 3, tile);
    grid.set(19, 19, tile);

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

    var object1 = world.addPlayer()
      ..x = 100
      ..y = 250;

    world.addObject(object1);

    world.addPlayerFrameListener(object1.hashCode, (pf){
      actor1.move(pf.player.x, pf.player.y);
      actor1.turn(pf.player.orientation);
    });

    world.start();

    InputHandler io = new InputHandler();

    stage.onEnterFrame.listen((e) {
        num ix = 0, iy = 0, ih = 0, it = 0, inc = 2, rinc = 0.1;
        if (io.keyState[87]) { object1.moveUp(); }
        if (io.keyState[83]) { object1.moveDown(); }
        if (io.keyState[65]) { object1.moveLeft(); }
        if (io.keyState[68]) { object1.moveRight(); }
        if (!io.keyState[87] && !io.keyState[83]) { object1.stopTopDownMove() ;}
        if (!io.keyState[65] && !io.keyState[68]) { object1.stopLeftRightMove(); }
        if (io.keyState[37]) { object1.orientation -= rinc; }
        if (io.keyState[39]) { object1.orientation += rinc; }
        html.querySelector('#detail').innerHtml =
            'orientation: ${object1.orientation} xV: ${object1.xVelocity} yV: ${object1.yVelocity}';
      });

      stage.onMouseMove.listen((e) {
        object1.turnToPoint(e.stageX, e.stageY);
      });
  });
}

