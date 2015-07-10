import 'dart:io';
import 'dart:async';
import 'package:giggl/gglcommon.dart';

import 'package:giggl/gglworld.dart';

List<World> worlds = new List<World>();
List<WebSocket> sockets = new List<WebSocket>();

void main() {
  num w = 20, h = 20;
  worlds.add(new World.size(w, h));

  runZoned(() async {
    var server = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 4040);
    await for (var req in server) {
      if (req.uri.path == '/ws') {
        //Upgrade HTTP request to a WebSocket connection.
        var socket = await WebSocketTransformer.upgrade(req);

        socket.listen((msg) {
          Cmd c = new Cmd.fromData(msg);
          c.id = socket.hashCode;



          if (!sockets.contains(socket)) {
            //esnd grid data;
          }
        });
      }
    }
  },
  onError: (e) => print("An error occur.")
  );
}