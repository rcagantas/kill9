import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:http_server/http_server.dart';
import 'package:giggl/gglworld.dart';
import 'package:giggl/gglcommon.dart';


class K9Server {
  String address;
  num port, wsport;
  Map<num, WebSocket> sockets = new Map<num, WebSocket>();
  Map<WebSocket, Function> actionHandlers = new Map<WebSocket, Function>();

  List<World> worlds = [];
  num worldWidth = 20, worldHeight = 20;

  K9Server(this.address, num port, num wsport) {

    // setup to handle static files
    // you need to do a "pub build" first to compile the app to javascript
    String pathToBuild = join(dirname(Platform.script.toFilePath()), "../build/web");
    print("serving $pathToBuild");
    VirtualDirectory staticFiles = new VirtualDirectory(pathToBuild);
    staticFiles.allowDirectoryListing = true;

    // serve static files
    HttpServer
      .bind(InternetAddress.LOOPBACK_IP_V4, port)
      .then((server) {
        server.listen(staticFiles.serveRequest);
    });

    // handle websocket requests
    HttpServer
      .bind(InternetAddress.LOOPBACK_IP_V4, wsport)
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
        actionHandlers[websocket](new CmdOld.fromString(e));
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
  new K9Server("127.0.0.1", 1024, 1025);
}
