part of giggl;

class Actor extends DisplayObjectContainer {
  Bitmap torso;
  FlipBook legs;
  num adjustment;
  Actor() {
    torso = new Bitmap(resMgr.getBitmapData("p1_rifle"));
    adjustment = torso.height/2;

    legs = new FlipBook(ResourceHandler.stridea, 10)
      ..addTo(this)
      ..play();

    this.x = this.y = 1; // just in case
    torso.pivotX = adjustment;
    torso.pivotY = adjustment;
    legs.x = -7;
    legs.y = 8;
    legs.pivotX = adjustment - 7; //offset of hips
    legs.pivotY = adjustment + 8;

    this.addChild(torso);
    stage.juggler.add(legs);
  }

  void move(num x, num y) {
    double xd = x - this.x;
    double yd = this.y - y;
    legs.rotation = math.atan2(xd, yd);
    //print("${legs.rotation} ${torso.rotation}");

    if ((legs.rotation.abs() - torso.rotation.abs()) >= (math.PI/2)) {
      legs.rotation = legs.rotation - (math.PI/2);
    }

    this.x = x;
    this.y = y;
  }

  void hipRotate(num r) { legs.rotation += r; }
  void torsoRotate(num r) { this.rotation += r; }
}