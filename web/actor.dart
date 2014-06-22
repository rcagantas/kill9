part of giggl;

class Actor extends DisplayObjectContainer {
  Bitmap torso;
  FlipBook hip;
  num adjustment;
  TextField dbgtxt;

  Actor() {
    torso = new Bitmap(resMgr.getBitmapData("ac_rifle"));
    adjustment = torso.height/2;

    hip = new FlipBook(ResourceHandler.ac_stride, 10)
      ..addTo(this)
      ..play();

    x = stage.stageWidth/2;
    y = stage.stageHeight/2;
    torso.pivotX =
    torso.pivotY = adjustment;
    hip.x = -7;
    hip.y = 8;
    hip.pivotX = adjustment - 7; //offset of hips
    hip.pivotY = adjustment + 8;

    this.addChild(torso);
    stage.juggler.add(hip);

    TextFormat tf = new TextFormat('Helvetica', 10, Color.Red);
    dbgtxt = new TextField()
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
    fixHipRotation(this.x, this.y);
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
    dbgtxt.rotation = -this.rotation;
    dbgtxt.text = "all: ${(this.rotation * 180/math.PI).toStringAsFixed(2)}\n"
      + "hip: ${(hip.rotation * 180/math.PI).toStringAsFixed(2)}";
  }
}