part of gglclient2;

class Arena extends DisplayObjectContainer {
  List<num> surfaces;
  final List<String> pnlNames =
      ['floor', 'death', 'player', 'collision', 'crate', 'tree'];
  Map<String, Sprite> panel = new Map<String, Sprite>();
  HudLayer hud;

  Map<int, PlayerSprite> players = new Map();
  Map<int, BulletSprite> bullets = new Map();
  Map<int, DropSprite> drops = new Map();

  Arena(num width, num height, this.surfaces) {

    for (String pnlName in pnlNames) {
      panel[pnlName] = new Sprite()..addTo(this);
    }

    num count = 0;
    for (num h = 0; h < height; h++) {
      for (num w = 0; w < width; w++) {
        // put the floor everywhere
        addSurface(Surface.PASSABLE, w, h);
        if (surfaces[count] != Surface.PASSABLE)
          addSurface(surfaces[count], w, h);
        count++;
      }
    }
  }

  void addSurface(num surface, num x, num y) {
    String name;
    switch(surface) {
      case Surface.NON_PASSABLE: name = "crate"; break;
      case Surface.OBSCURING: name = "tree"; break;
      default: name = "floor";
    }

    Sprite pnl = panel[name];
    Bitmap bmp = new Bitmap(resource.getBitmapData("t_$name"));
    num size = bmp.width;
    num posSize = 100;
    bmp.x = (x * posSize) + posSize/2;
    bmp.y = (y * posSize) + posSize/2;
    bmp.pivotX = size/2;
    bmp.pivotY = size/2;

    math.Random random = new math.Random();
    bmp.rotation = name != "floor"? (math.PI/2) * random.nextInt(4) : 0;
    bmp.addTo(pnl);
  }

  void action(Cmd c) {
    x -= c.moveX * c.ms;
    y -= c.moveY * c.ms;
  }

  void updateFrame(Frame pf) {
    for (PlayerSprite p in players.values) p.visible = false;
    for (BulletSprite b in bullets.values) b.pnlBullet.visible = false;
    for (DropSprite d in drops.values) d.visible = false;

    pf.visibleObjects.forEach((obj) {
      if (obj is ActorInFrame) {
        players.putIfAbsent(obj.id, () {
          PlayerSprite p = new PlayerSprite(obj.index);
          p.addTo(panel['player']);
          p.pnlDead.addTo(panel['death']);
          return p;
        });

        players[obj.id]
          ..move(obj.x, obj.y, obj.orientation)
          ..walk(obj.isMoving)
          ..takeDamage(obj.lifeRatio, obj.damageFrom)
          ..switchWeapon(obj.weaponType)
          ..ammoCount = obj.weaponAmmo
          // only for empty clips
          ..toggleFire(obj.isFiring && obj.weaponAmmo == 0)
          ..visible = true
          ;

        if (obj.id == pf.playerId) {
          x = stage.stageWidth/2 - obj.x;
          y = stage.stageHeight/2 - obj.y;
          //if (hud != null) hud.miniMove(obj.x, obj.y);
        }
      } else if (obj is BulletInFrame) {
        bullets.putIfAbsent(obj.id, () {
           BulletSprite b = new BulletSprite();
           b.addTo(panel['player']);
           b.pnlCollision.addTo(panel['collision']);
           return b;
        });
        bullets[obj.id]
          ..addTo(panel['player'])
          ..move(obj.x, obj.y)
          ..rotation = obj.orientation
          ..setBulletType(obj.type)
          ..hit(obj.hitObject)
          ..pnlBullet.visible = true
          ;

        if (players.containsKey(obj.owner))
          players[obj.owner].toggleFire(true);

      } else if (obj is WeaponDropInFrame) {
        drops.putIfAbsent(obj.id, () {
          return new DropSprite()..addTo(panel['player']);
        });
        drops[obj.id]
          ..x = obj.x
          ..y = obj.y
          ..type = obj.weaponType
          ..visible = true;
      }
    });

    if (hud != null) hud.updateFrame(pf);
  }
}