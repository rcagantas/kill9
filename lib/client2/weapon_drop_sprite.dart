part of gglclient2;

class WeaponDropSprite extends DisplayObjectContainer {
  List<TextField> drops = [];
  num _type = 0;
  WeaponDropSprite() {
    for (String weapon in resLoader.weaponNames) {
      drops.add(
          new TextField()
            ..x = 0
            ..y = 0
            ..text = weapon
            ..visible = false
            ..addTo(this)
      );
    }
  }

  set type(num t) {
    drops[_type].visible = false;
    _type = t;
    drops[_type].visible = true;
  }
}