import 'package:stagexl/stagexl.dart';

/**
 * examples: https://github.com/bp74/StageXL_Samples/
 * forums: http://www.stagexl.org/forum.html
 */
class GglClient {
  Stage _stage;
  Map<int, bool> _keyState = new Map<int, bool>();

  GglClient(this._stage) {
    _setupKeyListener();
  }
  
  void drawCircle() {
    var shape = new Shape();
    shape.graphics.circle(100, 100, 60);
    shape.graphics.fillColor(Color.Red);
    _stage.addChild(shape);
  }
  
  void _setupKeyListener() {
    _stage.focus = _stage;
    _stage.onKeyDown.listen((e) => _keyState[e.keyCode] = true);
    _stage.onKeyUp.listen((e) => _keyState[e.keyCode] = false);
    _stage.onEnterFrame.listen((e) => print(_keyState));    
  }
}
