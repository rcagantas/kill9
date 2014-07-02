part of gglclient;

class ParallaxPanel extends DisplayObjectContainer {
  num slide = 1;
  ParallaxPanel(this.slide);
}

class Client extends DisplayObjectContainer {
  List<Player> players = [];
  List<TileSheet> tiles = [];
  Player p1;
  ParallaxPanel trees = new ParallaxPanel(0.005);
  ParallaxPanel walls = new ParallaxPanel(0.01);

  Client() {
    ResourceHandler.init();
    stage.backgroundColor = Color.Black;
    this.addTo(stage);
  }

  void createRandomMap(num width, num height) {
    num baseX = width * TileSheet.SIZE;
    num baseY = height * TileSheet.SIZE;

    num startx = stage.stageWidth/2 - baseX/2;
    num starty = stage.stageHeight/2 - baseY/2;
    num count = 0;
    for (num i = 0; i < width; i++) {
      for (num j = 0; j < height; j++) {
        math.Random rand = new math.Random();
        num chance = rand.nextDouble();
        num type = (chance * 10).toInt();
        TileSheet tile = new TileSheet(type)
          ..index = count++
          ..x = startx + (j * TileSheet.SIZE)
          ..y = starty + (i * TileSheet.SIZE);
        switch(type) {
          case 2: trees.addChild(tile); break;
          case 1: walls.addChild(tile); break;
          default: this.addChild(tile);
        }
      }
    }

    p1 = new Player()
      ..move(stage.stageWidth/2, stage.stageHeight/2)
      ..addTo(this);

    walls.addTo(this);
    trees.addTo(this);
    trees.scaleX = trees.scaleY = 1 + trees.slide;
    walls.scaleX = walls.scaleY = 1 + walls.slide;

    trees.x = baseX - (baseX * trees.scaleX);
    trees.y = baseY - (baseY * trees.scaleY);
    walls.x = baseX - (baseX * walls.scaleX);
    walls.y = baseY - (baseY * walls.scaleY);
    print(walls.x);
  }

  void move(num x, num y) {
    this.x = x;
    this.y = y;
    walls.x = x * walls.slide - 5;
    walls.y = y * walls.slide - 5;
    trees.x = x * trees.slide - 3;
    trees.y = y * trees.slide - 3;

  }
}
