part of gglcommon;

class ObjectInFrame {
  num id;
  num objectType;
  num objectState;
  num x,y,orientation;
}

class ActorInFrame extends ObjectInFrame {
  num life;
  num weaponType;
  num weaponAmmo;
  num damageFrom;
}

class BulletInFrame extends ObjectInFrame {
  bool hitObject;
  bool hitPlayer;
}

class Frame {
  int playerId;

  // Viewport
  num topX,topY;

  // Objects visible in the world
  List<ObjectInFrame> visibleObjects = new List();

  String toString() {
    var stringBuffer = new StringBuffer()
    ..write("PlayerId: $playerId topX: $topX topY $topY");
    return stringBuffer.toString();
  }
}
