part of gglclient;

class BulletSprite extends DisplayObjectContainer {
  Shape shape;
  BulletSprite() {
    shape = new Shape()
      ..pivotX = 0
      ..pivotY = 0
      ..graphics.ellipse(0, 0, 3, 6)
      ..graphics.fillColor(Color.White)
      ..addTo(this);
  }
}