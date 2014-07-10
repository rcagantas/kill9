import 'dart:io';
import 'dart:async';
//import 'dart:math';

class NetServer {
  String _hostname;
  int _port;
  var _serverListener;
  var _serverWriter;
  Map<int,WebSocket> _mapClients = new Map();
  Timer pinger = null; 
  
  NetServer(String hostname, int port, var addClient, var serverListener, var serverWriter) {
    _hostname = hostname;
    _port = port;
    _serverListener = serverListener;
    _serverWriter = serverWriter;
    
    // each Game server starts a new Host
    HttpServer
      .bind(hostname, port)
      .then((server) {
        server.listen((req) {
          if (req.uri.path == '/ws') {
            WebSocketTransformer.upgrade(req).then((websocket) {
              // getId for client and add to map
              int clientId = addClient();
              _mapClients[clientId] = websocket;
              
              _mapClients[clientId].listen(_readMessage);
              
              // inform client of its clientId
              String msg = 'clientId=$clientId';
              _mapClients[clientId].add(msg);
            });
          }
        });
      });
      // add catchError!
    
      // ticker to writeout message, every duration tick
      if (pinger == null) {
        pinger = new Timer(new Duration(seconds: 10), _writeMessage);
      }
  }
  
  void _readMessage(String msg) {
    // do parsing and pass to callback function
    //_serverListener(data);
    
    print('debug received $msg');
  }
  
  void send(int clientId, var data) {
    //convert data to String
    //_writeMessage(_mapClients[clientId], msg);
  }
  
  void _writeMessage() {
    // Loop thru all clients, and try to send a data
    //_serverWriter(data)
    //_mapClients[clientId].add(msg);
    
    _mapClients.forEach((clientId,socket) {
      //String msg = _serverWriter(clientId);
      String msg = 'hello $clientId';
      _mapClients[clientId].add(msg);
      print('debug sending $msg');
    });
  }
}

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
