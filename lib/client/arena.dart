part of gglclient;

class LayerPanel extends DisplayObjectContainer {}

class Arena extends DisplayObjectContainer {
  List<PlayerSprite> players = [];
  PlayerSprite p1;
  LayerPanel playerPanel = new LayerPanel();
  LayerPanel trees = new LayerPanel();
  LayerPanel walls = new LayerPanel();
  num treeScale = 1.5;

  Arena() {
    ResourceHandler.init();
    this.addTo(stage);
  }

  void createMap(num width, num height, List<num> surface) {
    num count = 0;
    for (num i = 0; i < width; i++) {
      for (num j = 0; j < height; j++) {
        num type = surface[count];
        TileSheet tile = new TileSheet(0)
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

    p1 = new PlayerSprite()
      ..move(stage.stageWidth/2, stage.stageHeight/2)
      ..addTo(playerPanel);

    playerPanel.addTo(this);
    walls.addTo(this);
    trees.addTo(this);
  }

  void move(num x, num y) {
    this.x = x;
    this.y = y;
  }
}
