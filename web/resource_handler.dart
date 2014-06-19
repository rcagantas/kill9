part of giggl;

/**
 * Initialize all resources here.
 */
class ResourceHandler {
  static final int strideCount = 6;
  static final List<BitmapData> stride = [];
  static final List<BitmapData> stridea = [];
  static bool initialized = false;

  static init() {
    if (initialized) return; // protect against multiple inits

    for (int i = 0; i < strideCount; i++) {
       resMgr.addBitmapData("stride$i", "./res/sprites/stride$i.png");
       resMgr.addBitmapData("stridea$i", "./res/sprites/stridea$i.png");
    }
    resMgr.addBitmapData("p1_rifle", "./res/sprites/p1_rifle.png");

    resMgr.load().then((_) {
      for (int i = 0; i < strideCount; i++) {
        stride.add(resMgr.getBitmapData("stride$i"));
        stridea.add(resMgr.getBitmapData("stridea$i"));
      }
    });

    initialized = true;
  }
}