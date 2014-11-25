part of gglclient2;

class PlayerSprite extends DisplayObjectContainer {
  static const num center = 48.5; //center of player tile
  static const num offset = 8;
  static num totalPlayers = -1;
  static num hpRadius = 33;

  TextField dbg, playerName;
  FlipBook legs, death;
  Bitmap torso, head;
  List<Bitmap> weapon = [];
  List<Sound> weaponSound = [];
  Sound reloadSound;
  Shape hpBar;
  ParticleEmitter splatter, spawn;

  num playerNo;
  num currentWeapon = 0;
  bool _isFiring = false;
  num _hpRatio = 100;

  PlayerSprite(this.playerNo) {

    dbg = new TextField()
      ..defaultTextFormat = diagnostics.font11
      ..width = 200
      ..height = 200
      ..wordWrap = true
      ..text = "p:"
      ..addTo(this);

    playerName = new TextField()
      ..defaultTextFormat = new TextFormat('Lato', 15, Color.WhiteSmoke, bold:true, align:"center")
      ..width = 200
      ..height = 100
      ..pivotX = 100
      ..pivotY = -30
      ..wordWrap = false
      ..text = ""
      ..addTo(this);

    splatter = new ParticleEmitter(ParticleLoader.splatter)
      ..stop(true)
      ..addTo(this);
    stage.juggler.add(splatter);

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

    reloadSound = resource.getSound("snd_reload");
    for (String weaponName in resLoader.weaponNames) {
      weapon.add(
        new Bitmap(resource.getBitmapData("ac_$weaponName"))
          ..pivotX = center
          ..pivotY = center
          ..visible = weapon.isEmpty? true: false
          ..addTo(this)
      );
      weaponSound.add(resource.getSound("snd_$weaponName"));
    }

    head = new Bitmap(resource.getBitmapData("ac_head"))
      ..pivotX = center
      ..pivotY = center
      ..addTo(this);

    death = resLoader.flipbookDeath(playerNo, 10)
      ..x = -offset
      ..y = offset
      ..pivotX = center - offset
      ..pivotY = center + offset
      ..visible = false
      ..loop = false
      ..addTo(this)
      ..play();
    stage.juggler.add(death);

    spawn = new ParticleEmitter(ParticleLoader.spawn)
      ..stop(true)
      ..addTo(this);
    stage.juggler.add(spawn);
  }

  void set name(String n) { playerName.text = n == null? "" : "$n"; }

  bool get isDead { return _hpRatio < 1; }

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
    if (isDead) return;
    fixLegRotation(x, y);
    splatter.rotation = peg180(splatter.rotation + (rotation - r));
    this.x = x; this.y = y; rotation = peg180(r);
    playerName.rotation = -rotation;
    debug();
  }

  void walk(bool walk) {
    if (walk && !legs.playing) legs.play();
    else if (!walk) legs.gotoAndStop(0);
  }

  void toggleFire(bool b) {
    if (b) fire();
  }

  void fire() {
    if (isDead) return;
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
    weaponSound[currentWeapon].playSegment(0, currentWeapon == 0? .1:1, false);
  }

  void swapWeapon() {
    if (isDead) return;
    weapon[currentWeapon].visible = false;
    currentWeapon = currentWeapon < resLoader.weaponNames.length - 1? currentWeapon + 1: 0;
    weapon[currentWeapon].visible = true;
    reloadSound.play(false);
  }

  void switchWeapon(int weaponType) {
    if (weaponType == currentWeapon) return;
    weapon[currentWeapon].visible = false;
    currentWeapon = weaponType;
    weapon[currentWeapon].visible = true;
    reloadSound.play(false);
  }

  void updateHpBar() {
    if (hpRatio < 1) return;
    num angle = math.PI/4 * hpRatio/100;
    num color = hpRatio/100 < .4? Color.Red : Color.YellowGreen;
    hpBar.graphics.clear();
    hpBar
      ..graphics.arc(center, center, hpRadius, -angle, angle, false)
      ..graphics.strokeColor(color, 4);
  }

  void setVisibility(bool b) {
    legs.visible =
    torso.visible =
    head.visible =
    hpBar.visible =
    weapon[currentWeapon].visible = b;
    death.visible = !b;
  }

  void set hpRatio(num hp) {
    if (_hpRatio < 1 && hp == 100) {
      spawn.start(.5);
    } else if (_hpRatio < 1 && hp > 1) {
      death.gotoAndPlay(0);
      return;
    }
    _hpRatio = hp;
    updateHpBar();
    setVisibility(_hpRatio > 0);
  }

  num get hpRatio { return _hpRatio; }

  void takeDamage(num hp, num from) {
    if (hp == hpRatio) return;
    hpRatio = hp;
    if (hpRatio > 0 && hpRatio != 100) {
      splatter.rotation = peg180(from - rotation + math.PI);
      splatter.start(.2);
    }
  }

  void action(Cmd c) {
    num x = this.x + c.moveX * c.ms;
    num y = this.y + c.moveY * c.ms;
    num r = rotation + c.rotate * c.tr;
    if (c.mouseX != -1 && c.mouseY != -1) {
      r = math.PI - math.atan2(c.mouseX, c.mouseY);
    }

    walk(this.x != x || this.y != y || this.rotation != peg180(r));
    move(x, y, r);
    if (c.fire) fire();
    if (c.swap) swapWeapon();
  }

  void debug() {
    if (!diagnostics.isLogging) dbg.removeFromParent();
    dbg.rotation = -rotation;
    dbg.text = "\n\np: x:$x y:$y\n" +
        "r:${(rotation * 180/math.PI).toStringAsFixed(2)} " +
        "l:${(legs.rotation * 180/math.PI).toStringAsFixed(2)}";
  }
}

