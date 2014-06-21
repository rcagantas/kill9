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

    TextFormat tf = new TextFormat('Helvetica', 10, Color.Black);
    dbgtxt = new TextField()
      ..defaultTextFormat = tf
      ..x = 50
      ..y = 50
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
    num dx = x - this.x; //stage.stageWidth/2;
    num dy = this.y - y; //stage.stageHeight/2;
    num hrad = math.atan2(dx, dy);
    num trad = this.rotation;
    //this.rotation = trad.abs() > math.PI * 2? 0: trad;

    /*num hdeg = math.atan2(dx, dy) * 180/math.PI;
    num tdeg = trad * 180/math.PI;
    print("${(hdeg - tdeg).abs()}");*/

    num val = trad - hrad;
    dbgtxt.text = "${val * 180/math.PI}";
    hrad = val > math.PI/2? hrad - math.PI: hrad;
    // TODO: incorrect. fix.

    hip.rotation = hrad - trad;
  }

  void hipRotate(num r) { hip.rotation += r; }
  void torsoRotate(num r) {
    if (r == 0) return;
    num trad = this.rotation + r;
    trad = trad > math.PI? trad - math.PI*2: trad;
    trad = trad < -math.PI? trad + math.PI*2: trad;

    this.rotation = trad;

    fixHipRotation(this.x, this.y);
  }
}