// Copyright (c) 2015, Roel Cagantas. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';
import 'package:stagexl/stagexl.dart';
import 'package:giggl/gglclient2.dart';
import 'package:giggl/gglcommon.dart';
import 'package:giggl/gglworld.dart';

class RedDot extends DisplayObjectContainer {
  Shape shape;

  RedDot() {
    shape = new Shape()
      ..x = stage.stageWidth/2
      ..y = stage.stageHeight/2
      ..graphics.ellipse(0, 0, 15, 20)
      ..graphics.fillColor(Color.Red);

    addChild(shape);

    TextFormat font = new TextFormat('Lato', 15, Color.Black);

    TextField tf = new TextField()
        ..defaultTextFormat = font
        ..width = 200
        ..height = 200
        ..x = shape.x
        ..y = shape.y
        ..text = "something"
        ..wordWrap = true;

    addChild(tf);
  }

  void action(Cmd c) {
    x += c.moveX * c.ms;
    y += c.moveY * c.ms;
    shape.rotation += c.moveR * c.tr;
  }
}

class TestSprite extends DisplayObjectContainer {
  PlayerSprite testSprite, testSprite2;

  TestSprite() {
    testSprite = new PlayerSprite(0);
    testSprite2 = new PlayerSprite(1);

    testSprite.pnlDead.addTo(this);
    testSprite2.pnlDead.addTo(this);

    testSprite.x = stage.stageWidth/2;
    testSprite.y = stage.stageHeight/2;
    testSprite2.x = stage.stageWidth/2;
    testSprite2.y = stage.stageHeight/2;
    testSprite.addTo(this);
    testSprite2.addTo(this);
  }

  void action(Cmd c) {
    testSprite.action(c);
    if (c.fire == 1) {
      testSprite2.takeDamage(testSprite2.hpRatio - 1, testSprite.rotation);
      testSprite2.move(testSprite2.x + 1, testSprite2.y, testSprite2.rotation);
    }
    if (input.key[82]) {
      testSprite2.hpRatio = 100;
      testSprite2.x = stage.stageWidth/2;
      testSprite2.y = stage.stageHeight/2;
    }
  }
}

class TestBullet extends DisplayObjectContainer {
  PlayerSprite testSprite;

  TestBullet() {
    testSprite = new PlayerSprite(0)
      ..x = stage.stageWidth/2
      ..y = stage.stageHeight/2 + 200
      ..addTo(this);
  }

  void action(Cmd c) {
    Cmd nc = new Cmd();
    nc.moveX = c.moveX;
    nc.fire = c.fire;
    nc.swap = c.swap;
    testSprite.action(nc);
    if (nc.fire == 1 && !testSprite.isFiring) {
      math.Random random = new math.Random();
      num sign = random.nextInt(2) == 0? -1 : 1;

      BulletSprite b = BulletPool.getFreeBullet()
        ..x = testSprite.x + (sign * random.nextInt(15))
        ..y = testSprite.y - 40
        ..setWeaponType(testSprite.currentWeapon)
        ..addTo(this);

      Tween t = new Tween(b, 1.0, TransitionFunction.linear)
        ..animate.y.to(10)
        ..onComplete = () {
          if (b.y < 11) b.collide();
          new Timer(new Duration(seconds: 1), () {
            BulletPool.returnBullet(b);
          });
        };
      stage.juggler.add(t);
    }
  }
}

class TestArena extends DisplayObjectContainer {
  Arena arena;
  PlayerSprite p;
  HudLayer hud;
  TestArena() {
    List<num> surface = MapGenerator.createSimpleRandomSurface(Meta.w, Meta.h);
    arena = new Arena(Meta.w, Meta.h, surface)..addTo(this);
    hud = new HudLayer(Meta.w, Meta.h, surface)..addTo(this);

    p = new PlayerSprite(0);
    p.x = stage.stageWidth/2;
    p.y = stage.stageHeight/2;
    arena.panel['player'].addChild(p);
  }

