import 'package:stagexl/stagexl.dart';
import 'dart:html' as html;
import 'gglavatar.dart';

/**
 * examples: https://github.com/bp74/StageXL_Samples/
 * forums: http://www.stagexl.org/forum.html
 */
class GglClient {
  Map<int, bool> _keyState = new Map<int, bool>();
  ResourceManager _resMgr;
  Stage stage;

  GglClient(this.stage) {
    _setupResource();
    _setupKeyListener();
  }

  void _setupResource() {
    _resMgr = new ResourceManager()
      ..addBitmapData("idle", "./res/man_idle.png");
    _resMgr
      .load()
      .then((_) {
        stage.addChild(new GglAvatar(stage));
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
}
