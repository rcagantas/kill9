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
      String d = e.toString();
      var s = d.split(":");
      var cmd = s.length == 2? s[0]: d;
      var param = s.length == 2? s[1] : "";

      switch(cmd + ":") {
        case Comm.JOIN_RANDOM:
          int i = cbAddPlayer();
          if (i == 0) return;
          players[i] = websocket;
          break;
        case Comm.FILL_BOTS:
        case Comm.INPUT:
          if (cbPlayerInput != null) cbPlayerInput(e);
          break;
        default:
          print("unhandled ${cmd} ${param}");
      }
    });
  }

  void send(int id, String data) {
    if (players.containsKey(id)) players[id].add(data);
  }
}

