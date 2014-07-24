import 'package:giggl/gglworld.dart';
import 'package:giggl/gglcommon.dart';
import 'package:giggl/gglserver.dart';

void main() {
  // STEP 1: Wait for connection
  NetServer net = new NetServer("127.0.0.1", 1024);

  // create world
  num width = 20, height = 20;
  var surfaceList = MapGenerator.createSimpleRandomSurface(width, height);
  var grid = new Grid.surface(width, height, 100, surfaceList);
  var world = new World(grid);

  print("waiting for players");
  net.cbWorldId = () { return world.hashCode; };
  net.cbAddPlayer = () { return world.addPlayer(); };

  // STEP 2: Publish initializing data to client
  // 1. publish map detail to client
  // 2. publish all object ids to client (players/bullets/etc)

  // at this point everyone is connected;

  // STEP 3: Start game

  // register the frame listener for each player
  // for each playerId of all clients {
      //world.addPlayerFrameListener(playerId, framePublisher);
  // }

  // return id to Player;
}

// this is a reference function for the frame publishing call back
void framePublisher (Frame p) {

  // p.playerId == client ID
  // compress p and send to client;

}