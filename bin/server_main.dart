import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:giggl/gglcommon.dart';
import 'package:giggl/gglworld.dart';
import 'package:http_server/http_server.dart';

List<World> worlds = new List<World>();
List<WebSocket> sockets = new List<WebSocket>();

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
    print("[socket] attempt to add socket ${socket.hashCode}");

    World worldWithSpace = null;
    // search for an available world
    worlds.forEach((world) {
      // check if we have space for player in world
      if (world.hasSpace()) {
        worldWithSpace = world;
      }
    });
    if (worldWithSpace == null) {
      worlds.add(new World.size(Meta.w, Meta.h));
      worlds.last.start();
      worldWithSpace = worlds.last;
      print("[socket] created new world");
    }
    insertPlayer(worldWithSpace, socket);
  }
}

void main() {
  worlds.add(new World.size(Meta.w, Meta.h));
  
  var staticFiles = new VirtualDirectory("./build/web")
      ..allowDirectoryListing = true;
  
  runZoned(() {
      HttpServer.bind(Meta.host, Meta.httpPort).then((server) {
        print("[web] serving");
        server.listen(staticFiles.serveRequest);
      });
    },
    onError: (e, stackTrace) => print("$e $stackTrace")
  );

  runZoned(() async {
    var server = await HttpServer.bind(Meta.host, Meta.wsPort);
    await for (var req in server) {
      if (req.uri.path == '/ws') {
        //Upgrade HTTP request to a WebSocket connection.
        var socket = await WebSocketTransformer.upgrade(req);
        handleWebSocket(socket);
      }
    }
  },
  onError: (e, stackTrace) => print("[socket] websocket error. $e $stackTrace")
  );
}
