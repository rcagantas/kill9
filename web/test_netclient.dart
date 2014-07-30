import 'dart:html' as html;
import 'package:giggl/gglclient.dart';
import 'package:giggl/gglcommon.dart';
import 'dart:convert';

var dbg = html.querySelector('#dbg_text');
Arena arena;
InputHandler io;
NetClient net;
Map<int, PlayerSprite> players = new Map();
Map<int, BulletSprite> bullets = new Map();
List<int> visible = new List();
int id;

void main() {
  net = new NetClient("127.0.0.1", 1024);
  handleButtons();
  ResourceHandler.init();
  resMgr.load().then((_) {
    renderLoop.addStage(stage);
    arena = new Arena();
    io = new InputHandler();
    io.cbStateChange = (cf) {
      cf.id = id;
      net.socket.sendString(JSON.encode(cf.toString()));
    };
  });
}

void handleButtons() {
  net.socket.onMessage.listen(listener);
  net.socket.onError.listen((e) => dbg.innerHtml = "error on connection.");

  html.querySelector("#join_game").onClick.listen((e) {
    net.joinRandomGame();
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
    net.socket.send("${e.target.value}");
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
    List<int> surface = net.decodeData(s);
    arena.createMap(20, 20, surface);
  } else if (s.startsWith(Comm.ACTORS)) {
    List<int> actorCodes = net.decodeData(s);
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
  } else if (s.startsWith(Comm.FRAME)){
    Frame p = new Frame.fromString(net.decodeData(s));
    updateFrame(p);
  } else if (s.startsWith(Comm.PLAYER_ID)) {
    id = net.decodeData(s);
  }
}

void updateFrame(Frame p) {
  arena.move(-p.topX, -p.topY);
  visible.clear();

  p.visibleObjects.forEach((object) {
    if (players.containsKey(object.id)) {
      var player = players[object.id]
        ..move(object.x, object.y)
        ..turn(object.orientation)
        ..modHitPoints(object.lifeRatio, object.damageFrom)
        ..setWeapon(object.weaponType);
      if (!object.isMoving) player.stopMoving();
      if (object.isFiring) player.fire();
      visible.add(object.id);
    }
    else if (bullets.containsKey(object.id)) {
      bullets[object.id].type = object.type;
      bullets[object.id].x = object.x;
      bullets[object.id].y = object.y;
      bullets[object.id].rotation = object.orientation;
      if (object.hitObject) bullets[object.id].explode();
      visible.add(object.id);
    }
  });

  players.forEach((x,v) {
    v.visible = visible.contains(x);
  });

  bullets.forEach((x,v) {
    v.visible = visible.contains(x);
  });
}
