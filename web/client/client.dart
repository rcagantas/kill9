part of giggl;

class LayerAbove extends DisplayObjectContainer {

}

class Client extends DisplayObjectContainer {
  List<Player> players = [];
  List<TileSheet> tiles = [];
  Player p1;
  LayerAbove above = new LayerAbove();

  Client() {
    ResourceHandler.init();
    this.addTo(stage);
  }

  void createRandomMap(num x, num y) {
    num count = 0;
    for (int i = 0; i < x; i++) {
      for (int j = 0; j < y; j++) {
        math.Random rand = new math.Random();
        num type = rand.nextInt(3);
        TileSheet tile = new TileSheet(type)
          ..index = count++
          ..x = j * TileSheet.SIZE
          ..y = i * TileSheet.SIZE
          ..addTo(type == 2? above : this);
        if (tile.type == 2) tile.alpha = 0;
      }
    }

    p1 = new Player()
      ..move(stage.stageWidth/2, stage.stageHeight/2)
      ..addTo(this);

    above.addTo(this);
  }
}
