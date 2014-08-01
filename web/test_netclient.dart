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
    io.cbStateChange = (CommandFrame cf) {
      if (id == null || players[id] == null) return;
      cf.id = id;
      cf.mouseX += players[id].x;
      cf.mouseY += players[id].y;
      net.socket.sendString(Comm.INPUT + cf.toString());
    };
  });
}

void handleButtons() {
  net.socket.onMessage.listen(listener);
  net.socket.onError.listen((e) => dbg.innerHtml = "error on connection.");

  html.querySelector("#join_game").onClick.listen((e) {
    net.joinRandomGame();
  });

  html.querySelector("#fill_bots").onClick.listen((e) {
    net.socket.send(Comm.FILL_BOTS);
  });

  html.querySelector("#text_data").onKeyDown.listen((e) {
    if (e.keyCode != 13) return;
    dbg.innerHtml = "sending: ${e.target.value}</br>";
    net.socket.send("${e.target.value}");
    e.target.value = "";
  });
}

void listener(html.MessageEvent event) {
  var s = event.data.toString().split(":");
  String cmd = s[0] + ":";
  String data = s[1];
  switch (cmd) {
    case Comm.SURFACE:
      List<int> surface = JSON.decode(data);
      arena.createMap(20, 20, surface);
      break;
    case Comm.ACTORS:
      List<int> actorCodes = JSON.decode(data);
      for (int i in actorCodes) {
        PlayerSprite ps = new PlayerSprite()
          ..addTo(arena.playerPanel);
        players[i] = ps;
      }
      break;
    case Comm.BULLETS:
      List<int> bulletCodes = JSON.decode(data);
      for (int i in bulletCodes) {
        BulletSprite bs = new BulletSprite()
          ..addTo(arena.playerPanel);
        bullets[i] = bs;
      }
      break;
    case Comm.FRAME:
      Frame p = new Frame.fromString(JSON.decode(data));
      updateFrame(p);
      break;
    case Comm.PLAYER_ID:
      id = JSON.decode(data);
      break;
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
