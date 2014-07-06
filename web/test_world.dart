import 'package:stagexl/stagexl.dart';
import 'package:giggl/gglclient.dart';
import 'package:giggl/gglserver.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:html' as html;

Arena client;
InputHandler io;
PlayerSprite p1;
WorldActor player1;

Map<int, PlayerSprite> otherPs = new Map();
Map<int, WorldActor> otherAs = new Map();
Map<int, RealBullet> realBullets = new Map();

List<int> visible = new List();
List<RandomWalker> walkers = new List();

void main() {
  ResourceHandler.init();
  resMgr.load().then((_) {
    renderLoop.addStage(stage);
    client = new Arena();
    var nonPassableList = client.createRandomMap(20, 20);
    p1 = client.p1;
    p1.move(1000, 1000);



    var grid = new Grid(20,20,100);
    nonPassableList.forEach((p) {
      math.Point point = p;
      grid.set(point.x, point.y, new Tile(Surface.NotPassable));
    });


    var world = new World(grid);

    player1 = world.addPlayerandGetReference()
      ..x = 850
      ..y = 900;


    for (int i=1; i<5; i++) {
      var p = new PlayerSprite()
      ..move(850 + (i*50) , 900 )
      ..addTo(client.playerPanel);

      var actor = world.addPlayerandGetReference()
          ..x = 850 + (i*50)
          ..y = 900;

      otherPs[actor.hashCode] = p;
      otherAs[actor.hashCode] = actor;
    }

    for (int i=1; i<6; i++) {
      var p = new PlayerSprite()
      ..move(800 + (i*50) , 1000 )
      ..addTo(client.playerPanel);

      var actor = world.addPlayerandGetReference()
          ..x = 800 + (i*50)
          ..y = 1000;

      otherPs[actor.hashCode] = p;
      otherAs[actor.hashCode] = actor;
    }

    world.bullets.getBulletList().forEach((id) {
      realBullets[id] = new RealBullet()
      ..addTo(client.playerPanel)
      ..visible = false;
    });

    p1.removeFromParent();
    p1.addTo(client.playerPanel);

    world.addPlayerFrameListener(player1.hashCode, updateFrame);
    world.start();

    stage.onKeyUp.listen(onKeyUp);
    stage.onEnterFrame.listen(onFrame);
    stage.onMouseMove.listen(onMouseMove);
    stage.onMouseRightClick.listen((e) => p1 != null? p1.cycleWeapon() : 0);
    io = new InputHandler();


    otherAs.forEach((k,v) {
       new RandomWalker(v)
        ..start();
    });

    stage.onEnterFrame.listen((EnterFrameEvent e) {
      int count = 0;


      otherPs.values.forEach((p) {
        if (p.hp == 0) count = count + 1;
      });
      if (count < 9) {
        html.querySelector('#detail').innerHtml = 'Killed: $count';
      }
      else {
        html.querySelector('#detail').innerHtml = 'You WIN!!';

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

  if (io.keyState[37]) { player1.turnIncrement(-.1); }
  if (io.keyState[39]) { player1.turnIncrement(.1); }
  if (io.keyState[38] || io.mouseL) { p1.fire(); player1.weapon.fire();}
  if (!io.keyState[38] && !io.mouseL){ player1.weapon.stop(); }
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
  p1.move(p.x, p.y);
  p1.turn(p.playerOrientation);
  client.move(-p.topX, -p.topY);

  visible.removeRange(0, visible.length);

  p.visibleObjects.forEach((object) {
    if (otherPs.containsKey(object.id)) {
      var player = otherPs[object.id]
        ..move(object.x, object.y)
        ..turn(object.orientation);

      var damage = player.hp - object.life;

      if (damage>0) {
        player.takeDamage(damage,false);
      }
      visible.add(object.id);
    }
    else if (realBullets.containsKey(object.id)) {
      realBullets[object.id].x = object.x;
      realBullets[object.id].y = object.y;
      visible.add(object.id);
    }
  });

  otherPs.forEach((x,v) {
    v.visible = visible.contains(x);
  });

  realBullets.forEach((x,v) {
    v.visible = visible.contains(x);
  });
}

class RandomWalker {

  WorldActor player;
  RandomWalker (this.player);
  math.Random random = new math.Random();
  Timer _timer;

  void start() {
    _timer = new Timer.periodic(new Duration(milliseconds: 2000), _walkRandomly);
  }

  void stop() {
    _timer.cancel();
  }

  void _walkRandomly(Timer timer)  {
    player.stopLeftRightMove();
    player.stopTopDownMove();
    player.stopTurn();

    var move = random.nextInt(3);

    if (move == 0) {
      player.moveLeft();
    } else if (move == 1) {
      player.moveRight();
    }

    move = random.nextInt(3);

    if (move == 0) {
      player.moveUp();
    } else if (move == 1) {
      player.moveDown();
    }

    move = random.nextInt(3);

    if (move == 0) {
      player.turnClockwise();
    } else if (move == 1) {
      player.turnCounterClockwise();
    }
  }
}


class RealBullet extends Shape
{
  RealBullet() {
    this.graphics.circle(0, 0, 2);
    this.graphics.fillColor(Color.Black);
  }
}


