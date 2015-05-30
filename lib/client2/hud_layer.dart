part of gglclient2;

class HudLayer extends DisplayObjectContainer {
  List<num> surfaces;
  Sprite miniMap;
  Shape miniMain;

  static final num mapScale = 20;
  static final num size = 100;

  HudLayer(num width, num height, this.surfaces) {
    createMiniMap(width, height);
  }

  void createMiniMap(num width, num height) {
    miniMap = new Sprite();
    num startx = 0;
    num starty = 0;
    num count = 0;

    for (num h = 0; h < height; h++) {
      for (num w = 0; w < width; w++) {
        num c = Color.Gray;
        switch(surfaces[count]) {
          case Surface.NON_PASSABLE: c = Color.Beige; break;
          case Surface.OBSCURING: c = Color.Green; break;
        }

        new Shape()
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

    miniMap.addTo(this);
    miniMap.x = 10;
    miniMap.y = stage.stageHeight - miniMap.height - 8;

    miniMain = new Shape()
        ..graphics.rect(
            startx, starty,
            size/mapScale, size/mapScale)
        ..graphics.fillColor(Color.Fuchsia)
        ..alpha = .7
        ..pivotX = size/mapScale/2
        ..pivotY = size/mapScale/2
        ..addTo(miniMap);
  }

  void miniMove(num x, num y) {
    miniMain.x = x/mapScale - size/mapScale/2;
    miniMain.y = y/mapScale - size/mapScale/2;
  }
}
