part of giggl;

class Actor extends DisplayObjectContainer {
  Bitmap torso;
  FlipBook hip;
  num adjustment;
  bool debug = true;
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
    this.x = x;
    this.y = y;
  }

  void hipRotate(num r) { hip.rotation += r; }
  void torsoRotate(num r) { this.rotation += r; }
}