part of gglclient;

class BulletSprite extends DisplayObjectContainer {
  Shape shape;
  BulletSprite() {
    shape = new Shape()
      ..graphics.ellipse(0, 0, 3, 6)
      ..graphics.fillColor(Color.White)
      ..addTo(this);
  }
}

class GrenadeSprite extends DisplayObjectContainer {
  Bitmap grenade;
  GrenadeSprite() {
    grenade = new Bitmap(resMgr.getBitmapData("grenade"))
      ..pivotX = 8.5
      ..pivotY = 8.5
      ..addTo(this);
  }
}

class RocketSprite extends DisplayObjectContainer {
  Bitmap rocket;
  RocketSprite() {
    rocket = new Bitmap(resMgr.getBitmapData("rocket"))
      ..pivotX = 8.5
      ..pivotY = 8.5
      ..addTo(this);
  }
}