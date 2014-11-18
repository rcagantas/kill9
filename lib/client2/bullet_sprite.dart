part of gglclient2;

class BulletSprite extends DisplayObjectContainer {
  num center = 7;
  num type = 0;
  List<Bitmap> types = [];
  Sprite bulletLayer;
  ParticleEmitter bulletSplash;

  BulletSprite() {
    bulletLayer = new Sprite()
      ..addTo(this);

    for (num i = 0; i < resLoader.bulletNames.length; i++) {
      types.add(new Bitmap(resource.getBitmapData(resLoader.bulletNames[i]))
        ..pivotX = center
        ..pivotY = center
        ..visible = type == i? true : false
        ..addTo(bulletLayer));
    }
    bulletSplash = new ParticleEmitter(ParticleLoader.bulletSplash)
        ..stop(true)
        ..addTo(this);
      stage.juggler.add(bulletSplash);
  }

  set visible(bool b) { bulletLayer.visible = b; }

  void hitObject(bool b) {
    if (b) {
      switch (type) {
        case BulletType.BULLET:
          bulletSplash.start(.3);
          break;
      }
    }
  }
}