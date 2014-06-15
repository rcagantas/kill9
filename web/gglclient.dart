import 'package:stagexl/stagexl.dart';

/**
 * examples: https://github.com/bp74/StageXL_Samples/
 * forums: http://www.stagexl.org/forum.html
 */
class GglClient {
  Stage _stage;
  Map<int, bool> _keyState = new Map<int, bool>();
  ResourceManager _resMgr;


  GglClient(this._stage) {
    drawCircle();
    _setupResource();
    _setupKeyListener();
  }

  void _setupResource() {
    _resMgr = new ResourceManager()
      ..addBitmapData("idle", "./res/man_idle.png");
    _resMgr.load().then((_) {
      var idle = new Bitmap(_resMgr.getBitmapData("idle"));
      idle.setTransform(100, 100);
      _stage.addChild(idle);
    });

  }

  void drawCircle() {
    var shape = new Shape();
    shape.graphics.circle(
        _stage.stageWidth/2,
        _stage.stageHeight/2,
        20);
    shape.graphics.fillColor(Color.Red);
    _stage.addChild(shape);
  }

  void _setupKeyListener() {
    _stage.focus = _stage;
    _stage.onKeyDown.listen((e) => _keyState[e.keyCode] = true);
    _stage.onKeyUp.listen((e) => _keyState[e.keyCode] = false);
    //_stage.onEnterFrame.listen((e) => print(_keyState));
  }
}
