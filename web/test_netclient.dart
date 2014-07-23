import 'dart:html' as html;
import 'package:giggl/gglclient.dart';

var text = html.querySelector('#text');

void main() {
  NetClient client = new NetClient("127.0.0.1", 1024);
  client.socket.onMessage.listen(updateMessage);
  client.socket.onError.listen(errorMessage);

  html.querySelector("#create_bot").onClick.listen((e) {
    NetClient client = new NetClient("127.0.0.1", 1024);
    client.socket.onMessage.listen(updateMessage);
  });

  html.querySelector("#text_data").onKeyDown.listen((e) {
    if (e.keyCode != 13) return;
    text.innerHtml += "sending: ${e.target.value}</br>";
    client.socket.send("${e.target.value}");
  });
}

void updateMessage(html.MessageEvent event) {
  text.innerHtml += "${event.data}</br>";
}

void errorMessage(html.Event event) {
  text.innerHtml += "error on connection. </br>";
}