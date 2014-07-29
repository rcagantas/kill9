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

  String toString() {
    var stringBuffer = new StringBuffer()
    ..write("$id,$x,$y,$orientation,")
    ..write("$lifeRatio,$weaponType,$weaponAmmo,$damageFrom,$isFiring,$isMoving");
    return stringBuffer.toString();
  }

  ActorInFrame() {

  }

  ActorInFrame.fromString(String s) {
    var fields = s.split(",");

    id = num.parse(fields[0]);
    x = num.parse(fields[1]);
    y = num.parse(fields[2]);;
    orientation = num.parse(fields[3]);
    lifeRatio = num.parse(fields[4]) ;
    weaponType = num.parse(fields[5]);
    weaponAmmo = num.parse(fields[6]);
    damageFrom = num.parse(fields[7]);
    isFiring = fields[8] == "true";
    isMoving = fields[9] == "true";
  }
}

class BulletInFrame extends ObjectInFrame {
  int type;
  bool hitObject = false;
  bool hitActor = false;
  bool timedOut = false;

  String toString() {
    var stringBuffer = new StringBuffer()
    ..write("$id,$x,$y,$orientation,")
    ..write("$type,$hitObject,$hitActor,$timedOut");
    return stringBuffer.toString();
  }

  BulletInFrame() {

  }

  BulletInFrame.fromString(String s) {
    var fields = s.split(",");

    id = num.parse(fields[0]);
    x = num.parse(fields[1]);
    y = num.parse(fields[2]);;
    orientation = num.parse(fields[3]);
    type = int.parse(fields[4]);
    hitObject = fields[5] == "true";
    hitActor = fields[6] == "true";
    timedOut = fields[7] == "true";
  }
}

class Frame {
  int playerId;

  // Viewport
  num topX,topY;

  // Objects visible in the world
  List<ObjectInFrame> visibleObjects = new List();

  String toString() {
    var stringBuffer = new StringBuffer()
    ..write("$playerId,$topX,$topY")
    ..write("~");

    visibleObjects.forEach( (obj) {

      if (obj is ActorInFrame)
        stringBuffer.write("0#");
      else
        stringBuffer.write("1#");

      stringBuffer.write(obj.toString());
      stringBuffer.write("|");
    });

    return stringBuffer.toString();
  }

  Frame() {
  }

  Frame.fromString(String s) {
    var main = s.split("~");

    var fields = main[0].split(",");

    playerId = int.parse(fields[0]);
    topX = num.parse(fields[1]);
    topY = num.parse(fields[2]);

    var objects = main[1].split("|");

    objects.forEach( (str) {
      if (str == "") return;

      var obj = str.split("#");
      if (obj[0] == "0")
        visibleObjects.add(new ActorInFrame.fromString(obj[1]));
      else
        visibleObjects.add(new BulletInFrame.fromString(obj[1]));
    });

  }
}

class CommandFrame {
  int playerId, moveX, moveY;
  bool fire, weaponCycle;
}
