part of gglclient2;

class ParticleLoader {
  static Map splatter =
    {
     "maxParticles":30,
     "duration":0,
     "lifeSpan":0.5, "lifespanVariance":0.1,
     "startSize":15, "startSizeVariance":5,
     "finishSize":2, "finishSizeVariance":2,
     "shape":"circle",
     "emitterType":0,
     "location":{"x":0, "y":0},
     "locationVariance":{"x":0, "y":0},
     "speed":200, "speedVariance":10,
     "angle":-90, "angleVariance":20,
     "gravity":{"x":0, "y":0},
     "radialAcceleration":20, "radialAccelerationVariance":0,
     "tangentialAcceleration":10, "tangentialAccelerationVariance":0,
     "minRadius":0, "maxRadius":100, "maxRadiusVariance":0,
     "rotatePerSecond":0, "rotatePerSecondVariance":0,
     "compositeOperation":"source-over",
     "startColor":{"red":.5, "green":0, "blue":0, "alpha":1},
     "finishColor":{"red":.5, "green":0, "blue":0, "alpha":.25}
   };

  static Map spawn =
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
}