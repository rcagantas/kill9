part of giggl;

class Player extends DisplayObjectContainer {
  static final int _strideCount = 6;
  static final List<BitmapData> _bmpStride = [];
  static FlipBook _flipStride = null;

  Player() {
    if (_flipStride == null) {
    for (int i = 0; i < _strideCount; i++)
       resMgr.addBitmapData("stride"+i.toString(), "./res/stride"+i.toString()+".png");
    resMgr.load().then((_) {
      for (int i = 0; i < _strideCount; i++)
        _bmpStride.add(resMgr.getBitmapData("stride"+i.toString()));
      _flipStride = new FlipBook(_bmpStride, 10, true)
        ..x = stage.stageWidth/2 - _bmpStride[0].width/2
        ..y = stage.stageHeight/2 - _bmpStride[0].height/2
        ..addTo(this);
      stage.juggler.add(_flipStride);
    });
    }
  }

  void move(int x, int y) {
    _flipStride.setTransform(x, y);
  }

  void play() {
    _flipStride.play();
  }
}