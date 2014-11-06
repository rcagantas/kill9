part of gglclient2;

class ResourceLoader {
  final num playerMax = 10;
  final List<String> weaponNames = ['pistol','rifle','grenade','rocket'];
  ResourceLoader() {
    String dir = "assets/sprites";

    for (num i = 0; i < 6; i++)
      resource.addBitmapData("ac_stride$i", "$dir/ac_stride$i.png");

    for (num i = 0; i < playerMax; i++) {
      resource.addBitmapData("ac${i}_torso", "$dir/ac${i}_torso.png");
      resource.addBitmapData("ac${i}_death0", "$dir/ac${i}_death0.png");
      resource.addBitmapData("ac${i}_death1", "$dir/ac${i}_death1.png");
    }

    resource.addBitmapData("ac_head", "$dir/ac_head.png");

    for (String weaponName in weaponNames)
      resource.addBitmapData("ac_$weaponName", "$dir/ac_$weaponName.png");
  }
}

