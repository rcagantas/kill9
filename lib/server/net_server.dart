part of gglserver;

class NetServer {
  String address;
  int port;
  Function playerInput, callRandomLobby;
  Map<int, WebSocket> players = new Map();

  NetServer(this.address, this.port) {
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
      if (e == CommRequest.JOIN_RANDOM) {
        callRandomLobby(websocket);
      } else if (playerInput != null) {
        playerInput(e);
      } else {
        print("$e");
      }
    });
  }

  void send(int id, String data) { players[id].add(data); }
}

