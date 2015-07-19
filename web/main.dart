import 'dart:html' as html;
import 'dart:async';
import 'dart:convert';
import 'package:stagexl/stagexl.dart';
import 'package:giggl/gglclient2.dart';
import 'package:giggl/gglcommon.dart';

String hostname = "127.0.0,1";

class GameClient extends DisplayObjectContainer {
  html.WebSocket ws;
  Arena arena;
  HudLayer hud;
  bool reconnecting = false;
  bool connected = false;
  String name = "";

  GameClient() {
    initWebSocket();
  }

  void initWebSocket() {
    ws = new html.WebSocket("ws://" + hostname + ":4040/ws");
    ws.onOpen.listen((e) { connected = true; });
    ws.onClose.listen((e) { tryReconnect(); });
    ws.onError.listen((e) { tryReconnect(); });
    ws.onMessage.listen((e) {
      if (!connected) return;
      if (arena == null) {
        num w = 20, h = 20;
        List<num> grid = JSON.decode(e.data);
        arena = new Arena(w, h, grid)..addTo(this);
        hud = new HudLayer(w, h, grid)..addTo(this);
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
    c.id = c.hashCode;
    c.name = name == ""? "${ws.hashCode}" : name;
    if (ws != null && ws.readyState == html.WebSocket.OPEN) {
      ws.send(c.toData());
    }
  }
  
  void nameUpdateHandler(html.Event e) {
    name = (e.target as html.InputElement).value;
    print("setting name to $name");
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
    stages.putIfAbsent("socket", () { return new GameClient(); });
    setupStage(stages, "socket");
    html.querySelector('#inputName').onInput.listen(stages["socket"].nameUpdateHandler);
  });
}
