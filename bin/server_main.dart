import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:giggl/gglcommon.dart';
import 'package:giggl/gglworld.dart';

List<World> worlds = new List<World>();
List<WebSocket> sockets = new List<WebSocket>();
num w = 20, h = 20;

void insertPlayer(World world, WebSocket socket) {
  socket.add(JSON.encode(world.grid.surfaceList));

  Actor a = world.addPlayerAndGetReference();
  world.addPlayerFrameListener(a.hashCode, (Frame pf) {
    socket.add(pf.toString());
  });

  // make world respond to player action
  // but map socket id to actor id first
  socket.listen((msg) {
    Cmd c = new Cmd.fromData(msg);
    c.id = a.hashCode;
    world.action2(c);
  }, onDone: () {
    print("[server] ${socket.hashCode} disconnected.");
    world.removeActorAndReplaceWithBot(a);
  });
}

void handleWebSocket(WebSocket socket) {
  
  if (!sockets.contains(socket)) {
    sockets.add(socket);
    print("[server] attempt to add socket ${socket.hashCode}");

    World worldWithSpace = null;
    // search for an available world
    worlds.forEach((world) {
      // check if we have space for player in world
      if (world.hasSpace()) {
        worldWithSpace = world;
      }
    });
    if (worldWithSpace == null) {
      worlds.add(new World.size(w, h));
      worlds.last.start();
      worldWithSpace = worlds.last;
      print("[server] created new world");
    }
    insertPlayer(worldWithSpace, socket);
  }
}

void main() {
  worlds.add(new World.size(w, h));

  runZoned(() async {
    var server = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 4040);
    await for (var req in server) {
      if (req.uri.path == '/ws') {
        //Upgrade HTTP request to a WebSocket connection.
        var socket = await WebSocketTransformer.upgrade(req);
        handleWebSocket(socket);
      }
    }
  },
  onError: (e) => print("[server] error occurred on async handWebSocket. ${e.toString()}")
  );
}