  void action(Cmd c) {
    arena.action(c);
    p.action(c);
    hud.miniMove(hud.miniMain, p.x, p.y);
  }
}

class TestLocalWorld extends DisplayObjectContainer {
  Arena arena;
  HudLayer hud;
  World world;
  Actor player1;

  TestLocalWorld() {
    world = new World.size(Meta.w, Meta.h);
    arena = new Arena(Meta.w, Meta.h, world.grid.surfaceList)..addTo(this);
    hud = new HudLayer(Meta.w, Meta.h, world.grid.surfaceList)..addTo(this);
    arena.hud = hud;
  }

  void action(Cmd c) {
    world.action2(c);
    if (input.key[32]) {
      if (player1 != null) return;
      player1 = world.addPlayerAndGetReference();
      c.id = player1.hashCode;
      c.name = "Player1";
      world.addPlayerFrameListener(c.id, arena.updateFrame);
    }
  }
}

class TestSocket extends DisplayObjectContainer {
  WebSocket ws;
  Arena arena;
  HudLayer hud;
  bool reconnecting = false;
  bool connected = false;

  TestSocket() {}

  void initWebSocket() {
    ws = new WebSocket("ws://${Meta.host}:${Meta.wsPort}/ws");
    ws.onOpen.listen((e) { connected = true; });
    ws.onClose.listen((e) { tryReconnect(); });
    ws.onError.listen((e) { tryReconnect(); });
    ws.onMessage.listen((e) {
      if (!connected) return;
      if (arena == null) {
        List<num> grid = JSON.decode(e.data);
        arena = new Arena(Meta.w, Meta.h, grid)..addTo(this);
        hud = new HudLayer(Meta.w, Meta.h, grid)..addTo(this);
      } else {
        Frame pf = new Frame.fromString(e.data);
        arena.updateFrame(pf);
        hud.updateFrame(pf);
      }
    });
    reconnecting = false;
    debugWindow.serverMessage = "connected.";
  }

  void tryReconnect() {
    connected = false;
    if (reconnecting) return;
    debugWindow.serverMessage = "reconnecting...";
    reconnecting = true;
    new Timer(new Duration(milliseconds: 1000), () => initWebSocket());
  }

  void action(Cmd c) {
    if (input.key[32]) {
      initWebSocket();
    }
    
    c.id = c.hashCode;
    c.name = "Socket Test";
    if (ws != null && ws.readyState == WebSocket.OPEN) {
      ws.send(c.toData());
    }
  }
}

void setupStage(Map stages, String s) {
  input.removeAllListeners();
  stage.removeChildren();
  stage.addChild(stages[s]);
  input.addListener(stages[s].action);
  stage.addChild(debugWindow);
}

void main() {
  //initialize global variables
  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  Map stages = new Map();

  resourceLoader.load();
  resource.load().then((_) {
    input.init();
    stages.putIfAbsent("red", () { return new RedDot(); });
    stages.putIfAbsent("player", () { return new TestSprite(); });
    stages.putIfAbsent("bullet", () { return new TestBullet(); });
    stages.putIfAbsent("arena", () { return new TestArena(); });
    stages.putIfAbsent("local", () { return new TestLocalWorld(); });
    stages.putIfAbsent("socket", () { return new TestSocket(); });

    setupStage(stages, "local");

    querySelector("#red").onClick.listen((e) { setupStage(stages, "red"); });
    querySelector("#player").onClick.listen((e) { setupStage(stages, "player"); });
    querySelector("#bullet").onClick.listen((e) { setupStage(stages, "bullet"); });
    querySelector("#arena").onClick.listen((e) { setupStage(stages, "arena"); });
    querySelector("#local").onClick.listen((e) { setupStage(stages, "local"); });
    querySelector("#socket").onClick.listen((e) { setupStage(stages, "socket"); });
  });
}
