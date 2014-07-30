import 'package:giggl/gglworld.dart';
import 'package:giggl/gglcommon.dart';
import 'package:giggl/gglserver.dart';
import 'dart:convert';

NetServer net;

void main() {
  // STEP 1: Wait for connection
  net = new NetServer("127.0.0.1", 1024);

  // create world
  num width = 20, height = 20;
  var surfaceList = MapGenerator.createSimpleRandomSurface(width, height);
  var grid = new Grid.surface(width, height, 100, surfaceList);
  var world = new World(grid);

  print("waiting for players");
  net.cbWorldId = () { return world.hashCode; };
  net.cbAddPlayer = () { return world.addPlayer(); };
  bool started = false;
  world.onReady = () {
    if (started) return;
    List<int> actorCodes = new List();
    List<int> bulletCodes = new List();
    for (Actor a in world.actors)
      actorCodes.add(a.hashCode);
    world.bullets.getBulletIter().forEach((id) {
      bulletCodes.add(id);
    });

    // STEP 2: Publish initializing data to client
    for (Actor a in world.actors) {
      // send player id
      net.send(a.hashCode, Comm.PLAYER_ID + JSON.encode(a.hashCode));
      // 1. publish map detail to client
      net.send(a.hashCode, Comm.SURFACE + JSON.encode(surfaceList));
      // 2. publish all object ids to client (players/bullets/etc)
      net.send(a.hashCode, Comm.ACTORS + JSON.encode(actorCodes));
      net.send(a.hashCode, Comm.BULLETS + JSON.encode(bulletCodes));
      // 3. register the frame listener for each player
      world.addPlayerFrameListener(a.hashCode, framePublisher);
    }
    // at this point everyone is connected;
    started = true;
    // STEP 3: Start game
    world.start();
  };
}

// this is a reference function for the frame publishing call back
void framePublisher (Frame p) {
  num id = p.playerId;
  // compress p and send to client;
  net.send(id, Comm.FRAME + JSON.encode(p.toString()));
}