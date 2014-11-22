part of gglclient2;

class BulletSprite extends DisplayObjectContainer {
  num center = 7;
  num _type = 0;
  List<Bitmap> types = [];
  Sprite bulletLayer;
  ParticleEmitter bulletSplash, explode;

  BulletSprite() {
    bulletLayer = new Sprite()
      ..addTo(this);

    for (num i = 0; i < resLoader.bulletNames.length; i++) {
      types.add(new Bitmap(resource.getBitmapData(resLoader.bulletNames[i]))
        ..pivotX = center
        ..pivotY = center
        ..visible = _type == i? true : false
        ..addTo(bulletLayer));
    }
    bulletSplash = new ParticleEmitter(ParticleLoader.bulletSplash)
        ..stop(true)
        ..addTo(this);
    stage.juggler.add(bulletSplash);
    explode = new ParticleEmitter(ParticleLoader.explode)
        ..stop(true)
        ..addTo(this);
    stage.juggler.add(explode);
  }

  set visible(bool b) { bulletLayer.visible = b; }

  set type(num t) {
    if (t == _type) return;
    types[_type].visible = false;
    _type = t;
    types[_type].visible = true;
  }

  void hitPlayer(bool b) {
    if (b) {
      switch(_type) {
        case BulletType.GRENADE:
        case BulletType.ROCKET:
          explode.start(.5);
          break;
      }
    }
  }

  void hitObject(bool b) {
    if (b) {
      switch (_type) {
        case BulletType.BULLET:
          bulletSplash.start(.3);
          break;
        case BulletType.GRENADE:
        case BulletType.ROCKET:
          explode.start(.5);
          break;
      }
    }
  }
}