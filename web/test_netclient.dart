import 'dart:html' as html;
import 'package:giggl/gglclient.dart';

var text = html.querySelector('#text');

void main() {
  NetClient client = new NetClient("127.0.0.1", 1024);
  client.socket.onMessage.listen(updateMessage);
  client.socket.onError.listen(errorMessage);

  var addDummyBtn = html.querySelector("#addDummy");
  addDummyBtn.onClick.listen((event) {
    NetClient client = new NetClient("127.0.0.1", 1024);
    client.socket.onMessage.listen(updateMessage);
  });

  var sendDummyBtn = html.querySelector("#sendDummy");
  sendDummyBtn.onClick.listen((event) {
    text.innerHtml += "trying to send data</br>";
    client.socket.send("dummy data");
  });
}

void updateMessage(html.MessageEvent event) {
  text.innerHtml += "${event.data}</br>";
}

void errorMessage(html.Event event) {
  text.innerHtml += "error on connection. </br>";
}