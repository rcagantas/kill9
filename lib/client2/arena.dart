part of gglclient2;

class Arena extends DisplayObjectContainer {
  num main = 0, mainId = 0;
  num treeScaling = 1.5;
  static num size = 100;

  List<num> surfaces;
  List<Bitmap> surfaceBmp = [];
  TextField dbg;
  List<PlayerSprite> sprites = [];

  Map<int, PlayerSprite> players = new Map();
  Map<int, BulletSprite> bullets = new Map();
  Map<int, WeaponDropSprite> drops = new Map();

  Sprite floorPanel, cratePanel, treePanel, playerPanel;
  num mapScale = 20;
  Sprite miniMap;
  Shape miniMain;

  PlayerSprite get mainPlayer {
    return mainId != 0 ? players[mainId] : sprites[main];
  }

  Arena(num width, num height, this.surfaces) {
    dbg = new TextField()
          ..defaultTextFormat = diagnostics.font11
          ..x = 30
          ..y = 60
          ..width = 200
          ..height = 200
          ..wordWrap = true
          ..text = "";

    floorPanel = new Sprite()..addTo(this);
    playerPanel = new Sprite()..addTo(this);
    cratePanel = new Sprite()..addTo(this);
    treePanel = new Sprite()..addTo(this);

    num count = 0;
    for (num h = 0; h < height; h++) {
      for (num w = 0; w < width; w++) {
        num posY =  (h * size) + size/2;
        num posX =  (w * size) + size/2;

        Sprite panel = floorPanel;
        switch(surfaces[count]) {
          case Surface.NON_PASSABLE: panel = cratePanel; break;
          case Surface.OBSCURING: panel = treePanel; break;
          case Surface.PASSABLE: panel = floorPanel; break;
        }

        if (surfaces[count] == Surface.OBSCURING) {
          loadBmp(Surface.PASSABLE)
              ..x = posX
              ..y = posY
              ..addTo(floorPanel);
        }

        surfaceBmp.add(loadBmp(surfaces[count])
            ..x = posX
            ..y = posY
            ..addTo(panel));

        if (diagnostics.isLogging)
          dbg.text = "tile count: ${count + 1}";
        count++;
       }
    }

    for (num i = 0; i < resLoader.playerMax; i++) {
      sprites.add(new PlayerSprite(i)
        ..x = main == i? stage.stageWidth/2 : 0
        ..y = main == i? stage.stageHeight/2 : 0
        ..visible = main == i? true: false
        ..addTo(playerPanel)
        );
    }

    createMiniMap(width, height);
    dbg.addTo(this);
  }

  void createMiniMap(num width, num height) {
    miniMap = new Sprite();
    num startx = 0; //size/mapScale;
    num starty = 0; //stage.stageHeight - height * size/mapScale;
    num count = 0;

    for (num h = 0; h < height; h++) {
      for (num w = 0; w < width; w++) {
        num c = Color.Gray;
        switch(surfaces[count]) {
          case Surface.NON_PASSABLE: c = Color.Beige; break;
          case Surface.OBSCURING: c = Color.Green; break;
        }

        Shape s = new Shape()
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

    miniMain = new Shape()
        ..graphics.rect(
            startx, starty,
            size/mapScale, size/mapScale)
        ..graphics.fillColor(Color.Fuchsia)
        ..alpha = .7
        ..pivotX = size/mapScale/2
        ..pivotY = size/mapScale/2
        ..addTo(miniMap);
    miniMap.addTo(this);
    miniMove();
  }

  void miniMove() {
    if (players[mainId] == null) return;
    num x = players[mainId].x;
    num y = players[mainId].y;
    miniMain.x = x/mapScale - size/mapScale/2;
    miniMain.y = y/mapScale - size/mapScale/2;
    miniMap.x = x - stage.stageWidth/2;
    miniMap.y = y + stage.stageHeight/2 - size;
  }


  Bitmap loadBmp(num type) {
    Bitmap bmp;
    num size = 100;
    math.Random random = new math.Random();
    switch(type) {
      case Surface.PASSABLE: bmp = new Bitmap(resource.getBitmapData("floor")); break;
      case Surface.NON_PASSABLE: bmp = new Bitmap(resource.getBitmapData("crate")); break;
      case Surface.OBSCURING:
        bmp = new Bitmap(resource.getBitmapData("tree"))
          ..scaleX = treeScaling
          ..scaleY = treeScaling;
        break;
    }
    bmp.rotation = type != Surface.PASSABLE?
        (math.PI/2) * random.nextInt(4): bmp.rotation;
    bmp.pivotX = size/2;
    bmp.pivotY = size/2;
    return bmp;
  }

  void action(Cmd c) {
    if (!diagnostics.isLogging) dbg.removeFromParent();
    x -= c.moveX * c.ms;
    y -= c.moveY * c.ms;
    sprites[main].action(c);
    miniMove();
  }

  void updateFrame(Frame pf) {
    mainId = pf.playerId;

    for (BulletSprite b in bullets.values) b.visible = false;
    for (PlayerSprite p in players.values) p.visible = false;
    for (WeaponDropSprite w in drops.values) w.visible = false;

    // if the object isn't in our pool, lazy load it, then use it.
    pf.visibleObjects.forEach((obj) {
      if (obj is ActorInFrame) {
        players.putIfAbsent(obj.id, () {
          return sprites[players.length];
        });

        players[obj.id]
          ..move(obj.x, obj.y, obj.orientation)
          //..toggleFire(obj.isFiring)
          ..walk(obj.isMoving)
          ..switchWeapon(obj.weaponType)
          ..takeDamage(obj.lifeRatio, obj.damageFrom)
          ..name = obj.name
          ..visible = true;

        if (obj.id == mainId) {
          players[obj.id].addTo(playerPanel);
          x = stage.stageWidth/2 - obj.x;
          y = stage.stageHeight/2 - obj.y;
        }

      } else if (obj is BulletInFrame) {
        bullets.putIfAbsent(obj.id, () {
          return new BulletSprite()..addTo(playerPanel);
        });

        bullets[obj.id]
          ..x = obj.x
          ..y = obj.y
          ..rotation = obj.orientation
          ..hitObject(obj.hitObject)
          ..hitPlayer(obj.hitActor)
          ..type = obj.type
          ..visible = true;

        if (players.containsKey(obj.owner))
          players[obj.owner].toggleFire(true);

      } else if (obj is WeaponDropInFrame) {
        drops.putIfAbsent(obj.id, () {
          return new WeaponDropSprite()..addTo(floorPanel);
        })
          ..x = obj.x
          ..y = obj.y
          ..type = obj.weaponType
          ..visible = true;
      }
    });
    miniMove();
  }
}

