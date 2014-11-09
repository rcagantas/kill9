part of gglclient2;

class DefaultPanel extends DisplayObjectContainer {}

class Arena extends DisplayObjectContainer {
  List<num> surfaces;
  List<Bitmap> surfaceBmp = [];
  num treeScaling = 1.5;
  TextField dbg;

  num main = 0;
  List<PlayerSprite> players = [];

  DefaultPanel floorPanel = new DefaultPanel();
  DefaultPanel cratePanel = new DefaultPanel();
  DefaultPanel treePanel = new DefaultPanel();
  DefaultPanel playerPanel = new DefaultPanel();

  Arena(num width, num height, this.surfaces) {
    dbg = new TextField()
          ..defaultTextFormat = diagnostics.font11
          ..x = 30
          ..y = 60
          ..width = 200
          ..height = 200
          ..wordWrap = true
          ..text = "tiles: "
          ..addTo(diagnostics);

    floorPanel.addTo(this);
    playerPanel.addTo(this);
    cratePanel.addTo(this);
    treePanel.addTo(this);

    num count = 0;
    for (num h = 0; h < height; h++) {
      for (num w = 0; w < width; w++) {
        num posY =  (h * TileSheet.SIZE) + TileSheet.SIZE/2;
        num posX =  (w * TileSheet.SIZE) + TileSheet.SIZE/2;
        DefaultPanel panel = floorPanel;
        switch(surfaces[count]) {
          case Surface.NON_PASSABLE: panel = cratePanel; break;
          case Surface.OBSCURING: panel = treePanel; break;
        }

        surfaceBmp.add(loadBmp(surfaces[count])
            ..x = posX
            ..y = posY
            ..addTo(panel));

        if (surfaces[count] != Surface.PASSABLE) {
          loadBmp(Surface.PASSABLE)
              ..x = posX
              ..y = posY
              ..addTo(floorPanel);
        }

        dbg.text = "floor: ${count + 1}";
        count++;
       }
    }

    for (num i = 0; i < resLoader.playerMax; i++) {
      players.add(new PlayerSprite()
        ..x = main == i? stage.stageWidth/2 : 0
        ..y = main == i? stage.stageHeight/2 : 0
        ..visible = main == i? true: false
        ..playerNo = i
        ..addTo(playerPanel)
        );
    }
  }

  Bitmap loadBmp(num type) {
    Bitmap bmp;
    num size = 100;
    math.Random random = new math.Random();
    switch(type) {
      case Surface.PASSABLE: bmp = new Bitmap(resource.getBitmapData("floor")); break;
      case Surface.NON_PASSABLE: bmp = new Bitmap(resource.getBitmapData("crate")); break;
      case Surface.OBSCURING:
        bmp = new Bitmap(resource.getBitmapData("tree"))
          ..scaleX = treeScaling
          ..scaleY = treeScaling;
        break;
    }
    bmp.rotation = type != Surface.PASSABLE?
        (math.PI/2) * random.nextInt(4): bmp.rotation;
    bmp.pivotX = size/2;
    bmp.pivotY = size/2;
    return bmp;
  }
}

