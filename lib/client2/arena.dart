part of gglclient2;

class DefaultPanel extends DisplayObjectContainer {}

class Arena extends DisplayObjectContainer {
  num treeScaling = 1.5;
  num main = 0, mainId = 0;
  num mapScale = 20;
  static num size = 100;

  List<num> surfaces;
  List<Bitmap> surfaceBmp = [];
  TextField dbg;
  List<PlayerSprite> sprites = [];
  Map<int, PlayerSprite> players = new Map();
  Shape miniMain;
  DefaultPanel floorPanel, cratePanel, treePanel, playerPanel, miniMap;

  PlayerSprite get mainPlayer {
    return mainId != 0 ? players[mainId] : sprites[main];
  }

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

    floorPanel = new DefaultPanel()..addTo(this);
    playerPanel = new DefaultPanel()..addTo(this);
    cratePanel = new DefaultPanel()..addTo(this);
    treePanel = new DefaultPanel()..addTo(this);

    num count = 0;
    for (num h = 0; h < height; h++) {
      for (num w = 0; w < width; w++) {
        num posY =  (h * size) + size/2;
        num posX =  (w * size) + size/2;

        DefaultPanel panel = floorPanel;
        switch(surfaces[count]) {
          case Surface.NON_PASSABLE: panel = cratePanel; break;
          case Surface.OBSCURING: panel = treePanel; break;
          case Surface.PASSABLE: panel = floorPanel; break;
        }

        if (surfaces[count] == Surface.OBSCURING) {
          loadBmp(Surface.PASSABLE)
              ..x = posX
              ..y = posY
              ..addTo(floorPanel);
        }

        surfaceBmp.add(loadBmp(surfaces[count])
            ..x = posX
            ..y = posY
            ..addTo(panel));

        dbg.text = "floor: ${count + 1}";
        count++;
       }
    }

    for (num i = 0; i < resLoader.playerMax; i++) {
      sprites.add(new PlayerSprite()
        ..x = main == i? stage.stageWidth/2 : 0
        ..y = main == i? stage.stageHeight/2 : 0
        ..visible = main == i? true: false
        ..playerNo = i
        ..addTo(playerPanel)
        );
    }

    createMiniMap(height, width);
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

  void createMiniMap(num height, num width) {
    miniMap = new DefaultPanel();

    num startx = size/mapScale;
    num starty = stage.stageHeight - height * size/mapScale;
    num count = 0;
    for (num h = 0; h < height; h++) {
      for (num w = 0; w < width; w++) {
        num c = Color.Gray;
        switch(surfaces[count]) {
          case Surface.NON_PASSABLE: c = Color.Beige; break;
          case Surface.OBSCURING: c = Color.Green; break;
        }

        Shape s = new Shape()
          ..graphics.rect(
              startx + (w * size/mapScale),
              starty + (h * size/mapScale),
              size/mapScale, size/mapScale)
          ..graphics.fillColor(c)
          ..alpha = .7
          ..pivotX = size/mapScale/2
          ..pivotY = size/mapScale/2
          ..addTo(miniMap);

        count++;
      }
    }

    miniMain = new Shape()
        ..graphics.rect(
            startx, starty,
            size/mapScale, size/mapScale)
        ..graphics.fillColor(Color.Fuchsia)
        ..alpha = .7
        ..pivotX = size/mapScale/2
        ..pivotY = size/mapScale/2
        ..addTo(miniMap);

    miniMap.addTo(this);
  }

  void action(Cmd c) {
    if (!diagnostics.isLogging) dbg.removeFromParent();
    x -= c.moveX * c.ms;
    y -= c.moveY * c.ms;
    miniMap.x += c.moveX * c.ms;
    miniMap.y += c.moveY * c.ms;
    sprites[main].action(c);
    miniMain.x = sprites[main].x/mapScale - size/mapScale/2;
    miniMain.y = sprites[main].y/mapScale - size/mapScale/2;
  }
}

