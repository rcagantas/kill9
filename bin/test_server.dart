import 'package:giggl/gglserver.dart';

void main() {


  // ideally, grid should be instantiated by the procedural
  // map generator
  var grid = new Grid (20,20,100);


  var world = new World(grid);

  // STEP 1: Wait for connection

  // while (connection is less than 10 players) {
  //  wait for request..
  //  got request?
      int playerId = world.addPlayer();
  //  return playerId to client
  // }

  // at this point everyone is connected;

  // STEP 2: Publish initializing data to client

  // 1. publish map detail to client
  // 2. publish all object ids to client (players/bullets/etc)


  // STEP 3: Start game

  // register the frame listener for each player

  // for each playerId of all clients {
      world.addPlayerFrameListener(playerId, framePublisher);
  // }

  // return id to Player;

}


void framePublisher (Frame p) {
  // this is a reference function for the frame publishing call back

  // p.playerId == client ID
  // compress p and send to client;

}