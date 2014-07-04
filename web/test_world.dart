import 'package:stagexl/stagexl.dart';
import 'package:giggl/gglclient.dart';
import 'package:giggl/gglserver.dart';
import 'dart:async';
import 'dart:math';

Arena client;
InputHandler io;
PlayerSprite p1;
PlayerSprite p2;
WorldActor player1;
WorldActor player2;


void main() {
  ResourceHandler.init();
  resMgr.load().then((_) {
    renderLoop.addStage(stage);
    client = new Arena();
    client.createRandomMap(20, 20);
    p1 = client.p1;
    p1.x = 1000;
    p1.y = 1000;
    p2 =  new PlayerSprite()
    ..move(1000, 1000)
    ..addTo(client);

    var grid = new Grid(20,20,100);
    var world = new World(grid);
    player1 = world.addPlayer();
    player2 = world.addPlayer();
    player1.x = 1000;
    player1.y = 1000;
    player2.x = 1000;
    player2.y = 1000;

    world.addPlayerFrameListener(player1.hashCode, updateFrame);
    world.start();

    stage.onKeyUp.listen(onKeyUp);
    stage.onEnterFrame.listen(onFrame);
    stage.onMouseMove.listen(onMouseMove);
    stage.onMouseRightClick.listen((e) => p1 != null? p1.cycleWeapon() : 0);
    io = new InputHandler();

    var random = new Random();

    var timer = new Timer.periodic(new Duration(milliseconds: 2000), (elapsedTime) {
      player2.stopLeftRightMove();
      player2.stopTopDownMove();
      player2.stopTurn();

      var move = random.nextInt(3);

      if (move == 0) {
        player2.moveLeft();
      } else if (move == 1) {
        player2.moveRight();
      }

      move = random.nextInt(3);

      if (move == 0) {
        player2.moveUp();
      } else if (move == 1) {
        player2.moveDown();
      }

      move = random.nextInt(3);

      if (move == 0) {
        player2.turnClockwise();
      } else if (move == 1) {
        player2.turnCounterClockise();
      }
     });
  });
}

void onFrame(Event e) {
  if (p1 == null) return;
  handleInput();
}

void handleInput() {
  num ix = 0, iy = 0, ih = 0, it = 0, inc = 4, rinc = 0.1;

  if (io.keyState[87]) {
    player1.moveUp();
  }
  else if (io.keyState[83]) {
    player1.moveDown();
  }
  else {
    player1.stopTopDownMove();
  }

  if (io.keyState[65]) {
    player1.moveLeft();
  }
  else if (io.keyState[68]) {
    player1.moveRight();
  }
  else {
    player1.stopLeftRightMove();
  }

  if (io.keyState[37]) { player1.turnCounterClockise(); }
  if (io.keyState[39]) { player1.turnCounterClockise(); }
  if (io.keyState[38] || io.mouseL) { p1.fire(); }
  if (io.keyState[69]) { p1.takeDamage(1); }
}

void onKeyUp(KeyboardEvent e) {
  if (p1 == null) return;
  if (e.keyCode == 40) { p1.cycleWeapon(); }
  if (e.keyCode == 38 || e.keyCode == 40) {
    p1.resetTorso();
  }
}

void onMouseMove(MouseEvent e) {
  if (p1 == null) return;
  player1.turnToPoint(e.stageX + player1.x - stage.stageWidth/2,
      e.stageY + player1.y - stage.stageHeight/2);
}

void updateFrame (Frame p) {
  bool found = false;

  p1.move(p.x, p.y);
  p1.turn(p.playerOrientation);
  client.move(-p.topX, -p.topY);

  p.visibleObjects.forEach((object) {
    if (object.id == player2.hashCode) {
      p2.move(object.x, object.y);
      p2.turn(object.orientation);
      found = true;
    }
  });

  p2.visible = found;

}
