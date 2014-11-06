part of gglclient2;

class PlayerSprite extends DisplayObjectContainer {
  static const num center = 48.5; //center of player tile
  static const num offset = 8;
  static num totalPlayers = -1;
  static num hpRadius = 33;

  num playerNo;
  TextField dbg;
  FlipBook legs;
  Bitmap torso, head;
  List<Bitmap> weapon = [];
  Shape hpBar;
  num currentWeapon = 0;
  bool _isFiring = false;

  PlayerSprite() {
    playerNo = totalPlayers + 1 < resLoader.playerMax ?
        ++totalPlayers : resLoader.playerMax;
    dbg = new TextField()
             ..defaultTextFormat = diagnostics.font11
             ..width = 200
             ..height = 200
             ..wordWrap = true
             ..text = "p:";
    diagnostics.addChild(dbg);

    List<BitmapData> bmpStride = [];
    for (num i = 0; i < 6; i++)
      bmpStride.add(resource.getBitmapData("ac_stride$i"));

    hpBar = new Shape()
      ..pivotX = center
      ..pivotY = center
      ..rotation = math.PI/2
      ..graphics.arc(center, center, hpRadius, -math.PI/4, math.PI/4, false)
      ..graphics.strokeColor(Color.YellowGreen, 4)
      ..addTo(this);


    legs = new FlipBook(bmpStride, 10)
      ..x = -offset
      ..y = offset
      ..pivotX = center - offset
      ..pivotY = center + offset
      ..gotoAndStop(0)
      ..addTo(this);
    stage.juggler.add(legs);

    torso = new Bitmap(resource.getBitmapData("ac${playerNo}_torso"))
      ..pivotX = center
      ..pivotY = center
      ..addTo(this);

    for (String weaponName in resLoader.weaponNames) {
      weapon.add(
        new Bitmap(resource.getBitmapData("ac_$weaponName"))
          ..pivotX = center
          ..pivotY = center
          ..visible = weapon.isEmpty? true: false
          ..addTo(this)
      );
    }

    head = new Bitmap(resource.getBitmapData("ac_head"))
      ..pivotX = center
      ..pivotY = center
      ..addTo(this);
  }

  /** there's probably easier ways to do this. */
  num peg180(num val) {
    num max = math.PI;
    num min = -math.PI;
    val -= min;
    max -= min;
    if (max == 0) return min;
    val = val % max;
    val += min;
    while (val < min) val += max;
    return val;
  }

  void fixLegRotation(num x, num y) {
    num dx = x - this.x;
    num dy = y - this.y;
    if (dx == 0 && dy == 0) return;
    num hrad = math.atan2(dy, dx) + math.PI/2;
    num trad = this.rotation;

    num val = peg180(hrad - trad);
    val = val.abs() > math.PI/2? val - math.PI: val;
    legs.rotation = peg180(val);
  }

  void move(num x, num y, num r) {
    fixLegRotation(x, y);
    this.x = x; this.y = y;
    this.rotation = peg180(r);
    dbg.x = this.x + 30; dbg.y = this.y + 30;
    debug();
  }

  void walk(bool walk) {
    if (walk && !legs.playing) legs.play();
    else if (!walk) legs.gotoAndStop(0);
  }

  void fire() {
    if (_isFiring) return;
    Function firingTransition = (num ratio) {
      return 0.25 < ratio && ratio < 0.85? 1.0 : 0.0;
    };

    num time = .10;
    AnimationGroup fireAni = new AnimationGroup();
    fireAni.add(new Tween(weapon[currentWeapon], time, firingTransition)..animate.y.to(3));
    fireAni.add(new Tween(torso, time, firingTransition)..animate.y.to(3));
    fireAni.onStart = () => _isFiring = true;
    fireAni.onComplete = () => _isFiring = false;
    stage.juggler.add(fireAni);
  }

  void swapWeapon() {
    weapon[currentWeapon].visible = false;
    currentWeapon = currentWeapon < resLoader.weaponNames.length - 1? currentWeapon + 1: 0;
    weapon[currentWeapon].visible = true;
  }

  void debug() {
    dbg.text = "p: x:$x y:$y\n" +
        "r:${(rotation * 180/math.PI).toStringAsFixed(2)} " +
        "l:${(legs.rotation * 180/math.PI).toStringAsFixed(2)}";
  }
}

