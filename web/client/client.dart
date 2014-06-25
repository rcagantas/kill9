part of giggl;

/**
 * examples: https://github.com/bp74/StageXL_Samples/
 * forums: http://www.stagexl.org/forum.html
 * http://www.stagexl.org/demos/performance.html
 *
 */
class Client extends DisplayObjectContainer {
  List<Actor> actors = [];
  Actor p1;

  Client() {
    ResourceHandler.init();
    _setupResource();
  }

  void _setupResource() {
    resMgr.load().then((_) {

      p1 = new Actor()
        ..move(stage.stageWidth/2, stage.stageHeight/2)
        ..addTo(this);

      stage.addChild(this);
      renderLoop.addStage(stage);
    });
  }
}
