import 'dart:html' as html;
import 'package:giggl/gglclient.dart';
import 'package:giggl/gglcommon.dart';
import 'dart:convert';

var dbg = html.querySelector('#dbg_text');
Arena arena;

void main() {
  NetClient client = new NetClient("127.0.0.1", 1024);
  client.socket.onMessage.listen(listener);
  client.socket.onError.listen((e) => dbg.innerHtml = "error on connection.");

  html.querySelector("#join_game").onClick.listen((e) {
    client.joinRandomGame();
  });

  html.querySelector("#create_bot").onClick.listen((e) {
    NetClient client = new NetClient("127.0.0.1", 1024);
    client.socket.onOpen.listen((e) {
      client.joinRandomGame();
      client.socket.onMessage.listen(botListener);
    });
  });

  html.querySelector("#text_data").onKeyDown.listen((e) {
    if (e.keyCode != 13) return;
    dbg.innerHtml += "sending: ${e.target.value}</br>";
    client.socket.send("${e.target.value}");
  });

  ResourceHandler.init();
  resMgr.load().then((_) {
    renderLoop.addStage(stage);
    arena = new Arena();
  });
}

void botListener(html.MessageEvent event) {
  dbg.innerHtml = "${event.data}</br>";
}

void listener(html.MessageEvent event) {
  dbg.innerHtml = "${event.data}</br>";
  String s = event.data;
  if (s.startsWith(Comm.SURFACE)) {
    var str = s.replaceAll(Comm.SURFACE, "");
    List<int> surface = JSON.decode(str);
    arena.createMap(20, 20, surface);
  }
}
