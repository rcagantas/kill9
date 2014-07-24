import 'dart:html' as html;
import 'package:giggl/gglclient.dart';

var dbg = html.querySelector('#dbg_text');

void main() {
  NetClient client = new NetClient("127.0.0.1", 1024);
  client.socket.onMessage.listen(appendDebug);
  client.socket.onError.listen((e) => dbg.innerHtml = "error on connection.");

  html.querySelector("#join_game").onClick.listen((e) {
    client.joinRandomGame();
  });

  html.querySelector("#create_bot").onClick.listen((e) {
    NetClient client = new NetClient("127.0.0.1", 1024);
    client.socket.onOpen.listen((e) {
      client.joinRandomGame();
      client.socket.onMessage.listen(appendDebug);
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
    Arena arena = new Arena();
  });
}

void appendDebug(html.MessageEvent event) {
  dbg.innerHtml += "${event.data}</br>";
}
