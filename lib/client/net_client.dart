part of gglclient;

class NetClient {
  html.WebSocket socket;
  String uri;
  int port;
  int gameId = 0;

  NetClient(this.uri, this.port) {
    socket = new html.WebSocket("ws://${uri}:${port}/ws");
    socket.onMessage.listen(onData);
  }

  void joinRandomGame() {
    if (gameId == 0)
    socket.send(Comm.JOIN_RANDOM);
  }

  void joinCustomGame(int gameId) {
    socket.send(Comm.JOIN_GAME + "${gameId}");
  }

  void onData(html.MessageEvent event) {
    String s = event.data;
    if (s.startsWith(Comm.GAME_ID) && gameId == 0) {
      gameId = int.parse(s.replaceFirst(Comm.GAME_ID, ""));
    }
  }
}