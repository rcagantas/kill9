part of gglclient;

class BulletSprite extends DisplayObjectContainer {
  int _type;
  Shape bulletShape;
  ParticleEmitter bulletSplash;
  Bitmap grenade, rocket;
  ParticleEmitter grenadeParticles, rocketParticles, explosion;

  BulletSprite() {
    type = BulletType.BULLET;
  }

  void set type(int t) {
    this.removeChildren();
    switch(t) {
      case BulletType.BULLET:
        bulletSplash = new ParticleEmitter(
            ResourceHandler.jsonBulletSplash)
          ..stop(true)
          ..addTo(this);
        stage.juggler.add(bulletSplash);

        bulletShape = new Shape()
          ..graphics.ellipse(0, 0, 3, 6)
          ..graphics.fillColor(Color.White)
          ..addTo(this);
        break;
      case BulletType.GRENADE:
        explosion = new ParticleEmitter(
            ResourceHandler.jsonExplode)
          ..stop(true)
          ..addTo(this);
        stage.juggler.add(explosion);

        grenadeParticles = new ParticleEmitter(
            ResourceHandler.jsonGrenade)
          ..addTo(this);
        stage.juggler.add(grenadeParticles);

        grenade = new Bitmap(resMgr.getBitmapData("grenade"))
          ..pivotX = 7
          ..pivotY = 7
          ..addTo(this);
        break;
      case BulletType.ROCKET:
        explosion = new ParticleEmitter(
            ResourceHandler.jsonExplode)
          ..stop(true)
          ..addTo(this);
        stage.juggler.add(explosion);

        rocketParticles = new ParticleEmitter(ResourceHandler.jsonRocket)
          ..pivotX = 0
          ..pivotY = -10
          ..addTo(this);
        stage.juggler.add(rocketParticles);

        rocket = new Bitmap(resMgr.getBitmapData("rocket"))
          ..pivotX = 7
          ..pivotY = 7
          ..addTo(this);
        break;
    }
    _type = t;
  }

  int get type{ return _type; }

  void set visible(bool b) {
    switch(type) {
      case BulletType.BULLET:
        bulletShape.visible = b;
        break;
      case BulletType.GRENADE:
        grenade.visible =
        grenadeParticles.visible = b;
        break;
      case BulletType.ROCKET:
        rocket.visible =
        rocketParticles.visible = b;
        break;
    }
  }

  void explode() {
    switch(type) {
      case BulletType.BULLET: bulletSplash.start(0.3); break;
      case BulletType.GRENADE:
      case BulletType.ROCKET: explosion.start(0.5); break;
    }
  }
}