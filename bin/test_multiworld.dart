import 'package:giggl/gglworld.dart';
import 'dart:io';
import 'package:giggl/gglcommon.dart';

class MultiNetServer {
  String address;
  int port;
  Function cbCreateCustom, cbJoinRandom, cbJoinCustom,
    cbGetGameId, cbFillBots;
  Map<int, WebSocket> players = new Map<int, WebSocket>();

  MultiNetServer(this.address, this.port) {
    HttpServer
      .bind(address, port)
      .then((server) {
        server.listen((HttpRequest request) {
          if (request.uri.path == "/ws") {
            WebSocketTransformer
              .upgrade(request)
              .then(_listener);
          }
        });
      });
  }

  void _listener(WebSocket websocket) {
    websocket.listen((e) {
      String d = e.toString();
      var s = d.split(":");
      var cmd = s.length == 2? s[0]: d;
      var param = s.length == 2? s[1] : "";
      print("cmd: ${cmd}; param: ${param}");
      switch (cmd + ":") {
        case Comm.JOIN_RANDOM: _callCb(cbJoinRandom, param, websocket); break;
        case Comm.JOIN_GAME: _callCb(cbJoinCustom, param, websocket); break;
        case Comm.CREATE_GAME: _callCb(cbCreateCustom, param, websocket); break;
        case Comm.FILL_BOTS: cbFillBots(param); break;
      }
    });
  }

  void _callCb(Function cb, dynamic param, WebSocket websocket) {
    if (cb == null) return;
    int i = cb(param);
    if (i == 0) players[i] = websocket;
    websocket.add("${Comm.GAME_ID}${cbGetGameId(i)}");
  }
}

World worldFactory(List<World> worlds) {
  num width = 20, height = 20;
  var surfaceList = MapGenerator.createSimpleRandomSurface(width, height);
  var grid = new Grid.surface(width, height, 100, surfaceList);
  World world = new World(grid);
  world.onReady = () {
    List<int> actorCodes = new List();
    List<int> bulletCodes = new List();
    for (Actor a in world.actors)
      actorCodes.add(a.hashCode);
    world.bullets.getBulletIter().forEach((id) {
      bulletCodes.add(id);
    });
  };
  print("world ${world.hashCode} is waiting for players.");
  worlds.add(world);
  return world;
}

void main() {
  MultiNetServer mnet;
  List<World> worlds = [];

  World randomWorld = worldFactory(worlds);
  mnet = new MultiNetServer("127.0.0.1", 1024);
  mnet.cbJoinRandom = (e) { return randomWorld.addPlayer(); };
  mnet.cbJoinCustom = (gameId) {
    for (World world in worlds) {
      if (world.hashCode == gameId) {
        return world.addPlayer();
      }
      return 0;
    }
  };
  mnet.cbCreateCustom = (e) {
    var world = worldFactory(worlds);
    return world.addPlayer();
  };
  mnet.cbGetGameId = (e) {
    for (World w in worlds) {
       for (Actor a in w.actors) {
         if (a.hashCode == e)
           return w.hashCode;
       }
    }
    return 0;
  };
  mnet.cbFillBots = (e) {
    for (World w in worlds) {
      if (w.hashCode == int.parse(e)) {
        while (w.actors.length < 10) {
          Actor a = w.addPlayerandGetReference();
          RandomWalker walker = new RandomWalker(a);
          walker.start();
        }
      }
    }
  };
}