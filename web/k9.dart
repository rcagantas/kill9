import 'dart:html' as html;
import 'dart:math' as math;
import 'package:stagexl/stagexl.dart';
import 'package:giggl/gglclient2.dart';
import 'package:giggl/gglworld.dart';

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
    input.cbList.add(action);
  }

  void action(Cmd c) {
    num ms = 5, tr = .10;
    num x = p1.x + c.moveX * ms;
    num y = p1.y + c.moveY * ms;
    num r = p1.rotation + c.rotate * tr;
    p1.move(x, y, r);
    p1.walk(c.moveX != 0 || c.moveY != 0 || c.rotate != 0);
    if (c.fire) p1.fire();
    if (c.swap) p1.swapWeapon();
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
    input.cbList.add(action);
  }

  void action(Cmd c) {
    num ms = 5, tr = .10;
    arena.x -= c.moveX * ms;
    arena.y -= c.moveY * ms;
  }
}

void main() {
  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stage);
  print(input);
  print(resLoader);
  fontLoader.load.then((_) {
    resource.load().then((_) {
      // default
      DefaultPanel canvasPanel = new DefaultPanel()
        ..addTo(stage);
      stage.addChild(diagnostics);

      html.querySelector("#red").onClick.listen((e) {
        canvasPanel.removeChildren();
        canvasPanel.addChild(new RedDot());
      });

      html.querySelector("#player").onClick.listen((e) {
        canvasPanel.removeChildren();
        canvasPanel.addChild(new TestSprite());
      });

      html.querySelector("#arena").onClick.listen((e) {
        canvasPanel.removeChildren();
        canvasPanel.addChild(new TestArena());
      });

    });
  });
}