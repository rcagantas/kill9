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
      "maxParticles":50,
      "duration":0,
      "lifeSpan":0.5, "lifespanVariance":0.1,
      "startSize":15, "startSizeVariance":5,
      "finishSize":2, "finishSizeVariance":2,
      "shape":"circle",
      "emitterType":0,
      "location":{"x":0, "y":0},
      "locationVariance":{"x":0, "y":0},
      "speed":200, "speedVariance":10,
      "angle":-90, "angleVariance":45,
      "gravity":{"x":0, "y":0},
      "radialAcceleration":20, "radialAccelerationVariance":0,
      "tangentialAcceleration":10, "tangentialAccelerationVariance":0,
      "minRadius":0, "maxRadius":100, "maxRadiusVariance":0,
      "rotatePerSecond":0, "rotatePerSecondVariance":0,
      "compositeOperation":"source-over",
      "startColor":{"red":.5, "green":0, "blue":0, "alpha":1},
      "finishColor":{"red":.5, "green":0, "blue":0, "alpha":.25}
    };
  static Map jsonBloodSplatAoe =
    {
      "maxParticles":50,
      "duration":0,
      "lifeSpan":0.2, "lifespanVariance":0.1,
      "startSize":15, "startSizeVariance":5,
      "finishSize":2, "finishSizeVariance":2,
      "shape":"circle",
      "emitterType":0,
      "location":{"x":0, "y":0},
      "locationVariance":{"x":0, "y":0},
      "speed":200, "speedVariance":10,
      "angle":0, "angleVariance":360,
      "gravity":{"x":0, "y":0},
      "radialAcceleration":20, "radialAccelerationVariance":0,
      "tangentialAcceleration":10, "tangentialAccelerationVariance":0,
      "minRadius":0, "maxRadius":100, "maxRadiusVariance":0,
      "rotatePerSecond":0, "rotatePerSecondVariance":0,
      "compositeOperation":"source-over",
      "startColor":{"red":.5, "green":0, "blue":0, "alpha":1},
      "finishColor":{"red":.5, "green":0, "blue":0, "alpha":.25}
    };
  static Map jsonGrenade =
    {
      "maxParticles":5,
      "duration":0,
      "lifeSpan":0.4, "lifespanVariance":0.2,
      "startSize":1, "startSizeVariance":1,
      "finishSize":15, "finishSizeVariance":5,
      "shape":"circle",
      "emitterType":1,
      "location":{"x":0, "y":0},
      "locationVariance":{"x":0, "y":0},
      "speed":100, "speedVariance":10,
      "angle":0, "angleVariance":360,
      "gravity":{"x":0, "y":0},
      "radialAcceleration":20, "radialAccelerationVariance":0,
      "tangentialAcceleration":10, "tangentialAccelerationVariance":0,
      "minRadius":0, "maxRadius":40, "maxRadiusVariance":0,
      "rotatePerSecond":0, "rotatePerSecondVariance":0,
      "compositeOperation":"source-over",
      "startColor":{"red":1, "green":0.75, "blue":0, "alpha":1},
      "finishColor":{"red":1, "green":1, "blue":0, "alpha":0.25}
    };
  static Map jsonRocket =
    {
      "maxParticles":5,
      "duration":0,
      "lifeSpan":0.3, "lifespanVariance":0.2,
      "startSize":15, "startSizeVariance":5,
      "finishSize":2, "finishSizeVariance":2,
      "shape":"circle",
      "emitterType":0,
      "location":{"x":0, "y":0},
      "locationVariance":{"x":0, "y":0},
      "speed":200, "speedVariance":10,
      "angle":90, "angleVariance":15,
      "gravity":{"x":0, "y":0},
      "radialAcceleration":20, "radialAccelerationVariance":0,
      "tangentialAcceleration":10, "tangentialAccelerationVariance":0,
      "minRadius":0, "maxRadius":40, "maxRadiusVariance":0,
      "rotatePerSecond":0, "rotatePerSecondVariance":0,
      "compositeOperation":"source-over",
      "startColor":{"red":1, "green":0.75, "blue":0, "alpha":1},
      "finishColor":{"red":1, "green":1, "blue":0, "alpha":0}
    };
  static Map jsonExplode =
    {
      "maxParticles":400,
      "duration":0,
      "lifeSpan":0.9, "lifespanVariance":0.4,
      "startSize":70, "startSizeVariance":20,
      "finishSize":20, "finishSizeVariance":0,
      "shape":"circle",
      "emitterType":0,
      "location":{"x":0, "y":0}, "locationVariance":{"x":0, "y":0},
      "speed":300, "speedVariance":300,
      "angle":0, "angleVariance":360,
      "gravity":{"x":0, "y":0},
      "radialAcceleration":100, "radialAccelerationVariance":10,
      "tangentialAcceleration":0, "tangentialAccelerationVariance":0,
      "minRadius":0, "maxRadius":100, "maxRadiusVariance":0,
      "rotatePerSecond":0, "rotatePerSecondVariance":0,
      "compositeOperation":"source-over",
      "startColor":{"red":1, "green":0.75, "blue":0, "alpha":1},
      "finishColor":{"red":1, "green":0, "blue":0, "alpha":0}
    };
  static Map jsonBulletSplash =
    {
      "maxParticles":5,
      "duration":0,
      "lifeSpan":0.9, "lifespanVariance":0.2,
      "startSize":15, "startSizeVariance":5,
      "finishSize":2, "finishSizeVariance":2,
      "shape":"circle",
      "emitterType":0,
      "location":{"x":0, "y":0},
      "locationVariance":{"x":0, "y":0},
      "speed":100, "speedVariance":10,
      "angle":90, "angleVariance":25,
      "gravity":{"x":0, "y":0},
      "radialAcceleration":20, "radialAccelerationVariance":0,
      "tangentialAcceleration":10, "tangentialAccelerationVariance":0,
      "minRadius":0, "maxRadius":40, "maxRadiusVariance":0,
      "rotatePerSecond":0, "rotatePerSecondVariance":0,
      "compositeOperation":"source-over",
      "startColor":{"red":0, "green":0, "blue":0, "alpha":1},
      "finishColor":{"red":1, "green":1, "blue":1, "alpha":0}
    };
  static Map jsonSpawn =
    { "maxParticles":200,
      "duration":0,
      "lifeSpan":0.9, "lifespanVariance":0.4,
      "startSize":5, "startSizeVariance":2,
      "finishSize":10, "finishSizeVariance":2,
      "shape":"circle",
      "emitterType":1,
      "location":{"x":0, "y":0}, "locationVariance":{"x":0, "y":0},
      "speed":100, "speedVariance":10,
      "angle":0, "angleVariance":360,
      "gravity":{"x":0, "y":100},
      "radialAcceleration":20, "radialAccelerationVariance":0,
      "tangentialAcceleration":10, "tangentialAccelerationVariance":0,
      "minRadius":0, "maxRadius":50, "maxRadiusVariance":0,
      "rotatePerSecond":0, "rotatePerSecondVariance":0,
      "compositeOperation":"source-over",
      "startColor":{"red":1, "green":0.75, "blue":0, "alpha":1},
      "finishColor":{"red":1, "green":0, "blue":0, "alpha":0}
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

    resMgr.addBitmapData("grenade", "${sprites}/bu_grenade.png");
    resMgr.addBitmapData("rocket", "${sprites}/bu_rocket.png");

    resMgr.addBitmapData("crate", "${tiles}/crate.png");
    resMgr.addBitmapData("tree", "${tiles}/tree.png");
    resMgr.addBitmapData("floor", "${tiles}/floor5.png");

    //sounds
    resMgr.addSound("snd_pistol", "${sounds}/pistol.ogg");
    resMgr.addSound("snd_rifle", "${sounds}/rifle.ogg");
    resMgr.addSound("snd_grenade", "${sounds}/grenade.ogg");
    resMgr.addSound("snd_rocket", "${sounds}/rocket.ogg");
    resMgr.addSound("snd_reload", "${sounds}/reload.ogg");

    SoundMixer.soundTransform = new SoundTransform(0.2);

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