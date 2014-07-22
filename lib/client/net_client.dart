part of gglclient;

class NetClient {
  html.WebSocket socket;
  String uri;
  int port;
  NetClient(this.uri, this.port) {
    socket = new html.WebSocket("ws://${uri}:${port}/ws");
  }

  void send(String message) {
    if (socket == null ||
        socket.readyState != html.WebSocket.OPEN) {
      return;
    }
    socket.send(message);
  }
}