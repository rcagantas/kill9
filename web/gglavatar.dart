import 'package:stagexl/stagexl.dart';

class GglAvatar extends DisplayObjectContainer {
  Stage stage;
  ResourceManager _resMgr;
  static final int _strideCount = 6;
  List<BitmapData> _bmpStride = [];

  GglAvatar(this.stage) {
    _resMgr = new ResourceManager();
    for (int i = 0; i < _strideCount; i++)
       _resMgr.addBitmapData("stride"+i.toString(), "./res/stride"+i.toString()+".png");
    _resMgr.load().then((_) {
      for (int i = 0; i < _strideCount; i++)
        _bmpStride.add(_resMgr.getBitmapData("stride"+i.toString()));
      var flipBook = new FlipBook(_bmpStride, 10, true)
        ..x = 100
        ..y = 100
        ..play()
        ..addTo(this);

      stage.juggler.add(flipBook);
    });
  }
}