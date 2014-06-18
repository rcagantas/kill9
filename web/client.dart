part of giggl;

/**
 * examples: https://github.com/bp74/StageXL_Samples/
 * forums: http://www.stagexl.org/forum.html
 * http://www.stagexl.org/demos/performance.html
 *
 */
class Client extends DisplayObjectContainer {
  Player p1, p2;

  Client() {
    ResourceHandler.init();
    _setupResource();
  }

  void _setupResource() {
    resMgr.load().then((_) {

      p1 = new Player()
        ..x = 50
        ..y = 50
        ..play()
        ..addTo(this);
      p1.rotation = .5;

      p2 = new Player()
        ..x = 100
        ..y = 100
        ..play()
        ..addTo(this);

      stage.addChild(this);
      renderLoop.addStage(stage);
      this.onEnterFrame.listen(onFrame);
    });
  }

  void onFrame(EnterFrameEvent event) {
    p1.x++; p1.y--;
    p1.x = p1.x > stage.stageWidth? 0: p1.x;
    p1.x = p1.x < 0? stage.stageWidth: p1.x;
    p1.y = p1.y > stage.stageHeight? 0: p1.y;
    p1.y = p1.y < 0? stage.stageHeight: p1.y;
  }
}
