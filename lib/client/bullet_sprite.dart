part of gglclient;

abstract class ProjectileSprite {
  void collide();
  void explode();
}

class BulletSprite 
  extends DisplayObjectContainer 
  implements ProjectileSprite {
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

  @override
  void collide() {
    splash.start(0.3);
  }

  @override
  void explode() {
  }
}

class GrenadeSprite 
  extends DisplayObjectContainer 
  implements ProjectileSprite {
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

  void collide() {
    
  }
  
  @override
  void set visible(bool b) {
    grenade.visible = b;
    particles.visible = b;
  }
  
  @override
  void explode() {
    explosion.start(0.5);
  }
}

class RocketSprite 
  extends DisplayObjectContainer 
  implements ProjectileSprite {
  Bitmap rocket;
  ParticleEmitter particles, explosion;
  RocketSprite() {
    particles = new ParticleEmitter(ResourceHandler.jsonRocket)
      ..pivotX = 0
      ..pivotY = -10
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
    particles.visible = b;
  }

  @override
  void explode() {
    explosion.start(0.5);
  }

  @override
  void collide() {
    explosion.start(0.5);
  }
}