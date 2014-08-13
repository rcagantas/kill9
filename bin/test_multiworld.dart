import 'package:giggl/gglworld.dart';
import 'package:giggl/gglcommon.dart';
import 'package:giggl/gglserver.dart';
import 'dart:convert';

World worldFactory(List<World> worlds, MultiNetServer mnet) {
  num width = 20, height = 20;
  var surfaceList = MapGenerator.createSimpleRandomSurface(width, height);
  var grid = new Grid.surface(width, height, 100, surfaceList);
  World world = new World(grid);
  print("world ${world.hashCode} is waiting for players.");
  world.onReady = () {
    List<int> actorCodes = new List();
    List<int> bulletCodes = new List();
    for (Actor a in world.actors)
      actorCodes.add(a.hashCode);
    world.bullets.getBulletIter().forEach((id) {
      bulletCodes.add(id);
    });

    for (Actor a in world.actors) {
      mnet.send(a.hashCode, Comm.PLAYER_ID + JSON.encode(a.hashCode));
      mnet.send(a.hashCode, Comm.SURFACE + JSON.encode(world.grid.surfaceList));
      mnet.send(a.hashCode, Comm.ACTORS + JSON.encode(actorCodes));
      mnet.send(a.hashCode, Comm.BULLETS + JSON.encode(bulletCodes));
      world.addPlayerFrameListener(a.hashCode, (Frame p) {
        num id = p.playerId;
        mnet.send(id, Comm.FRAME + JSON.encode(p.toString()));
      });
    }

    world.start();
    print("starting world ${world.hashCode}");

    for (int i = 0; i < world.actors.length; i++) {
      Actor a = world.actors[i];
      if (!mnet.players.keys.contains(a.hashCode)) {
        RandomWalker walker = new RandomWalker(a);
        a.name = Bots.names[i];
        walker.start();
      }
    }
  };
  worlds.add(world);
  return world;
}

void main() {
  MultiNetServer mnet;
  World randomWorld;
  List<World> worlds = [];

  mnet = new MultiNetServer("127.0.0.1", 1024);

  mnet.cbJoinRandom = (e) {
    if (randomWorld == null ||
        randomWorld.actors.length == World.MAX_PLAYERS) {
      randomWorld = worldFactory(worlds, mnet);
      print("new world");
    }
    return randomWorld.addPlayer();
  };

  mnet.cbJoinCustom = (gameId) {
    for (World world in worlds) {
      if (world.hashCode == gameId) {
        return world.addPlayer();
      }
      return 0;
    }
  };

  mnet.cbCreateCustom = (e) {
    var world = worldFactory(worlds, mnet);
    return world.addPlayer();
  };

  mnet.cbFillBots = (playerId) {
    for (World w in worlds) {
      for (Actor a in w.actors) {
        if (a.hashCode == playerId) {
          while (w.actors.length < World.MAX_PLAYERS) {
            Actor a = w.addPlayerandGetReference();
          }
          return;
        }
      }
    }
  };

  mnet.cbPlayerName = (int playerId, String playerName) {
    for (World w in worlds) {
      for (Actor a in w.actors) {
        if (a.hashCode == playerId) {
          a.name = playerName;
        }
      }
    }
  };

  mnet.cbInput = (data) {
    CommandFrame cf = new CommandFrame.fromString(data);
    for (World world in worlds) {
      for (Actor a in world.actors) {
        if (cf.id == a.hashCode) {
          if (cf.moveX == -1) a.moveLeft();
          else if (cf.moveX == 1) a.moveRight();
          else if (cf.moveX == 0) a.stopLeftRightMove();

          if (cf.moveY == -1) a.moveUp();
          else if (cf.moveY == 1) a.moveDown();
          else a.stopTopDownMove();

          if (cf.orientation == -1) a.turnCounterClockwise();
          else if (cf.orientation == 1) a.turnClockwise();
          else a.stopTurn();

          if (cf.mouseMoved)
            a.turnToPoint(cf.mouseX, cf.mouseY);

          if (cf.fire) a.weapon.fire();
          else a.weapon.stop();

          if (cf.weaponCycle) a.switchWeapon();
        }
      }
    }
  };
}