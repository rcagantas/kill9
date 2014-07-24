part of gglserver;

class NetServer {
  String address;
  int port;
  Function cbPlayerInput, cbAddPlayer, cbWorldId;
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
        int i = cbAddPlayer();
        if (i == 0) return;
        players[i] = websocket;
        send(i, CommRequest.GAME_ID + "${cbWorldId()}");
        send(i, CommRequest.PLAYER_ID + "${i}");
      } else if (cbPlayerInput != null) {
        cbPlayerInput(e);
      } else {
        print("$e");
      }
    });
  }

  void send(int id, String data) { players[id].add(data); }
}

