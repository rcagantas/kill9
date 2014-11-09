part of gglclient2;

class PlayerSprite extends DisplayObjectContainer {
  static const num center = 48.5; //center of player tile
  static const num offset = 8;
  static num totalPlayers = -1;
  static num hpRadius = 33;

  TextField dbg;
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

  PlayerSprite() {
    playerNo = 0;
    dbg = new TextField()
             ..defaultTextFormat = diagnostics.font11
             ..width = 200
             ..height = 200
             ..wordWrap = true
             ..text = "p:"
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
    debug();
  }

  void walk(bool walk) {
    if (walk && !legs.playing) legs.play();
    else if (!walk) legs.gotoAndStop(0);
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
    weaponSound[currentWeapon].play(false);
  }

  void swapWeapon() {
    if (isDead) return;
    weapon[currentWeapon].visible = false;
    currentWeapon = currentWeapon < resLoader.weaponNames.length - 1? currentWeapon + 1: 0;
    weapon[currentWeapon].visible = true;
    reloadSound.play(false);
  }

  void updateHpBar() {
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
    weapon[currentWeapon].visible = b;
    death.visible = !b;
  }

  void set hpRatio(num hp) {
    if (_hpRatio < 1 && hp == 100) spawn.start(.5);
    _hpRatio = hp;
    setVisibility(_hpRatio > 0);
    updateHpBar();
    if (_hpRatio < 1) death.gotoAndPlay(0);
  }

  num get hpRatio { return _hpRatio; }

  void takeDamage(num damage, num from) {
    if (hpRatio - damage < 0) {
      hpRatio = 0;
      return;
    }
    hpRatio = hpRatio - damage;
    splatter.rotation = peg180(from - rotation);
    splatter.start(.2);
  }

  void debug() {
    dbg.rotation = -rotation;
    dbg.text = "\n\np: x:$x y:$y\n" +
        "r:${(rotation * 180/math.PI).toStringAsFixed(2)} " +
        "l:${(legs.rotation * 180/math.PI).toStringAsFixed(2)}";
  }
}

