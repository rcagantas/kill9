import 'dart:html' as html;
import 'dart:async';
import 'dart:convert';
import 'package:stagexl/stagexl.dart';
import 'package:giggl/gglclient2.dart';
import 'package:giggl/gglcommon.dart';

class GameClient extends DisplayObjectContainer {
  html.WebSocket ws;
  Arena arena;
  HudLayer hud;
  bool reconnecting = false;
  bool connected = false;
  String name = "";
  String chat = "";
  html.UListElement chatLogs = html.querySelector("#chatLog");

  GameClient() { 
    initWebSocket();
  }

  void initWebSocket() {
    ws = new html.WebSocket("ws://${Meta.host}:${Meta.wsPort}/ws");
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
        updateChatLogs(pf.chat);
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
    c.chat = chat.replaceAll(",", ";;;");
    if (ws != null && ws.readyState == html.WebSocket.OPEN) {
      ws.send(c.toData());
    }
    chat = "";
  }
  
  void nameUpdateHandler(html.Event e) {
    name = (e.target as html.InputElement).value;
    print("setting name to $name");
  }
  
  void sendChat(html.Event e) {
    html.InputElement elem = html.querySelector("#chat");
    chat = elem.value;
    elem.value = "";
  }
  
  void updateChatLogs(String chat) {
    if (chat.isEmpty) return;
    while (chatLogs.children.length >= 5) chatLogs.children.removeAt(0);
    html.LIElement entry = new html.LIElement();
    entry.text = chat;
    chatLogs.children.add(entry);
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
    html.querySelector("#inputName").onInput.listen(stages["socket"].nameUpdateHandler);
    html.querySelector("#chat").onChange.listen(stages["socket"].sendChat);
  });
}
