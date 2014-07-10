import 'dart:html';

void main() {
  WebSocket socket = new WebSocket('ws://127.0.0.1:1024/ws');

  if (socket != null && socket.readyState == WebSocket.OPEN) {
    socket.send('connecting');
  }

  socket.onMessage.listen((e) => datareceived(e));
}

void datareceived(MessageEvent event) {
  querySelector("#txt1").text = event.data;
}