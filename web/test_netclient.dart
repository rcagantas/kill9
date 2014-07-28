import 'dart:html' as html;
import 'package:giggl/gglclient.dart';
import 'package:giggl/gglcommon.dart';

var dbg = html.querySelector('#dbg_text');
Arena arena;
NetClient client;
Map<int, PlayerSprite> players = new Map();
Map<int, BulletSprite> bullets = new Map();


void main() {
  client = new NetClient("127.0.0.1", 1024);
  handleButtons();
  ResourceHandler.init();
  resMgr.load().then((_) {
    renderLoop.addStage(stage);
    arena = new Arena();
  });
}

void handleButtons() {
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
    dbg.innerHtml = "sending: ${e.target.value}</br>";
    client.socket.send("${e.target.value}");
    e.target.value = "";
  });
}

void botListener(html.MessageEvent event) {
  dbg.innerHtml = "${event.data}</br>";
}

void listener(html.MessageEvent event) {
  dbg.innerHtml = "${event.data}</br>";
  String s = event.data;
  if (s.startsWith(Comm.SURFACE)) {
    List<int> surface = client.decodeData(s);
    arena.createMap(20, 20, surface);
  } else if (s.startsWith(Comm.ACTORS)) {
    List<int> actorCodes = client.decodeData(s);
    for (int i in actorCodes) {
      PlayerSprite ps = new PlayerSprite()
        ..addTo(arena.playerPanel);
      players[i] = ps;
    }
  } else if (s.startsWith(Comm.BULLETS)) {
    List<int> bulletCodes = new List();
    for (int i in bulletCodes) {
      BulletSprite bs = new BulletSprite()
        ..addTo(arena.playerPanel);
      bullets[i] = bs;
    }
  }
}
