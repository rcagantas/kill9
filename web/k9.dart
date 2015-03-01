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
  }

  void action(Cmd c) {
    p1.action(c);
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

class TestLocal extends DisplayObjectContainer {
  World world;
  Arena arena;
  Actor player1;
  TestLocal() {
    world = new World.size(20, 20);
    arena = new Arena(20, 20, world.grid.surfaceList)
      ..addTo(this);
  }

  void start() {
    if (player1 != null) return;
    player1 = world.addPlayerandGetReference();
    input.mainId = player1.hashCode;
    input.addListener(world.action);
    world.addPlayerFrameListener(input.mainId, arena.updateFrame);
  }
}

class TestNetClient extends DisplayObjectContainer {
  Arena arena;
  Frame pf;
  html.WebSocket socket;

  TestNetClient() {
    String uri = "127.0.0.1";
    num port = 1025;
    socket = new html.WebSocket("ws://${uri}:${port}/ws");
    print("trying to open $socket");

    socket.onOpen.listen((e) {
      print("socket opened.");
      socket.send("init");
      input.addListener(action);
    });

    socket.onMessage.listen((e) {
      if (arena == null) {
        arena = new Arena(20, 20, JSON.decode(e.data))
          ..addTo(this);
      } else {
        pf = new Frame.fromString(e.data);
      }
    });

    socket.onError.listen((e) {
      print("cannot open socket");
    });

    stage.onEnterFrame.listen((e) {
      if (pf == null) return;
      arena.updateFrame(pf);
    });
  }

  void action(Cmd cmd) {
    if (arena == null) return;
    cmd.id = arena.mainId;
    socket.send(cmd.stringify());
  }
}

void setupPanel(DisplayObjectContainer panel, Function action) {
  input.removeListeners();
  if (action != null) input.addListener(action);
  stage.removeChildren();
  stage.addChild(panel);
  //stage.addChild(diagnostics);
}

void main() {
  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stage);
  print(input);
  print(resLoader);

  resource.load().then((_) {
    RedDot dot = new RedDot();
    TestSprite sprite = new TestSprite();
    TestArena arena = new TestArena();
    TestLocal local = new TestLocal();
    TestNetClient net = new TestNetClient();

    html.querySelector("#player_name").onInput.listen((e) {
      local.world.stop();
      input.name = e.target.value;
    });

    html.querySelector("#red").onClick.listen((e) {
      local.world.stop();
      setupPanel(dot, dot.action);
    });

    html.querySelector("#player").onClick.listen((e) {
      local.world.stop();
      setupPanel(sprite, sprite.action);
    });

    html.querySelector("#arena").onClick.listen((e) {
      local.world.stop();
      setupPanel(arena, arena.arena.action);
    });

    html.querySelector("#local").onClick.listen((e) {
      setupPanel(local, local.world.action);
      local.start();
      local.world.start();
    });

    html.querySelector("#net").onClick.listen((e) {
      local.world.stop();
      setupPanel(net, net.action);
    });
  });
}