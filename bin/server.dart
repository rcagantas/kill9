import 'package:giggl/gglserver.dart';
int index = 0;

// debugging only
void main() {
  NetServer gs1 = new NetServer('127.0.0.1', 1024, addPlayer, serverListener, serverWriter);
  //GameServer gs2 = new GameServer('127.0.0.1', 1025, addPlayer, serverListener, serverWriter);
}

int addPlayer() {
  return ++index;
}

void serverListener() {
}

String serverWriter() {
  return 'test';
}