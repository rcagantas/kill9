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
       resMgr.addBitmapData("ac_stride$i", "./res/sprites/ac_stride$i.png");
    }
    resMgr.addBitmapData("ac_rifle", "./res/sprites/ac_rifle.png");

    resMgr.addBitmapData("ac_center", "./res/sprites/ac_center.png");
    resMgr.addBitmapData("ac_corner1", "./res/sprites/ac_corner1.png");
    resMgr.addBitmapData("ac_corner2", "./res/sprites/ac_corner2.png");

    resMgr.load().then((_) {
      for (int i = 0; i < strideCount; i++) {
        ac_stride.add(resMgr.getBitmapData("ac_stride$i"));
      }
    });

    initialized = true;
  }
}