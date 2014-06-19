part of giggl;

class Actor extends DisplayObjectContainer {
  Bitmap torso;
  FlipBook legs;
  Actor() {
    torso = new Bitmap(resMgr.getBitmapData("p1_rifle"));
    legs = new FlipBook(ResourceHandler.stridea, 10)
      ..x = 1
      ..y = 1
      ..addTo(this)
      ..play();
    this.x = this.y = 1; // just in case
    this.pivotX = torso.width/2;
    this.pivotY = torso.height/2;
    this.addChild(torso);
    stage.juggler.add(legs);
  }
}