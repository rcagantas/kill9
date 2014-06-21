part of giggl;

class Actor extends DisplayObjectContainer {
  Bitmap torso;
  FlipBook hip;
  num adjustment;

  Actor() {
    torso = new Bitmap(resMgr.getBitmapData("ac_rifle"));
    adjustment = torso.height/2;

    hip = new FlipBook(ResourceHandler.ac_stride, 10)
      ..addTo(this)
      ..play();

    this.x = this.y = 1; // just in case
    torso.pivotX =
    torso.pivotY = adjustment;
    hip.x = -7;
    hip.y = 8;
    hip.pivotX = adjustment - 7; //offset of hips
    hip.pivotY = adjustment + 8;

    this.addChild(torso);
    stage.juggler.add(hip);
  }


  void move(num x, num y) {
    if (this.x == x && this.y == y) {
      hip.gotoAndStop(0);
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
    this.rotation = trad.abs() > math.PI * 2? 0: trad;

    /*num hdeg = math.atan2(dx, dy) * 180/math.PI;
    num tdeg = trad * 180/math.PI;
    print("${(hdeg - tdeg).abs()}");*/

    num val = (hrad - trad).abs();
    hrad = val > math.PI/2 || val < 0?
        hrad - math.PI:
        hrad;
    hip.rotation = hrad - trad;
  }

  void hipRotate(num r) { hip.rotation += r; }
  void torsoRotate(num r) {
    this.rotation += r; fixHipRotation(this.x, this.y);
  }
}