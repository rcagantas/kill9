part of giggl;

/**
 * examples: https://github.com/bp74/StageXL_Samples/
 * forums: http://www.stagexl.org/forum.html
 * http://www.stagexl.org/demos/performance.html
 *
 */
class Client extends DisplayObjectContainer {
  Actor p1, p2;
  InputHandler kb = new InputHandler()
    ..propagate = false;

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
      stage.onEnterFrame.listen(onFrame);
    });
  }

  void onFrame(Event e) {
    if (p1 == null) return;
    num ix = 0, iy = 0, ih = 0, it = 0, inc = 2, rinc = 0.1;
    if (kb.keyState[87]) { iy = inc; }
    if (kb.keyState[83]) { iy = -inc; }
    if (kb.keyState[65]) { ix = inc; }
    if (kb.keyState[68]) { ix = -inc; }
    if (kb.keyState[37]) { it = -rinc; }
    if (kb.keyState[39]) { it = rinc; }
    if (kb.keyState[40]) { p1.cycleWeapon(); }

    p1.move(p1.x - ix, p1.y - iy);
    p1.torsoRotate(it);
  }
}
