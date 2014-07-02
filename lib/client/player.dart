part of gglclient;

class Player extends DisplayObjectContainer {
  static const num CENTER = 48.5; //center of player tile
  static const num OFFSET = 8;
  static const num HPRADIUS = 33;

  Bitmap head;
  Bitmap torso;
  String pre = "ac0";
  Map<String, Bitmap> weapons = new Map<String, Bitmap>();
  List<String> weaponNames = ['pistol','rifle','grenade','rocket'];
  String weapon = "pistol";
  FlipBook hip;
  Shape arcHealth;
  TextField dbg;
  bool dbgmode = false;
  num hp = 100;
  ParticleEmitter splatter;

  Player() {
    splatter = new ParticleEmitter(ResourceHandler.jsonBloodSplat)
      ..stop(true)
      ..addTo(this);
    stage.juggler.add(splatter);

    arcHealth = new Shape()
      ..pivotX = CENTER
      ..pivotY = CENTER
      ..rotation = math.PI/2
      ..graphics.arc(CENTER, CENTER, HPRADIUS, -math.PI/4, math.PI/4, false)
      ..graphics.strokeColor(Color.YellowGreen, 4)
      ..addTo(this);

    hip = new FlipBook(ResourceHandler.ac0_stride, 10)
      ..addTo(this)
      ..x = - OFFSET
      ..y = OFFSET
      ..pivotX = CENTER - OFFSET
      ..pivotY = CENTER + OFFSET
      ..play();
    stage.juggler.add(hip);

    torso = new Bitmap(resMgr.getBitmapData("${pre}_torso"))
      ..pivotX = CENTER
      ..pivotY = CENTER
      ..addTo(this);

    for (String weaponName in weaponNames) {
      Bitmap bmp = new Bitmap(resMgr.getBitmapData("${pre}_${weaponName}"))
        ..visible = weaponName == "pistol"? true: false
        ..pivotX = CENTER
        ..pivotY = CENTER
        ..addTo(this);
      weapons[weaponName] = bmp;
    }

    head = new Bitmap(resMgr.getBitmapData("${pre}_head"))
      ..pivotX = CENTER
      ..pivotY = CENTER
      ..addTo(this);

    x = stage.stageWidth/2;
    y = stage.stageHeight/2;

    TextFormat tf = new TextFormat('Helvetica', 10, Color.Red);
    dbg = new TextField()
      ..defaultTextFormat = tf
      ..x = 30
      ..y = 30
      ..width = 200
      ..height = 200
      ..wordWrap = true
      ..addTo(this);
  }

  void move(num x, num y) {
    if (this.x == x && this.y == y) {
      hip.gotoAndStop(0);
      return;
    }
    if (!hip.playing) hip.play();
    fixHipRotation(x, y);
    this.x = x;
    this.y = y;
  }

  void takeDamage(num dmg) {
    hp = hp - dmg < 0? 0 : hp - dmg;
    num angle = math.PI/4 * hp/100;
    num color = hp/100 < .4? Color.Red : Color.YellowGreen;
    arcHealth.graphics.clear();
    arcHealth
      ..graphics.arc(CENTER, CENTER, HPRADIUS, -angle, angle, false)
      ..graphics.strokeColor(color, 4);
    splatter.start(.2);
  }

  void fixHipRotation(num x, num y) {
    num dx = x - this.x;
    num dy = y - this.y;
    if (dx == 0 && dy == 0) return;
    num hrad = math.atan2(dy, dx) + math.PI/2;
    num trad = this.rotation;

    num val = peg180(hrad - trad);
    val = val.abs() > math.PI/2? val - math.PI: val;
    hip.rotation = peg180(val);
    displayAngles();
  }

  void turn(num r) {
    if (this.rotation == r) return;
    this.rotation = peg180(r);
    dbg.rotation = -this.rotation;
    fixHipRotation(this.x, this.y);
  }

  void turnToPoint(num dx, num dy) {
    turn(math.PI - math.atan2(dx - x, dy - y));
  }

  void turnAdd(num r) { turn(this.rotation + r); }

  /** there's probably easier ways to do this. */
  num peg180(num val) {
    num max = math.PI;
    num min = -math.PI;
    val -= min;
    max -= min;
    if (max == 0) return min;
    val = val % max;
    val += min;
    while (val < min) val += max;
    return val;
  }

  void displayAngles() {
    if (!dbgmode) return;
    dbg.text = "all: ${(this.rotation * 180/math.PI).toStringAsFixed(2)}\n"
      + "hip: ${(hip.rotation * 180/math.PI).toStringAsFixed(2)}";
  }

  String cycleWeapon() {
    num index = weaponNames.indexOf(weapon);
    String newWeapon = weaponNames[index + 1 >= weaponNames.length? 0 : index + 1];
    setWeapon(newWeapon);
    return newWeapon;
  }

  bool setWeapon(String newWeapon) {
    if (weaponNames.contains(newWeapon)) {
      weapons[weapon].visible = false;
      weapon = newWeapon;
      weapons[weapon].visible = true;
      return true;
    }
    return false;
  }

  num frameskip = 0;
  void fire() {
    frameskip++;
    if (frameskip != 4) return;
    frameskip = 0;
    torso.y =
    weapons[weapon].y = torso.y == 3? 0 : 3;;
  }

  void resetTorso() {
    torso.y =
    weapons[weapon].y = 0;
  }
}