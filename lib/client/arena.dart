part of gglclient;

class LayerPanel extends DisplayObjectContainer {}

class Arena extends DisplayObjectContainer {
  List<PlayerSprite> players = [];
  List<TileSheet> tiles = [];
  PlayerSprite p1;
  LayerPanel trees = new LayerPanel();
  LayerPanel walls = new LayerPanel();

  Arena() {
    ResourceHandler.init();
    this.addTo(stage);
  }

  void createRandomMap(num width, num height) {
    num baseX = width * TileSheet.SIZE;
    num baseY = height * TileSheet.SIZE;

    num count = 0;
    for (num i = 0; i < width; i++) {
      for (num j = 0; j < height; j++) {
        math.Random rand = new math.Random();
        num chance = rand.nextDouble();
        num type = (chance * 10).toInt();
        TileSheet tile = new TileSheet(type)
          ..index = count++
          ..x =  (j * TileSheet.SIZE)
          ..y =  (i * TileSheet.SIZE);
        switch(type) {
          case 2: trees.addChild(tile); break;
          case 1: walls.addChild(tile); break;
          default: this.addChild(tile);
        }
      }
    }

    p1 = new PlayerSprite()
      ..move(stage.stageWidth/2, stage.stageHeight/2)
      ..addTo(this);

    trees.addTo(this);
    walls.addTo(this);
  }

  void move(num x, num y) {
    this.x = x;
    this.y = y;
  }
}
