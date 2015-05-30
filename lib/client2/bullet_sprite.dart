part of gglclient2;

class BulletPool {
  static List<BulletSprite> _bullets = new List<BulletSprite>();

  static BulletSprite getFreeBullet() {
    if (_bullets.isNotEmpty) {
      _bullets[0].reset();
      return _bullets.removeAt(0);
    }
    return new BulletSprite();
  }

  static void returnBullet(BulletSprite b) {
    if (!_bullets.contains(b)) _bullets.add(b);
  }

  static String debug() {
    return "bullet pool count: ${_bullets.length}";
  }
}

class BulletSprite extends Sprite {
  num _wtype = 0;

  Bitmap bullet, grenade, rocket;
  Sprite pnlCollision = new Sprite();
  Sprite pnlBullet = new Sprite();
  Sound explodeSnd, hitSnd;
  ParticleEmitter bulletHit, explode;

  static final num center = 7;

  BulletSprite() {
    bullet = new Bitmap(resource.getBitmapData("wb_bullet"))
      ..pivotX = center
      ..pivotY = center
      ..addTo(pnlBullet);

    grenade = new Bitmap(resource.getBitmapData("wb_grenade"))
      ..pivotX = center
      ..pivotY = center
      ..addTo(pnlBullet);

    rocket = new Bitmap(resource.getBitmapData("wb_rocket"))
      ..pivotX = center
      ..pivotY = center
      ..addTo(pnlBullet);

    bulletHit = new ParticleEmitter(ParticleLoader.bulletHit)
        ..stop(true)
        ..addTo(pnlCollision);
    stage.juggler.add(bulletHit);

    explode = new ParticleEmitter(ParticleLoader.explode)
        ..stop(true)
        ..addTo(pnlCollision);
    stage.juggler.add(explode);

    explodeSnd = resource.getSound("ws_explode");
    hitSnd = resource.getSound("ws_hit");
    pnlBullet.addTo(this);
    pnlCollision.addTo(this);
  }

  void setBulletType(num type) {
    switch (type) {
      case 0: setWeaponType(0); break;
      case 1: setWeaponType(2); break;
      case 2: setWeaponType(3); break;
    }
  }


  void setWeaponType(num type) {
    _wtype = type;
    pnlBullet.removeChildren();
    switch(type) {
      case 0:
      case 1: pnlBullet.addChild(bullet); break;
      case 2: pnlBullet.addChild(grenade); break;
      case 3: pnlBullet.addChild(rocket); break;
      default: pnlBullet.addChild(bullet); break;
    }
  }

  void reset() {
    pnlBullet.visible = true;
  }

  void hit(bool b) {
    if (b) collide();
  }

  void move(num x, num y) {
    this.x = x;
    this.y = y;
    if (!this.contains(pnlCollision)) {
      pnlCollision.x = this.x;
      pnlCollision.y = this.y;
      pnlCollision.rotation = this.rotation;
    }
  }

  void collide() {
    pnlBullet.visible = false;
    switch(_wtype) {
      case 0:
      case 1:
        bulletHit.start(0.3);
        hitSnd.play(false);
        break;
      case 2:
      case 3:
        explode.start(0.3);
        explodeSnd.play(false);
        break;
    }
  }
}
