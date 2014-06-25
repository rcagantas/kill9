part of giggl;

/**
 * Initialize all resources here.
 */
class ResourceHandler {
  static final int strideCount = 6;
  static final List<BitmapData> ac_stride = [];
  static bool initialized = false;

  static init() {
    if (initialized) return; // protect against multiple inits

    for (int i = 0; i < strideCount; i++) {
       resMgr.addBitmapData("ac_stride$i", "./assets/sprites/ac_stride$i.png");
    }
    /** deprecate soon */
    resMgr.addBitmapData("ac_center", "./assets/sprites/ac_center.png");
    resMgr.addBitmapData("ac_corner1", "./assets/sprites/ac_corner1.png");
    resMgr.addBitmapData("ac_corner2", "./assets/sprites/ac_corner2.png");

    resMgr.addBitmapData("ac_torso", "./assets/sprites/ac_torso.png");

    resMgr.addBitmapData("ac_pistol", "./assets/sprites/ac_pistol.png");
    resMgr.addBitmapData("ac_rifle", "./assets/sprites/ac_rifle.png");
    resMgr.addBitmapData("ac_grenade", "./assets/sprites/ac_grenade.png");
    resMgr.addBitmapData("ac_rocket", "./assets/sprites/ac_rocket.png");


    resMgr.load().then((_) {
      for (int i = 0; i < strideCount; i++) {
        ac_stride.add(resMgr.getBitmapData("ac_stride$i"));
      }
    });

    initialized = true;
  }
}