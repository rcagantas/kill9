part of giggl;

/**
 * examples: https://github.com/bp74/StageXL_Samples/
 * forums: http://www.stagexl.org/forum.html
 * http://www.stagexl.org/demos/performance.html
 *
 */
class Client extends DisplayObjectContainer {
  Actor p1, p2;

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
      //stage.onKeyDown.listen(onFrameRandom);
      stage.onEnterFrame.listen(onFrameInput);
    });
  }

  InputHandler kb = new InputHandler();
  void onFrameInput(Event event) {
    if (p1 == null) return;
    num ix, iy, inc = 2;
    ix = iy = 0;
    if (kb.keyState[87]) { iy = inc; }
    if (kb.keyState[83]) { iy = -inc; }
    if (kb.keyState[65]) { ix = inc; }
    if (kb.keyState[68]) { ix = -inc; }
    p1.move(p1.x - ix, p1.y - iy);
  }

  math.Random rand = new math.Random();
  void onFrameRandom(Event event) {
    num incx = rand.nextInt(2);
    num incy = rand.nextInt(2);
    num incr = .1;

    incx = rand.nextBool()? incx * 1: incx * -1;
    incy = rand.nextBool()? incy * 1: incy * -1;
    incr = rand.nextBool()? incr * 1: incr * -1;
    //p1.x += incx; p1.y += incy;
    p1.rotation += incr;

    print("${p1.x} ${incx}: ${p1.y} ${incy}: ${p1.rotation} ${incr}");

    p1.x = p1.x > stage.stageWidth? 0: p1.x;
    p1.x = p1.x < 0? stage.stageWidth: p1.x;
    p1.y = p1.y > stage.stageHeight? 0: p1.y;
    p1.y = p1.y < 0? stage.stageHeight: p1.y;
  }
}
