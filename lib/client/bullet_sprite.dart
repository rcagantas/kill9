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
  ParticleEmitter particles;
  GrenadeSprite() {
    particles = new ParticleEmitter(ResourceHandler.jsonGrenade)
      ..addTo(this);
    stage.juggler.add(particles);

    grenade = new Bitmap(resMgr.getBitmapData("grenade"))
      ..pivotX = 7
      ..pivotY = 7
      ..addTo(this);
  }
}

class RocketSprite extends DisplayObjectContainer {
  Bitmap rocket;
  ParticleEmitter particles;
  RocketSprite() {
    particles = new ParticleEmitter(ResourceHandler.jsonRocket)
      ..addTo(this);
    stage.juggler.add(particles);

    rocket = new Bitmap(resMgr.getBitmapData("rocket"))
      ..pivotX = 7
      ..pivotY = 7
      ..addTo(this);
  }
}