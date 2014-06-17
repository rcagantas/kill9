part of giggl;

/**
 * examples: https://github.com/bp74/StageXL_Samples/
 * forums: http://www.stagexl.org/forum.html
 * TODO: this should be the display object.
 * Player should be an animatable. Follow examples here:
 * http://www.stagexl.org/demos/performance.html
 */
class Client {
  Map<int, bool> _keyState = new Map<int, bool>();

  Client() {
    _setupResource();
    _setupKeyListener();
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

  void _setupKeyListener() {
    stage.focus = stage;
    stage.onKeyDown.listen((e) => _keyState[e.keyCode] = true);
    stage.onKeyUp.listen((e) => _keyState[e.keyCode] = false);
    //_stage.onEnterFrame.listen((e) => print(_keyState));
    stage.onEnterFrame.listen((EnterFrameEvent e) {
      var fps = null;
      fps = fps == null
          ? 1.00 / e.passedTime
          : 0.05 / e.passedTime + 0.95 * fps;
      html.querySelector('#fps').innerHtml = 'fps: ${fps.round()}';
    });
  }

  void startRender() {
    var renderLoop = new RenderLoop();
    renderLoop.addStage(stage);
  }
}
