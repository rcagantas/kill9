import 'dart:html' as html;
import 'dart:math' as math;
import 'package:stagexl/stagexl.dart';
import 'package:giggl/gglclient2.dart';
import 'package:giggl/gglworld.dart';
import 'package:giggl/gglcommon.dart';
import 'dart:convert';

class RedDot extends DisplayObjectContainer {
  Shape shape;

  RedDot() {
    input.addListener(action);
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
    p1 = new PlayerSprite(0)
      ..x = stage.stageWidth/2
      ..y = stage.stageHeight/2
      ..addTo(this);
    input.addListener(p1.action);
    input.addListener(action);
  }

  void action(Cmd c) {
    if (input.key[69]) p1.takeDamage(p1.hpRatio - 1, 45 * math.PI/180);
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
    input.addListener(arena.action);
  }
}

class TestWorld extends DisplayObjectContainer {
  World world;
  Arena arena;
  Actor player1;
  TestWorld() {
    world = new World.size(20, 20);
    arena = new Arena(20, 20, world.grid.surfaceList)
      ..addTo(this);
    player1 = world.addPlayerandGetReference();
    input.mainId = player1.hashCode;
    input.addListener(world.action);
    world.addPlayerFrameListener(input.mainId, arena.updateFrame);
  }
}

class TestNetClient extends DisplayObjectContainer {
  Arena arena;
  Frame pf;
  TestNetClient() {
    String uri = "127.0.0.1";
    num port = 1024;
    html.WebSocket socket = new html.WebSocket("ws://${uri}:${port}/ws");
    print("trying to open $socket");
    socket.onOpen.listen((e) {
      print("socket opened.");
      socket.send("init");
      input.addListener((Cmd cmd) {
        if (arena == null) return;
        cmd.id = arena.mainId;
        socket.send(cmd.stringify());
      });
    });

    socket.onMessage.listen((e) {
      if (arena == null) {
        arena = new Arena(20, 20, JSON.decode(e.data))
          ..addTo(this);
      } else {
        arena.updateFrame(new Frame.fromString(e.data));
      }
    });
    socket.onError.listen((e) {
      print("cannot open socket");
    });
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

      TestWorld testWorld = null; //new TestWorld();
      TestNetClient testNetClient = new TestNetClient();
      setupPanel(testNetClient);

      html.querySelector("#player_name").onInput.listen((e) {
        input.name = e.target.value;
      });

      html.querySelector("#red").onClick.listen((e) {
        input.removeListeners();
        setupPanel(new RedDot());
      });

      html.querySelector("#player").onClick.listen((e) {
        input.removeListeners();
        setupPanel(new TestSprite());
      });

      html.querySelector("#arena").onClick.listen((e) {
        input.removeListeners();
        setupPanel(new TestArena());
      });

      html.querySelector("#world").onClick.listen((e) {
        input.removeListeners();;
        input.addListener(testWorld.world.action);
        setupPanel(testWorld);
      });
    });
  });
}