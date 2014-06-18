part of giggl;

/**
 * Initialize all resources here.
 */
class ResourceHandler {
  static final int strideCount = 6;
  static final List<BitmapData> bmpStride = [];
  static bool initialized = false;

  static init() {
    if (initialized) return; // protect against multiple inits

    for (int i = 0; i < strideCount; i++)
       resMgr.addBitmapData("stride$i", "./res/stride$i.png");

    resMgr.load().then((_) {
      for (int i = 0; i < strideCount; i++)
        bmpStride.add(resMgr.getBitmapData("stride$i"));
    });

    initialized = true;
  }
}