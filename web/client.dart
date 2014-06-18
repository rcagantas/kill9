part of giggl;

/**
 * examples: https://github.com/bp74/StageXL_Samples/
 * forums: http://www.stagexl.org/forum.html
 * TODO: this should be the display object.
 * Player should be an animatable. Follow examples here:
 * http://www.stagexl.org/demos/performance.html
 */
class Client {
  Client() {
    _setupResource();
  }

  void _setupResource() {
    Player x = new Player();
    resMgr
      .load()
      .then((_) {
        stage.addChild(x);

        x.play();
        x.move(100, 100);
      })
      .catchError((e) => print(e));
  }

  void startRender() {
    var renderLoop = new RenderLoop();
    renderLoop.addStage(stage);
  }
}
