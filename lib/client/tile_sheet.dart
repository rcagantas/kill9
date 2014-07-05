part of gglclient;

/**
 * 0: concrete
 * 1: wall
 * 2: shrubbery
 */
class TileSheet extends DisplayObjectContainer {
  num type = 0;
  static final num SIZE = 100;
  Shape shape;
  TextField dbg;
  num _index;
  Bitmap crate,tree,floor;

  TileSheet(num type) {
    num color = Color.LightGray;
    switch(type) {
      case 1: color = Color.DarkGray; break;
      case 2: color = Color.LightGreen; break;
    }

    math.Random ran = new math.Random();
    if (type == 0) {
      floor = new Bitmap(resMgr.getBitmapData("floor"))
        ..pivotX = SIZE/2
        ..pivotY = SIZE/2
        ..addTo(this);
    } else if (type == 1) {
      crate = new Bitmap(resMgr.getBitmapData("crate"))
        ..pivotX = SIZE/2
        ..pivotY = SIZE/2
        ..rotation = (math.PI/2) * ran.nextInt(4)
        ..addTo(this);
    } else if (type == 2) {
      tree = new Bitmap(resMgr.getBitmapData("tree"))
        ..pivotX = SIZE/2
        ..pivotY = SIZE/2
        ..rotation = (math.PI/2) * ran.nextInt(4)
        ..addTo(this);
    } else {
      shape = new Shape()
        ..graphics.rect(x - SIZE/2, y - SIZE/2, SIZE, SIZE)
        ..graphics.strokeColor(color, 1)
        ..graphics.fillColor(color)
        ..addTo(this);
    }

    TextFormat tf = new TextFormat('Helvetica', 10, Color.White);
    dbg = new TextField()
      ..x = 5
      ..y = 5
      ..defaultTextFormat = tf
      ..wordWrap = true
      ..addTo(this);
  }

  num get index { return _index; }
  void set index(num i) {
    _index = i;
    //dbg.text = "$i";
  }
}