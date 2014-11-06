import 'package:stagexl/stagexl.dart';
import 'package:giggl/gglclient2.dart';

class RedDot extends DisplayObjectContainer {
  Shape shape;

  RedDot() {
    input.cbList.add(action);
    shape = new Shape();
    shape.graphics.ellipse(0, 0, 50, 100);
    shape.graphics.fillColor(Color.Red);
    stage.addChild(shape);
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
  }
}

void main() {
  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stage);
  print(input);
  print(resLoader);
  fontLoader.load.then((_) {
    resource.load().then((_) {
      stage.addChild(new TestSprite());
      stage.addChild(diagnostics);
    });
  });
}