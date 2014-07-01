part of giggl;

/**
 * Initialize all resources here.
 */
class ResourceHandler {
  static final int strideCount = 6;
  static final List<BitmapData> ac_stride = [];
  static final List<BitmapData> ac0_stride = [];
  static bool initialized = false;
  static Map jsonBloodSplat =
    {
      "maxParticles": 50,
      "duration": .2,
      "lifeSpan": 0.2, "lifespanVariance": 0.1,
      "startSize": .1, "startSizeVariance": .2,
      "finishSize": 20, "finishSizeVariance": 5,
      "shape": "circle",
      "emitterType": 0,
      "location": {"x": 0, "y": 0},
      "locationVariance": {"x": 0, "y": 0},
      "speed": 200, "speedVariance": 10,
      "angle": -90, "angleVariance": 45,
      "gravity": {"x": 0, "y": 0},
      "radialAcceleration": 20, "radialAccelerationVariance": 0,
      "tangentialAcceleration": 10, "tangentialAccelerationVariance": 0,
      "minRadius": 0, "maxRadius": 100, "maxRadiusVariance": 0,
      "rotatePerSecond": 0, "rotatePerSecondVariance": 0,
      "compositeOperation": "source-over",
      "startColor": {"red": 1, "green": 0, "blue": 0, "alpha": 1},
      "finishColor": {"red": 1, "green": 0, "blue": 0, "alpha": 0}
    };

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