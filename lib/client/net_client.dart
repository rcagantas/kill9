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

  dynamic decodeData(String packet) {
    var data;
    if (packet.startsWith(Comm.SURFACE)) {
      data = packet.replaceAll(Comm.SURFACE, "");
    } else if (packet.startsWith(Comm.ACTORS)) {
      data = packet.replaceAll(Comm.ACTORS, "");
    } else if (packet.startsWith(Comm.FRAME)) {
      data = packet.replaceAll(Comm.FRAME, "");
    }
    return JSON.decode(data);
  }
}