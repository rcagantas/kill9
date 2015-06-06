part of gglclient2;

class HudLayer extends DisplayObjectContainer {
  List<num> surfaces;
  Sprite miniMap;
  List<String> weaponNames = ['pistol', 'rifle', 'grenade', 'rocket'];
  List<Sprite> container = new List<Sprite>();
  List<TextField> ammoText = new List<TextField>();
  TextField killCount;

  Shape miniMain;
  Map<num, Shape> drops = new Map<num, Shape>();
  Map<num, Sprite> slots = new Map<num, Sprite>();

  static final num mapScale = 20;
  static final num size = 100;
  static final num center = 50;
  static final num weaponAlpha = .60;

  HudLayer(num width, num height, this.surfaces) {
    createMiniMap(width, height);

    TextFormat tf = new TextFormat('Lato', 25, Color.White, align:TextFormatAlign.CENTER);
    for (int i = 0; i < weaponNames.length; i++) {
      ammoText.add(
          new TextField()
            ..defaultTextFormat = tf
            ..x = 50);
      Sprite s = new Sprite()
          ..addChild(
              new Bitmap(resource.getBitmapData("wd_${weaponNames[i]}"))
                  ..rotation = -.785)
          ..addChild(ammoText[i])
          ..y = stage.stageHeight - center
          ..alpha = weaponAlpha;
      container.add(s);
    }

    killCount = new TextField()
      ..defaultTextFormat = tf
      ..x = stage.stageWidth - 100
      ..y = 50
      ..addTo(this);
  }

  void createMiniMap(num width, num height) {
    miniMap = new Sprite();
    num count = 0;

    for (num h = 0; h < height; h++) {
      for (num w = 0; w < width; w++) {
        num c = Color.Gray;
        switch(surfaces[count]) {
          case Surface.NON_PASSABLE: c = Color.Beige; break;
          case Surface.OBSCURING: c = Color.Green; break;
        }
        shapeFactory(w, h, c);
        count++;
      }
    }

    miniMap.addTo(this);
    miniMap.x = 10;
    miniMap.y = stage.stageHeight - miniMap.height - 8;

    miniMain = shapeFactory(x, y, Color.Fuchsia);
  }

  Shape shapeFactory(num x, num y, num color) {
    return
        new Shape()
                ..graphics.rect(
                    x * size/mapScale,
                    y * size/mapScale,
                    size/mapScale, size/mapScale)
                ..graphics.fillColor(color)
                ..alpha = .7
                ..pivotX = size/mapScale/2
                ..pivotY = size/mapScale/2
                ..addTo(miniMap);
  }

  void miniMove(Shape s, num x, num y) {
    s.x = x/mapScale - size/mapScale/2;
    s.y = y/mapScale - size/mapScale/2;
  }

  void updateFrame(Frame pf) {
    num mainId = pf.playerId;

    for (Shape d in drops.values) d.visible = false;
    for (Sprite s in container) s.alpha = weaponAlpha;

    pf.visibleObjects.forEach((obj) {
      if (obj is ActorInFrame) {
        if (obj.id == mainId) {
          miniMove(miniMain, obj.x, obj.y);
          slots.putIfAbsent(obj.weaponType, () {
            container[obj.weaponType].x = 65 + (slots.length * 80);
            container[obj.weaponType].addTo(this);
            return container[obj.weaponType];
          });
          container[obj.weaponType].alpha = 1;
          ammoText[obj.weaponType].text = "${obj.weaponAmmo}";
          killCount.text = "${obj.killCount}";
        }
      } else if (obj is WeaponDropInFrame) {
        drops.putIfAbsent(obj.id, () {
          return shapeFactory(0, 0, Color.DarkRed);
        });
        drops[obj.id].visible = true;
        miniMove(drops[obj.id], obj.x, obj.y);
      }

    });
  }
}
