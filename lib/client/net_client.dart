part of gglclient;

class NetClient {
  html.WebSocket socket;
  String uri;
  int port;

  NetClient(this.uri, this.port) {
    socket = new html.WebSocket("ws://${uri}:${port}/ws");
    socket.onMessage.listen(onData);
  }

  void joinRandomGame(String playerName) {
    if (playerName != "") {
      socket.send(Comm.JOIN_RANDOM);
      socket.send(Comm.PLAYER_NAME + "${playerName}");
    }
  }

  void joinCustomGame(int gameId) {
    socket.send(Comm.JOIN_GAME + "${gameId}");
  }

  void onData(html.MessageEvent event) {
    String s = event.data;
  }
}