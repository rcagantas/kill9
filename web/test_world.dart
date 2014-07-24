import 'dart:async';
import 'dart:math' as math;
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'package:giggl/gglclient.dart';
import 'package:giggl/gglworld.dart';
import 'package:giggl/gglcommon.dart';

Arena arena;
InputHandler io;
PlayerSprite p1;
Actor player1;

Map<int, PlayerSprite> players = new Map();
Map<int, Actor> actors = new Map();
Map<int, BulletSprite> bullets = new Map();

List<int> visible = new List();
List<RandomWalker> walkers = new List();

void main() {
  ResourceHandler.init();
  resMgr.load().then((_) {
    renderLoop.addStage(stage);
    arena = new Arena();
    num width = 20;
    num height = 20;
    var surfaceList = MapGenerator.createSimpleRandomSurface(width, height);
    arena.createMap(width, height, surfaceList);
    //p1 = arena.p1;
    //p1.move(1000, 1000);

    var grid = new Grid.surface(width, height, 100, surfaceList);

    var world = new World(grid);

    player1 = world.addPlayerandGetReference()
      ..x = 850
      ..y = 900;

    p1 = new PlayerSprite()
      ..move(player1.x, player1.y)
      ..addTo(arena.playerPanel);
    arena.p1 = p1;

    for (int i=1; i<5; i++) {
      var p = new PlayerSprite()
      ..move(850 + (i*50) , 900 )
      ..addTo(arena.playerPanel)
      ..nameDisplay.text = Bots.names[i - 1];

      var actor = world.addPlayerandGetReference()
          ..x = 850 + (i*50)
          ..y = 900;

      players[actor.hashCode] = p;
      actors[actor.hashCode] = actor;
    }

    for (int i=1; i<6; i++) {
      var p = new PlayerSprite()
      ..move(800 + (i*50) , 1000 )
      ..addTo(arena.playerPanel)
      ..nameDisplay.text = Bots.names[3 + i];

      var actor = world.addPlayerandGetReference()
          ..x = 800 + (i*50)
          ..y = 1000;

      players[actor.hashCode] = p;
      actors[actor.hashCode] = actor;
    }

    world.bullets.getBulletList().forEach((id) {
      bullets[id] = new BulletSprite()
      ..addTo(arena.playerPanel)
      ..visible = false;
    });

    p1.removeFromParent();
    p1.addTo(arena.playerPanel);

    world.addPlayerFrameListener(player1.hashCode, updateFrame);
    world.start();

    stage.onKeyUp.listen(onKeyUp);
    stage.onEnterFrame.listen(onFrame);
    stage.onMouseMove.listen(onMouseMove);
    stage.onMouseRightClick.listen((e) => player1 != null? player1.switchWeapon() : 0);
    io = new InputHandler();


    actors.forEach((k,v) {
       new RandomWalker(v)
        ..start();
    });


    players[player1.hashCode] = p1;
    actors[player1.hashCode] = player1;

    stage.onEnterFrame.listen((EnterFrameEvent e) {
      int count = 0;


      players.values.forEach((p) {
        if (p.hp == 0) count = count + 1;
      });
      if (count < 9) {
        html.querySelector('#detail').innerHtml = 'Killed: $count Weapon: ${p1.weapon} Ammo: ${player1.weapon.ammo}';
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

  if (io.keyState[37]) { player1.turnIncrement(-.05); }
  if (io.keyState[39]) { player1.turnIncrement(.05); }
  if (io.keyState[38] || io.mouseL) { player1.weapon.fire();}
  if (!io.keyState[38] && !io.mouseL){ player1.weapon.stop(); }
}

void onKeyUp(KeyboardEvent e) {
  if (p1 == null) return;
  if (e.keyCode == 40) { player1.switchWeapon(); }
  if (e.keyCode == 38 || e.keyCode == 40) {
  }
}

void onMouseMove(MouseEvent e) {
  if (p1 == null) return;
  player1.turnToPoint(e.stageX + player1.x - stage.stageWidth/2,
      e.stageY + player1.y - stage.stageHeight/2);
}

void updateFrame (Frame p) {
  arena.move(-p.topX, -p.topY);
  visible.clear();

  p.visibleObjects.forEach((object) {
    if (players.containsKey(object.id)) {
      var player = players[object.id]
        ..move(object.x, object.y)
        ..turn(object.orientation)
        ..modHitPoints(object.lifeRatio, object.damageFrom)
        ..setWeapon(object.weaponType);
      if (!object.isMoving) player.stopMoving();
      if (object.isFiring) player.fire();
      visible.add(object.id);
    }
    else if (bullets.containsKey(object.id)) {
      bullets[object.id].type = object.type;
      bullets[object.id].x = object.x;
      bullets[object.id].y = object.y;
      bullets[object.id].rotation = object.orientation;
      if (object.hitObject) bullets[object.id].explode();
      visible.add(object.id);
    }
  });

  players.forEach((x,v) {
    v.visible = visible.contains(x);
  });

  bullets.forEach((x,v) {
    v.visible = visible.contains(x);
  });
}

class RandomWalker {

  Actor player;
  RandomWalker (this.player);
  math.Random random = new math.Random();
  Timer _timer, _fireTimer = null, _stopTimer;

  void start() {
    _timer = new Timer.periodic(new Duration(milliseconds: 2000), _walkRandomly);
  }

  void stop() {
    _timer.cancel();
    _fireTimer.cancel();
    _stopTimer.cancel();
  }

  void _stopFiring(Timer timer) {
    player.weapon.stop();
  }

  void _fire(Timer timer) {
    if (player.life == 0) return;
    var fire = random.nextInt(2);
    if (fire == 0) player.weapon.fire();
  }

  void _walkRandomly(Timer timer)  {
    player.stopLeftRightMove();
    player.stopTopDownMove();
    player.stopTurn();

    if (_fireTimer == null) {
      _fireTimer = new Timer.periodic(new Duration(milliseconds: 200), _fire);
      _stopTimer = new Timer.periodic(new Duration(milliseconds: 10), _stopFiring);
    }

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

