part of gglclient;

/**
 * Initialize all resources here.
 */
class ResourceHandler {
  static final int strideCount = 6;
  static final List<BitmapData> ac_stride = [];
  static const num MAX_PLAYERS = 9;
  static bool initialized = false;
  static String pre = "ac";
  static Map jsonBloodSplat =
    {
      "maxParticles": 50,
      "duration": .2,
      "lifeSpan": 0.2, "lifespanVariance": 0.1,
      "startSize": 1, "startSizeVariance": 1,
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
      "finishColor": {"red": 1, "green": 0, "blue": 0, "alpha": .25}
    };
  static Map jsonBloodSplatAoe =
    {
      "maxParticles": 50,
      "duration": .2,
      "lifeSpan": 0.2, "lifespanVariance": 0.1,
      "startSize": 1, "startSizeVariance": 1,
      "finishSize": 30, "finishSizeVariance": 5,
      "shape": "circle",
      "emitterType": 0,
      "location": {"x": 0, "y": 0},
      "locationVariance": {"x": 0, "y": 0},
      "speed": 200, "speedVariance": 10,
      "angle": 0, "angleVariance": 360,
      "gravity": {"x": 0, "y": 0},
      "radialAcceleration": 20, "radialAccelerationVariance": 0,
      "tangentialAcceleration": 10, "tangentialAccelerationVariance": 0,
      "minRadius": 0, "maxRadius": 100, "maxRadiusVariance": 0,
      "rotatePerSecond": 0, "rotatePerSecondVariance": 0,
      "compositeOperation": "source-over",
      "startColor": {"red": 1, "green": 0, "blue": 0, "alpha": 1},
      "finishColor": {"red": 1, "green": 0, "blue": 0, "alpha": .25}
    };


  static init() {
    if (initialized) return; // protect against multiple inits
    String sprites = "assets/sprites";
    String tiles = "assets/tiles";
    String sounds = "assets/sounds";

    for (int i = 0; i < strideCount; i++) {
       resMgr.addBitmapData("${pre}_stride$i", "${sprites}/${pre}_stride$i.png");
    }
    /** deprecate soon */
    resMgr.addBitmapData("ac_center", "${sprites}/ac_center.png");
    resMgr.addBitmapData("ac_corner1", "${sprites}/ac_corner1.png");
    resMgr.addBitmapData("ac_corner2", "${sprites}/ac_corner2.png");

    for (num i = 0; i <= MAX_PLAYERS; i++) {
      resMgr.addBitmapData("${pre}${i}_torso", "${sprites}/${pre}${i}_torso.png");
      resMgr.addBitmapData("${pre}${i}_death0", "${sprites}/${pre}${i}_death0.png");
      resMgr.addBitmapData("${pre}${i}_death1", "${sprites}/${pre}${i}_death1.png");
    }

    resMgr.addBitmapData("${pre}_head", "${sprites}/${pre}_head.png");
    resMgr.addBitmapData("${pre}_pistol", "${sprites}/${pre}_pistol.png");
    resMgr.addBitmapData("${pre}_rifle", "${sprites}/${pre}_rifle.png");
    resMgr.addBitmapData("${pre}_grenade", "${sprites}/${pre}_grenade.png");
    resMgr.addBitmapData("${pre}_rocket", "${sprites}/${pre}_rocket.png");

    resMgr.addBitmapData("crate", "${tiles}/crate.png");
    resMgr.addBitmapData("tree", "${tiles}/tree.png");
    resMgr.addBitmapData("floor", "${tiles}/floor.png");
    
    //sounds
    resMgr.addSound("snd_pistol", "${sounds}/pistol.ogg");
    resMgr.addSound("snd_rifle", "${sounds}/rifle.ogg");
    resMgr.addSound("snd_grenade", "${sounds}/pistol.ogg");
    resMgr.addSound("snd_rocket", "${sounds}/rocket.ogg");

    resMgr.load().then((_) {
      for (int i = 0; i < strideCount; i++) {
        ac_stride.add(resMgr.getBitmapData("${pre}_stride$i"));
        initialized = true;
      }
    });
  }

  static FlipBook flipbookDeath(num playerNo, num frameRate) {
    List<BitmapData> death = [];
    death.add(resMgr.getBitmapData("${pre}${playerNo}_death0"));
    death.add(resMgr.getBitmapData("${pre}${playerNo}_death1"));
    return new FlipBook(death, frameRate);
  }
}