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
        ..x = 50
        ..y = 50
        ..addTo(this);

      stage.addChild(this);
      renderLoop.addStage(stage);
      stage.onKeyDown.listen(onFrame);
    });
  }

  Random rand = new Random();

  void onFrame(Event event) {
    int incx = rand.nextInt(2);
    int incy = rand.nextInt(2);
    double incr = .1;

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
