part of gglclient2;

class ResourceLoader {
  final num playerMax = 10;
  final List<String> weaponNames = ['pistol','rifle','grenade','rocket'];
  ResourceLoader() {
    String sprites = "assets/sprites";
    String sounds = "assets/sounds";
    String tiles = "assets/tiles";

    for (num i = 0; i < 6; i++)
      resource.addBitmapData("ac_stride$i", "$sprites/ac_stride$i.png");

    for (num i = 0; i < playerMax; i++) {
      resource.addBitmapData("ac${i}_torso", "$sprites/ac${i}_torso.png");
      resource.addBitmapData("ac${i}_death0", "$sprites/ac${i}_death0.png");
      resource.addBitmapData("ac${i}_death1", "$sprites/ac${i}_death1.png");
    }

    resource.addBitmapData("ac_head", "$sprites/ac_head.png");

    for (String weaponName in weaponNames) {
      resource.addBitmapData("ac_$weaponName", "$sprites/ac_$weaponName.png");
      resource.addSound("snd_$weaponName", "$sounds/$weaponName.ogg");
    }
    resource.addSound("snd_reload", "$sounds/reload.ogg");
    SoundMixer.soundTransform = new SoundTransform(0.3);

    resource.addBitmapData("crate", "$tiles/crate.png");
    resource.addBitmapData("tree", "$tiles/tree.png");
    resource.addBitmapData("floor", "$tiles/floor5.png");
  }

  FlipBook flipbookDeath(num playerNo, num frameRate) {
    List<BitmapData> death = [];
    death.add(resource.getBitmapData("ac${playerNo}_death0"));
    death.add(resource.getBitmapData("ac${playerNo}_death1"));
    return new FlipBook(death, frameRate);
  }

}

