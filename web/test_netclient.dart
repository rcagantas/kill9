import 'package:giggl/client/net_client.dart';
import 'dart:html' as html;

void main() {
  NetClient client = new NetClient("127.0.0.1", 1024);
  client.socket.onMessage.listen(updateMessage);
  client.socket.onError.listen(errorMessage);

  var button = html.querySelector("#addDummy");
  button.onClick.listen((event) {
    NetClient client = new NetClient("127.0.0.1", 1024);
    client.socket.onMessage.listen(updateMessage);
  });
}

void updateMessage(html.MessageEvent event) {
  var text = html.querySelector('#text');
  text.innerHtml += "${event.data}</br>";
}

void errorMessage(html.Event event) {
  var text = html.querySelector('#text');
  text.innerHtml += "error on connection. </br>";
}