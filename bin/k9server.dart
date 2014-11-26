import 'dart:io';
import 'package:giggl/gglworld.dart';
import 'dart:convert';
import 'package:giggl/gglcommon.dart';

class K9Server {
  String address;
  num port;
  Map<num, WebSocket> sockets = new Map<num, WebSocket>();
  Map<WebSocket, Function> actionHandlers = new Map<WebSocket, Function>();

  List<World> worlds = [];
  num worldWidth = 20, worldHeight = 20;

  K9Server(this.address, num port) {
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

    worlds.add(new World.size(worldWidth, worldHeight));
  }

  void _listener(WebSocket websocket) {
    websocket.listen((e) {
      if (worlds.last.actors == World.MAX_PLAYERS)
        worlds.add(new World.size(worldWidth, worldHeight));

      if (sockets.containsValue(websocket)) {
        actionHandlers[websocket](new Cmd.fromString(e));
      } else {
        Actor a = worlds.last.addPlayerandGetReference();
        sockets[a.hashCode] = websocket;
        sockets[a.hashCode].add(JSON.encode(worlds.last.grid.surfaceList));
        actionHandlers[websocket] = worlds.last.action;
        worlds.last.addPlayerFrameListener(a.hashCode, (Frame f) {
          sockets[a.hashCode].add(f.toString());
        });
      }
    });
  }
}

void main() {
  new K9Server("127.0.0.1", 1024);
}
