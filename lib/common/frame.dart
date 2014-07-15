part of gglcommon;

class ObjectInFrame {
  num id;
  num x,y,orientation;
}

class ActorInFrame extends ObjectInFrame {
  num lifeRatio;
  num weaponType;
  num weaponAmmo;
  num damageFrom;
  bool isFiring = false;
  bool isMoving = false;
}

class BulletInFrame extends ObjectInFrame {}

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
