part of gglclient2;

class DropSprite extends DisplayObjectContainer {
  ParticleEmitter spawn;
  Sprite drop = new Sprite();
  Bitmap rifle, grenade, rocket;
  static final num center = 50;
  DropSprite() {
    drop.addTo(this);
    rifle = new Bitmap(resource.getBitmapData("wd_rifle"))
      ..pivotX = center
      ..pivotY = center
      ..addTo(drop);
    grenade = new Bitmap(resource.getBitmapData("wd_grenade"))
      ..pivotX = center
      ..pivotY = center
      ..addTo(drop);
    rocket = new Bitmap(resource.getBitmapData("wd_rocket"))
      ..pivotX = center
      ..pivotY = center
      ..addTo(drop);
    spawn = new ParticleEmitter(ParticleLoader.spawn)
      ..stop(true)
      ..addTo(this);
    stage.juggler.add(spawn);
  }

  set type(num type) {
    drop.removeChildren();
    switch(type) {
      case 1: drop.addChild(rifle); break;
      case 2: drop.addChild(grenade); break;
      case 3: drop.addChild(rocket); break;
      default: drop.addChild(rifle); break;
    }
    spawn.start();
  }
}