part of giggl;

/**
 * examples: https://github.com/bp74/StageXL_Samples/
 * forums: http://www.stagexl.org/forum.html
 * http://www.stagexl.org/demos/performance.html
 *
 * TODO Player should be an animatable.
 */
class Client extends DisplayObjectContainer {
  Client() {
    ResourceHandler.init();
    renderLoop.addStage(stage);
    _setupResource();
  }

  void _setupResource() {
    resMgr.load().then((_) {

      Player x = new Player()
        ..x = 100
        ..y = 100
        ..play()
        ..addTo(this);
      x.rotation = 1;

      Player y = new Player()
        ..x = 250
        ..y = 250
        ..play()
        ..addTo(this);


      stage.addChild(this);
    });
  }
}
