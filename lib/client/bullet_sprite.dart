part of gglclient;

class BulletSprite extends DisplayObjectContainer {
  Shape shape;
  ParticleEmitter splash;
  BulletSprite() {
    splash = new ParticleEmitter(
        ResourceHandler.jsonBulletSplash)
      ..stop(true)
      ..addTo(this);
    stage.juggler.add(splash);

    shape = new Shape()
      ..graphics.ellipse(0, 0, 3, 6)
      ..graphics.fillColor(Color.White)
      ..addTo(this);
  }

  void set visible(bool b) {
    shape.visible = b;
  }

  void collide() {
    splash.start(0.3);
  }
}

class GrenadeSprite extends DisplayObjectContainer {
  Bitmap grenade;
  ParticleEmitter particles, explosion;
  GrenadeSprite() {
    particles = new ParticleEmitter(
        ResourceHandler.jsonGrenade)
      ..addTo(this);
    stage.juggler.add(particles);

    explosion = new ParticleEmitter(
        ResourceHandler.jsonExplode)
      ..stop(true)
      ..addTo(this);
    stage.juggler.add(explosion);

    grenade = new Bitmap(resMgr.getBitmapData("grenade"))
      ..pivotX = 7
      ..pivotY = 7
      ..addTo(this);
  }

  void set visible(bool b) {
    grenade.visible = b;
  }

  void explode() {
    explosion.start(0.2);
  }
}

class RocketSprite extends DisplayObjectContainer {
  Bitmap rocket;
  ParticleEmitter particles, explosion;
  RocketSprite() {
    particles = new ParticleEmitter(ResourceHandler.jsonRocket)
      ..addTo(this);
    stage.juggler.add(particles);

    explosion = new ParticleEmitter(
        ResourceHandler.jsonExplode)
      ..stop(true)
      ..addTo(this);
    stage.juggler.add(explosion);

    rocket = new Bitmap(resMgr.getBitmapData("rocket"))
      ..pivotX = 7
      ..pivotY = 7
      ..addTo(this);
  }

  void set visible(bool b) {
    rocket.visible = b;
  }

  void explode() {
    explosion.start(0.2);
  }
}