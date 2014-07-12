part of gglclient;

class MiniMap {
  Shape point;
  num starty;
  num div = 20;

  MiniMap(num width, num height, List<num> surface) {
    num startx = 0, count = 0;
    starty = stage.stageHeight - height * TileSheet.SIZE/div;
    for (num i = 0; i < height; i++) {
      for (num j = 0; j < width; j++) {
        num t = surface[count++];
        num c = Color.Gray;
        switch(t) {
          case Surface.NON_PASSABLE: c = Color.Beige; break;
          case Surface.OBSCURING: c = Color.Green; break;
        }
        Shape s = new Shape()
          ..graphics.rect(
              j * (TileSheet.SIZE/div),
              starty + (i * TileSheet.SIZE/div),
              TileSheet.SIZE/div, TileSheet.SIZE/div)
          ..graphics.fillColor(c)
          ..addTo(stage);
      }
    }

    point = new Shape()
      ..graphics.circle(0, starty, 5)
      ..graphics.fillColor(Color.Fuchsia)
      ..addTo(stage);
  }

  void miniMove(num x, num y) {
    point.x = (div/2 + 3) + (x/div);
    point.y = (div/2 + 3) + (y/div);
  }
}