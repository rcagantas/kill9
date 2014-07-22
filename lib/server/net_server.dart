part of gglserver;

class NetServer {
  String address;
  int port;
  Function addClient, readyCallback, playerInput;
  Map<int, WebSocket> players = new Map();

  NetServer(this.address, this.port, this.addClient, this.readyCallback) {
    HttpServer
      .bind(address, port)
      .then((server) {
        server.listen((HttpRequest request) {
          if (request.uri.path == "/ws") {
            WebSocketTransformer
              .upgrade(request)
              .then(_addPlayer);
          }
        });
    });
  }

  void _addPlayer(WebSocket websocket) {
    if (addClient == null || readyCallback == null) return;
    if (players.length == 10) return;
    int id = addClient();
    players[id] = websocket;
    websocket.listen(receive);
    websocket.add("id: ${id}");
    if (players.length == 10) readyCallback();
  }

  void send(int id, String data) { players[id].add(data); }
  void receive(String data) {
    if (playerInput != null) playerInput(data);
    print("$data");
  }
}

