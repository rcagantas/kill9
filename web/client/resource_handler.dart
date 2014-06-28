part of giggl;

/**
 * Initialize all resources here.
 */
class ResourceHandler {
  static final int strideCount = 6;
  static final List<BitmapData> ac_stride = [];
  static final List<BitmapData> ac0_stride = [];
  static bool initialized = false;

  static init() {
    if (initialized) return; // protect against multiple inits
    String pre = "ac0";

    for (int i = 0; i < strideCount; i++) {
       resMgr.addBitmapData("${pre}_stride$i", "./assets/sprites/${pre}_stride$i.png");
    }
    /** deprecate soon */
    resMgr.addBitmapData("ac_center", "./assets/sprites/ac_center.png");
    resMgr.addBitmapData("ac_corner1", "./assets/sprites/ac_corner1.png");
    resMgr.addBitmapData("ac_corner2", "./assets/sprites/ac_corner2.png");

    resMgr.addBitmapData("${pre}_head", "./assets/sprites/${pre}_head.png");
    resMgr.addBitmapData("${pre}_torso", "./assets/sprites/${pre}_torso.png");
    resMgr.addBitmapData("${pre}_pistol", "./assets/sprites/${pre}_pistol.png");
    resMgr.addBitmapData("${pre}_rifle", "./assets/sprites/${pre}_rifle.png");
    resMgr.addBitmapData("${pre}_grenade", "./assets/sprites/${pre}_grenade.png");
    resMgr.addBitmapData("${pre}_rocket", "./assets/sprites/${pre}_rocket.png");


    resMgr.load().then((_) {
      for (int i = 0; i < strideCount; i++) {
        ac0_stride.add(resMgr.getBitmapData("${pre}_stride$i"));
        initialized = true;
      }
    });
  }
}