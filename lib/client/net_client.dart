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
    socket.send(CommRequest.JOIN_RANDOM);
  }

  void joinCustomGame(int gameId) {
    socket.send(CommRequest.JOIN_GAME + "${gameId}");
  }

  void onData(html.MessageEvent event) {
    String message = event.data;
    if (message.startsWith(CommRequest.GAME_ID) && gameId == 0) {
      gameId = int.parse(message.replaceFirst(CommRequest.GAME_ID, ""));
    }
  }
}