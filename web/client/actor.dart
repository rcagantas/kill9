part of giggl;

class Actor extends DisplayObjectContainer {
  Bitmap head;
  Bitmap torso;
  String pre = "ac0";
  Map<String, Bitmap> weaponBmps = new Map<String, Bitmap>();
  List<String> weaponNames = ['pistol','rifle','grenade','rocket'];
  String currentWeapon = "pistol";
  FlipBook hip;
  static const num CENTER = 48.5; //center of player tile
  static const num OFFSET = 8;
  Shape arcHealth;
  TextField dbg;
  bool dbgmode = false;

  Actor() {
    arcHealth = new Shape()
      ..pivotX = CENTER
      ..pivotY = CENTER
      ..graphics.arc(CENTER, CENTER, 33, math.PI/4, 3/4 * math.PI, false)
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
      weaponBmps[weaponName] = bmp;
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

  void torsoRotate(num r) { turn(this.rotation + r); }

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
    num index = weaponNames.indexOf(currentWeapon);
    String weapon = weaponNames[index + 1 >= weaponNames.length? 0 : index + 1];    
    setWeapon(weapon);
    return weaponNames[index];
  }
  
  bool setWeapon(String weapon) {
    if (weaponNames.contains(weapon)) {
      weaponBmps[currentWeapon].visible = false;
      currentWeapon = weapon;
      weaponBmps[currentWeapon].visible = true;
      return true;
    }
    return false;
  }
}