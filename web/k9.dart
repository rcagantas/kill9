import 'dart:html' as html;
import 'dart:math' as math;
import 'package:stagexl/stagexl.dart';
import 'package:giggl/gglclient2.dart';
import 'package:giggl/gglworld.dart';
import 'package:giggl/gglcommon.dart';

class RedDot extends DisplayObjectContainer {
  Shape shape;

  RedDot() {
    input.cbList.add(action);
    shape = new Shape()
      ..x = stage.stageWidth/2
      ..y = stage.stageHeight/2;
    shape.graphics.ellipse(0, 0, 15, 20);
    shape.graphics.fillColor(Color.Red);
    this.addChild(shape);
  }

  void action(Cmd c) {
    num ms = 5, tr = .10;
    shape.x += c.moveX * ms;
    shape.y += c.moveY * ms;
    shape.rotation += c.rotate * tr;
  }
}

class TestSprite extends DisplayObjectContainer {
  PlayerSprite p1;
  TestSprite() {
    p1 = new PlayerSprite()
      ..x = stage.stageWidth/2
      ..y = stage.stageHeight/2
      ..addTo(this);
    input.cbList.add(p1.action);
    input.cbList.add(action);
  }

  void action(Cmd c) {
    if (input.key[69]) p1.takeDamage(1, 45 * math.PI/180);
    if (input.key[82]) p1.hpRatio = 100;
  }
}

class TestArena extends DisplayObjectContainer {
  Arena arena;
  TestArena() {
    num width = 20, height = 20;
    List<num> surface = MapGenerator.createSimpleRandomSurface(width, height);
    arena = new Arena(width, height, surface)
      ..addTo(this);
    input.cbList.add(arena.action);
  }
}

class TestWorld extends DisplayObjectContainer {
  World world;
  Arena arena;
  Actor player1;
  TestWorld() {
    world = new World.size(20, 20);
    arena = new Arena(20, 20, world.grid.surfaceList);
    player1 = world.addPlayerandGetReference();
  }
}

void setupPanel(DisplayObjectContainer panel) {
  stage.removeChildren();
  stage.addChild(panel);
  stage.addChild(diagnostics);
}

void main() {
  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stage);
  print(input);
  print(resLoader);
  fontLoader.load.then((_) {
    resource.load().then((_) {

      setupPanel(new TestArena());

      html.querySelector("#red").onClick.listen((e) {
        input.cbList.clear();
        setupPanel(new RedDot());
      });

      html.querySelector("#player").onClick.listen((e) {
        input.cbList.clear();
        setupPanel(new TestSprite());
      });

      html.querySelector("#arena").onClick.listen((e) {
        input.cbList.clear();
        setupPanel(new TestArena());
      });
    });
  });
}