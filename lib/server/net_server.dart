part of gglserver;

class MultiNetServer {
  String address;
  int port;
  Function cbCreateCustom, cbJoinRandom,
      cbJoinCustom, cbFillBots,
      cbInput, cbPlayerName;
  Map<int, WebSocket> players = new Map<int, WebSocket>();

  MultiNetServer(this.address, this.port) {
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
      //print("cmd: ${cmd}; param: ${param}");
      switch (cmd + ":") {
        case Comm.INPUT: if (cbInput != null) cbInput(param); break;
        case Comm.JOIN_RANDOM: _callCbJoin(cbJoinRandom, param, websocket); break;
        case Comm.JOIN_GAME: _callCbJoin(cbJoinCustom, param, websocket); break;
        case Comm.CREATE_GAME: _callCbJoin(cbCreateCustom, param, websocket); break;
        case Comm.FILL_BOTS:
          if (cbFillBots == null) break;
          for (int i in players.keys) {
            if (players[i] == websocket)
              cbFillBots(i);
          }
          break;
        case Comm.PLAYER_NAME:
          if (cbPlayerName == null) return;
          for (int i in players.keys) {
            if (players[i] == websocket)
              cbPlayerName(i, param);
          }
          break;
      }
    });
  }

  void _callCbJoin(Function cb, dynamic param, WebSocket websocket) {
    if (cb == null) return;
    // don't process players who are already in a game.
    for (WebSocket w in players.values) {
      if (w == websocket) return;
    }
    int i = cb(param);
    if (i != 0) players[i] = websocket;
  }

  void send(int id, String data) {
    if (players.containsKey(id))
      players[id].add(data);
  }
}

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

