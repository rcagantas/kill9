part of gglclient;

class LayerPanel extends DisplayObjectContainer {}

class Arena extends DisplayObjectContainer {
  List<PlayerSprite> players = [];
  List<TileSheet> tiles = [];
  PlayerSprite p1;
  LayerPanel playerPanel = new LayerPanel();
  LayerPanel trees = new LayerPanel();
  LayerPanel walls = new LayerPanel();

  Arena() {
    ResourceHandler.init();
    this.addTo(stage);
  }

  List createRandomMap(num width, num height) {
    num count = 0;

    List<math.Point> nonPassable = new List();


    for (num i = 0; i < width; i++) {
      for (num j = 0; j < height; j++) {
        math.Random rand = new math.Random();
        TileSheet tile = new TileSheet(0)
          ..index = count++
          ..x =  (j * TileSheet.SIZE) + TileSheet.SIZE/2
          ..y =  (i * TileSheet.SIZE) + TileSheet.SIZE/2
          ..addTo(this);

        num chance = rand.nextDouble();
        num type = (chance * 10).toInt();

        // make the middle part passable
        if ((i > 7 && i < 12 ) &&
           (j > 7 && j < 12 )){
          type = 0;
        }

        if (type > 0) {
          TileSheet layerTile = new TileSheet(type)
              ..x =  (j * TileSheet.SIZE) + TileSheet.SIZE/2
              ..y =  (i * TileSheet.SIZE) + TileSheet.SIZE/2;
          switch(type) {
            case 2: trees.addChild(layerTile); break;
            case 1: walls.addChild(layerTile);
                    nonPassable.add(new Point(j,i));
                    break;

          }
        }
      }
    }

    p1 = new PlayerSprite()
      ..move(stage.stageWidth/2, stage.stageHeight/2)
      ..addTo(playerPanel);

    playerPanel.addTo(this);
    trees.addTo(this);
    walls.addTo(this);

    return nonPassable;
  }

  void move(num x, num y) {
    this.x = x;
    this.y = y;
  }
}
