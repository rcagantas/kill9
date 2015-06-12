import 'dart:io';
/*
import 'dart:convert';
import 'package:path/path.dart';
import 'package:http_server/http_server.dart';
import 'package:giggl/gglcommon.dart';*/
import 'package:giggl/gglworld.dart';

class ServerMain {
  List<World> worlds = [];

  Map<num, WebSocket> sockets = new Map<num, WebSocket>();

  ServerMain() {
    HttpServer
      .bind(InternetAddress.LOOPBACK_IP_V4, 1025)
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

  void _listener(WebSocket ws) {
    ws.listen((e) {
    });
  }
}

void main() {

}