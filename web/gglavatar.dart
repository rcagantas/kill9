part of giggl;

class GglAvatar extends DisplayObjectContainer {
  Stage _stage = GglStage.getInstance();
  ResourceManager _resMgr;
  static final int _strideCount = 6;
  List<BitmapData> _bmpStride = [];

  GglAvatar() {
    _resMgr = new ResourceManager();
    for (int i = 0; i < _strideCount; i++)
       _resMgr.addBitmapData("stride"+i.toString(), "./res/stride"+i.toString()+".png");
    _resMgr.load().then((_) {
      for (int i = 0; i < _strideCount; i++)
        _bmpStride.add(_resMgr.getBitmapData("stride"+i.toString()));
      var flipBook = new FlipBook(_bmpStride, 10, true)
        ..x = _stage.stageWidth/2 - _bmpStride[0].width/2
        ..y = _stage.stageHeight/2 - _bmpStride[0].height/2
        ..play()
        ..addTo(this);

      _stage.juggler.add(flipBook);
    });
  }
}