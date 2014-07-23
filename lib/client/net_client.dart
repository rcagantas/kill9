part of gglclient;

class NetClient {
  html.WebSocket socket;
  String uri;
  int port;
  int gameId;

  NetClient(this.uri, this.port) {
    socket = new html.WebSocket("ws://${uri}:${port}/ws");
    socket.onMessage.listen(onData);
  }

  void joinRandomGame() {
    socket.send(CommRequest.JOIN_RANDOM);
  }

  void joinCustomGame(int gameId) {
    socket.send(CommRequest.JOIN_GAME + "${gameId}");
  }

  void onData(html.MessageEvent event) {
    String message = event.data;
    if (message.startsWith(CommRequest.GAME_ID)) {
      gameId = int.parse(message.replaceFirst(CommRequest.GAME_ID, ""));
    }
  }
}