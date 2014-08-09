part of gglclient;

class LayerPanel extends DisplayObjectContainer {}

class Arena extends DisplayObjectContainer {
  List<PlayerSprite> players = [];
  PlayerSprite p1;
  LayerPanel playerPanel = new LayerPanel();
  LayerPanel trees = new LayerPanel();
  LayerPanel walls = new LayerPanel();
  num treeScale = 1.5;
  MiniMap miniMap;

  Arena() {
    this.addTo(stage);
  }

  void createMap(num width, num height, List<num> surface) {
    num count = 0;
    for (num i = 0; i < height; i++) {
      for (num j = 0; j < width; j++) {
        num type = surface[count];
        TileSheet tile = new TileSheet(Surface.PASSABLE)
          ..index = count++
          ..x =  (j * TileSheet.SIZE) + TileSheet.SIZE/2
          ..y =  (i * TileSheet.SIZE) + TileSheet.SIZE/2
          ..addTo(this);

        if (type != Surface.PASSABLE) {
          TileSheet layerTile = new TileSheet(type)
              ..x =  (j * TileSheet.SIZE) + TileSheet.SIZE/2
              ..y =  (i * TileSheet.SIZE) + TileSheet.SIZE/2;
          switch(type) {
            case Surface.OBSCURING:
              layerTile.scaleX = layerTile.scaleY = treeScale;
              trees.addChild(layerTile);
              break;
            case Surface.NON_PASSABLE:
              walls.addChild(layerTile);
              break;
          }
        }
      }
    }

    //add border
    for (num i = -1; i <= height; i++) {
      for (num j = -1; j <= width; j++) {
        if (i == -1 || i == height ||
            j == -1 || j == width) {
          /*TileSheet tile = new TileSheet(Surface.OBSCURING)
            ..x = (j * TileSheet.SIZE) + TileSheet.SIZE/2
            ..y =  (i * TileSheet.SIZE) + TileSheet.SIZE/2
            ..scaleX = treeScale
            ..scaleY = treeScale
            ..addTo(trees);*/
          TileSheet groundTile = new TileSheet(Surface.NON_PASSABLE)
            ..x = (j * TileSheet.SIZE) + TileSheet.SIZE/2
            ..y =  (i * TileSheet.SIZE) + TileSheet.SIZE/2
            ..addTo(this);
        }
      }
    }

    /*
    p1 = new PlayerSprite()
      ..move(stage.stageWidth/2, stage.stageHeight/2)
      ..addTo(playerPanel)
      ..nameDisplay.text = "";*/

    playerPanel.addTo(this);
    walls.addTo(this);
    trees.addTo(this);
    miniMap = new MiniMap(width, height, surface);
  }

  void move(num x, num y) {
    this.x = x;
    this.y = y;
    miniMap.miniMove(-x, -y);
  }
}
