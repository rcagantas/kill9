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

  String toString() {
    var stringBuffer = new StringBuffer()
    ..write("$id,$x,$y,$orientation,")
    ..write("$lifeRatio,$weaponType,$weaponAmmo,$damageFrom,$isFiring,$isMoving,")
    ..write("$name");
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
    name = fields[10];
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

  // Player stats;
  Map killStats = new Map();
  Map deathStats = new Map();

  // Objects visible in the world
  List<ObjectInFrame> visibleObjects = new List();

  String toString() {
    var stringBuffer = new StringBuffer()
    ..write("$playerId,$topX,$topY")
    ..write("~");
    //playerStats
    killStats.forEach((key, value) {
      stringBuffer.write("$key,$value,");
    });

    stringBuffer.write("~");

    deathStats.forEach((key, value) {
      stringBuffer.write("$key,$value,");
    });

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


    if (main[1] !=  "") {
      var kills = main[1].split(",");
      for (int i = 0; i < kills.length-1; i = i+2) {
        killStats[int.parse(kills[i])] = int.parse(kills[i+1]);
      }
    }
    if (main[2] !=  "") {
      var deaths = main[1].split(",");
      for (int i = 0; i < deaths.length-1; i = i+2) {
        deathStats[int.parse(deaths[i])] = int.parse(deaths[i+1]);
      }
    }


    var objects = main[3].split("|");

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
  num ms = 5, tr = .10;
  num moveX = 0, moveY = 0, rotate = 0;
  num mouseX = -1, mouseY = -1;
  bool fire = false, swap = false;
  num dmg = 0;

  String toString() {
    return "moveX: $moveX; moveY: $moveY; rotate: $rotate\n" +
        "fire: $fire; swap: $swap;";
  }

  bool equals(Cmd c) {
    return this.toString() == c.toString();
  }
}

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
    fire = fields[4] == "true"? true: false;
    weaponCycle = fields[5] == "true"? true: false;
    mouseMoved = fields[6] == "true"? true: false;
    mouseX = num.parse(fields[7]);
    mouseY = num.parse(fields[8]);

  }
}
