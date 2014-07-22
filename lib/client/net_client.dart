import 'dart:html';

class NetClient {
  WebSocket socket;
  String uri;
  int port;
  NetClient(this.uri, this.port) {
    socket = new WebSocket("ws://${uri}:${port}/ws");
  }

  void send(String message) {
    if (socket == null ||
        socket.readyState != WebSocket.OPEN) {
      return;
    }
    socket.send(message);
  }
}