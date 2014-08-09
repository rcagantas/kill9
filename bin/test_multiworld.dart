import 'package:giggl/gglworld.dart';
import 'dart:io';
import 'package:giggl/gglcommon.dart';
import 'dart:convert';

class MultiNetServer {
  String address;
  int port;
  Function cbCreateCustom, cbJoinRandom,
      cbJoinCustom, cbFillBots,
      cbInput;
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
      //print("cmd: ${cmd}; param: ${param}");
      switch (cmd + ":") {
        case Comm.INPUT: if (cbInput != null) cbInput(param); break;
        case Comm.JOIN_RANDOM: _callCbJoin(cbJoinRandom, param, websocket); break;
        case Comm.JOIN_GAME: _callCbJoin(cbJoinCustom, param, websocket); break;
        case Comm.CREATE_GAME: _callCbJoin(cbCreateCustom, param, websocket); break;
        case Comm.FILL_BOTS:
          for (int i in players.keys) {
            if (players[i] == websocket) {
              cbFillBots(i);
            }
          }
          break;
      }
    });
  }

  void _callCbJoin(Function cb, dynamic param, WebSocket websocket) {
    if (cb == null) return;
    // don't process players who are already in a game.
    for (WebSocket w in players.values) {
      if (w == websocket) return;
    }
    int i = cb(param);
    if (i != 0) players[i] = websocket;
  }

  void send(int id, String data) {
    if (players.containsKey(id))
      players[id].add(data);
  }
}

World worldFactory(List<World> worlds, MultiNetServer mnet) {
  num width = 20, height = 20;
  var surfaceList = MapGenerator.createSimpleRandomSurface(width, height);
  var grid = new Grid.surface(width, height, 100, surfaceList);
  World world = new World(grid);
  print("world ${world.hashCode} is waiting for players.");
  world.onReady = () {
    List<int> actorCodes = new List();
    List<int> bulletCodes = new List();
    for (Actor a in world.actors)
      actorCodes.add(a.hashCode);
    world.bullets.getBulletIter().forEach((id) {
      bulletCodes.add(id);
    });

    for (Actor a in world.actors) {
      // send player id
      mnet.send(a.hashCode, Comm.PLAYER_ID + JSON.encode(a.hashCode));
      // 1. publish map detail to client
      mnet.send(a.hashCode, Comm.SURFACE + JSON.encode(world.grid.surfaceList));
      // 2. publish all object ids to client (players/bullets/etc)
      mnet.send(a.hashCode, Comm.ACTORS + JSON.encode(actorCodes));
      mnet.send(a.hashCode, Comm.BULLETS + JSON.encode(bulletCodes));
      // 3. register the frame listener for each player
      world.addPlayerFrameListener(a.hashCode, (Frame p) {
        num id = p.playerId;
        // compress p and send to client;
        mnet.send(id, Comm.FRAME + JSON.encode(p.toString()));
      });
    }

    world.start();
    print("startin world ${world.hashCode}");

    for (Actor a in world.actors) {
      // if actor is not a player, must be a bot.
      if (!mnet.players.keys.contains(a.hashCode)) {
        RandomWalker walker = new RandomWalker(a);
        walker.start();
      }
    }
  };
  worlds.add(world);
  return world;
}

void main() {
  MultiNetServer mnet;
  World randomWorld;
  List<World> worlds = [];

  mnet = new MultiNetServer("127.0.0.1", 1024);

  mnet.cbJoinRandom = (e) {
    if (randomWorld == null ||
        randomWorld.actors.length == World.MAX_PLAYERS) {
      randomWorld = worldFactory(worlds, mnet);
      print("new world");
    }
    return randomWorld.addPlayer();
  };

  mnet.cbJoinCustom = (gameId) {
    for (World world in worlds) {
      if (world.hashCode == gameId) {
        return world.addPlayer();
      }
      return 0;
    }
  };

  mnet.cbCreateCustom = (e) {
    var world = worldFactory(worlds, mnet);
    return world.addPlayer();
  };

  mnet.cbFillBots = (playerId) {
    for (World w in worlds) {
      for (Actor a in w.actors) {
        if (a.hashCode == playerId) {
          while (w.actors.length < World.MAX_PLAYERS) {
            Actor a = w.addPlayerandGetReference();
          }
          return;
        }
      }
    }
  };

  mnet.cbInput = (data) {
    CommandFrame cf = new CommandFrame.fromString(data);
    for (World world in worlds) {
      for (Actor a in world.actors) {
        if (cf.id == a.hashCode) {
          if (cf.moveX == -1) a.moveLeft();
          else if (cf.moveX == 1) a.moveRight();
          else if (cf.moveX == 0) a.stopLeftRightMove();

          if (cf.moveY == -1) a.moveUp();
          else if (cf.moveY == 1) a.moveDown();
          else a.stopTopDownMove();

          if (cf.orientation == -1) a.turnCounterClockwise();
          else if (cf.orientation == 1) a.turnClockwise();
          else a.stopTurn();

          if (cf.mouseMoved)
            a.turnToPoint(cf.mouseX, cf.mouseY);

          if (cf.fire) a.weapon.fire();
          else a.weapon.stop();

          if (cf.weaponCycle) a.switchWeapon();
        }
      }
    }
  };
}