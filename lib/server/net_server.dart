part of gglserver;

class NetServer {
  String address;
  int port;
  Function cbPlayerInput, cbAddPlayer;
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
      if (e == Comm.JOIN_RANDOM) {
        int i = cbAddPlayer();
        if (i == 0) return;
        players[i] = websocket;
      } else if (cbPlayerInput != null) {
        cbPlayerInput(e);
      }
    });
  }

  void send(int id, String data) {
    if (players.containsKey(id)) players[id].add(data);
  }
}

