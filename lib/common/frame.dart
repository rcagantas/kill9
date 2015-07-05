part of gglcommon;

class ObjectInFrame {
  num id;
  num x,y,orientation;
}

class WeaponDropInFrame extends ObjectInFrame {
  int weaponType;

  String toString() {
    var stringBuffer = new StringBuffer()
    ..write("$id,$x,$y,$orientation,")
    ..write("$weaponType");
    return stringBuffer.toString();
  }

  WeaponDropInFrame() {

  }

  WeaponDropInFrame.fromString(String s) {
    var fields = s.split(",");

    id = num.parse(fields[0]);
    x = num.parse(fields[1]);
    y = num.parse(fields[2]);;
    orientation = num.parse(fields[3]);
    weaponType = int.parse(fields[4]);
  }
}

class ActorInFrame extends ObjectInFrame {
  num lifeRatio;
  num weaponType;
  num weaponAmmo;
  num damageFrom;
  bool isFiring = false;
  bool isMoving = false;
  String name;
  num index;

  String toString() {
    var stringBuffer = new StringBuffer()
    ..write("$id,$x,$y,$orientation,")
    ..write("$lifeRatio,$weaponType,$weaponAmmo,$damageFrom,$isFiring,$isMoving,")
    ..write("$name,$index");
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
    isFiring = fields[9] == "true";
    isMoving = fields[10] == "true";
    name = fields[11];
    index = num.parse(fields[12]);
  }
}

class BulletInFrame extends ObjectInFrame {
  num type, owner;
  bool hitObject = false;
  bool hitActor = false;
  bool timedOut = false;

  String toString() {
    var stringBuffer = new StringBuffer()
    ..write("$id,$x,$y,$orientation,")
    ..write("$type,$hitObject,$hitActor,$timedOut,")
    ..write("$owner");
    return stringBuffer.toString();
  }

  BulletInFrame() {}

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
    owner = num.parse(fields[8]);
  }
}

class Frame {
  int playerId;

  // Viewport
  num topX,topY,time,kills;
  String stats = "";

  // Objects visible in the world
  List<ObjectInFrame> visibleObjects = new List();

  String toString() {
    var stringBuffer = new StringBuffer()
    ..write("$playerId,$topX,$topY,$time,$kills,$stats")
    ..write("~");

    stringBuffer.write("~");

    visibleObjects.forEach( (obj) {

      if (obj is ActorInFrame)
        stringBuffer.write("0#");
      else if (obj is BulletInFrame)
        stringBuffer.write("1#");
      else
        stringBuffer.write("2#");

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
    time = num.parse(fields[3]);
    kills = num.parse(fields[4]);
    stats = fields[5];

    var objects = main[2].split("|");

    objects.forEach( (str) {
      if (str == "") return;

      var obj = str.split("#");
      if (obj[0] == "0")
        visibleObjects.add(new ActorInFrame.fromString(obj[1]));
      else if(obj[0] == "1")
        visibleObjects.add(new BulletInFrame.fromString(obj[1]));
      else
        visibleObjects.add(new WeaponDropInFrame.fromString(obj[1]));
    });
  }
}

class Cmd {
  num id;
  num ms, tr, moveX, moveY, moveR, fire, swap, mouseX, mouseY;
  String name;

  Cmd() {
    ms = 5;
    tr = .10;
    moveX = moveY = moveR = fire = swap = swap = 0;
    mouseX = mouseY = -1;
  }

  String toString() {
    return "[X:$moveX,Y:$moveY,R:$moveR,F:$fire,S:$swap,MX:$mouseX,MR:$mouseY]";
  }

  String toData() {
    return "$moveX,$moveY,$moveR," +
        "$fire,$swap,$mouseX,$mouseY";
  }

  Cmd.fromData(String s) {
    //var fields = s.split(",");
  }
}

/*
class CommandFrame {
  int id = 0, moveX = 0, moveY = 0, orientation = 0;
  bool fire = false, weaponCycle = false, mouseMoved = false;
  num mouseX = 0.0, mouseY = 0.0;

  String toString() {
    var stringBuffer = new StringBuffer()
      ..write("$id,$moveX,$moveY,$orientation,")
      ..write("$fire,$weaponCycle,$mouseMoved,")
      ..write("$mouseX, $mouseY");
    return stringBuffer.toString();
  }

  CommandFrame() {}

  CommandFrame.fromString(String s) {
    var fields = s.split(",");
    if (fields[0] == null) return;
    id = int.parse(fields[0]);
    moveX = int.parse(fields[1]);
    moveY = int.parse(fields[2]);
    orientation = int.parse(fields[3]);
    fire = fields[4] == "true";
    weaponCycle = fields[5] == "true";
    mouseMoved = fields[6] == "true";
    mouseX = num.parse(fields[7]);
    mouseY = num.parse(fields[8]);

  }
}
*/
class CmdOld {
  num ms = 10, tr = .10;
  num dmg = 0;
  num id = 0;
  String name;
  num moveX = 0, moveY = 0, rotate = 0;
  num mouseX = -1, mouseY = -1;
  bool fire = false, swap = false;

  String toString() {
    return "moveX: $moveX; moveY: $moveY; rotate: $rotate\n" +
        "mouseX:  $mouseX; mouseY: $mouseY\n" +
        "fire: $fire; swap: $swap;";
  }

  String stringify() {
    StringBuffer sb = new StringBuffer()
      ..write("$id,$name,")
      ..write("$moveX,$moveY,$rotate,")
      ..write("$mouseX,$mouseY,")
      ..write("$fire,$swap,");
    return sb.toString();
  }

  CmdOld() {}

  CmdOld.fromString(String s) {
    var fields = s.split(",");
    if (fields[0] == null) return;
    id = num.parse(fields[0]);
    name = fields[1];
    moveX = num.parse(fields[2]);
    moveY = num.parse(fields[3]);
    rotate = num.parse(fields[4]);
    mouseX = num.parse(fields[5]);
    mouseY = num.parse(fields[6]);
    fire = fields[7] == "true"? true: false;
    swap = fields[8] == "true"? true: false;
  }

  bool equals(CmdOld c) {
    return this.toString() == c.toString();
  }
}

