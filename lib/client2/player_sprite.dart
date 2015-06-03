part of gglclient2;

class PlayerSprite extends Sprite {
  static const num center = 48.5; //center of player tile
  static const num offset = 8;
  static num hpRadius = 33;

  TextField dbg, playerName;
  FlipBook legs;
  Bitmap torso, head, color, dead, colorDead, mflash;
  ParticleEmitter splatter;
  Shape hpBar;

  List<Bitmap> weapon = [];
  static List<Sound> weaponSnd = [];
  static Sound reloadSnd, emptySnd, walkSnd;
  static SoundChannel walkSndCh;

  Sprite pnlAlive = new Sprite();
  Sprite pnlDead = new Sprite();

  num currentWeapon = 0;
  num ammoCount = 0;
  num _hpRatio = 100;
  bool isFiring = false;
  final List<String> weaponNames = ['pistol', 'rifle', 'grenade', 'rocket'];
  static final num maxPlayers = 10;
  num _playerNo = -1;

  num get playerNo { return _playerNo; }


  PlayerSprite(num n) {
    _playerNo = n;
    _playerNo = _playerNo < 0 || maxPlayers < _playerNo? 0 : _playerNo;

    dead = new Bitmap(resource.getBitmapData("p_dead"))
      ..pivotX = center
      ..pivotY = center
      ..addTo(pnlDead);

    colorDead = new Bitmap(resource.getBitmapData("cd_$_playerNo"))
      ..pivotX = center
      ..pivotY = center
      ..addTo(pnlDead);

    dbg = new TextField()
      ..defaultTextFormat = new TextFormat('Lato', 15, Color.Black)
      ..width = 200
      ..height = 200
      ..wordWrap = true
      ..text = "p:"
      ..addTo(pnlAlive);

    playerName = new TextField()
      ..defaultTextFormat =
      new TextFormat('Lato', 15, Color.WhiteSmoke, bold: true, align: "center")
      ..width = 200
      ..height = 100
      ..pivotX = 100
      ..pivotY = -30
      ..wordWrap = false
      ..text = ""
      ..addTo(pnlAlive);

    splatter = new ParticleEmitter(ParticleLoader.splatter)
      ..stop(true)
      ..addTo(pnlAlive);
    stage.juggler.add(splatter);

    walkSnd = resource.getSound("ws_footsteps");
    List<BitmapData> bmpStride = [];
    for (num i = 0;
        i < 6;
        i++) bmpStride.add(resource.getBitmapData("p_stride$i"));

    legs = new FlipBook(bmpStride, 10)
      ..x = -offset
      ..y = offset
      ..pivotX = center - offset
      ..pivotY = center + offset
      ..gotoAndStop(0)
      ..addTo(pnlAlive);
    stage.juggler.add(legs);

    hpBar = new Shape()
      ..pivotX = center
      ..pivotY = center
      ..rotation = math.PI / 2
      ..graphics.arc(center, center, hpRadius, -math.PI / 4, math.PI / 4, false)
      ..graphics.strokeColor(Color.YellowGreen, 4)
      ..addTo(pnlAlive);

    mflash = new Bitmap(resource.getBitmapData("p_mflash"))
      ..pivotX = center
      ..pivotY = center
      ..x = x + 36
      ..y = y - offset
      ..alpha = 0
      ..addTo(pnlAlive);

    torso = new Bitmap(resource.getBitmapData("p_torso"))
      ..pivotX = center
      ..pivotY = center
      ..addTo(pnlAlive);

    color = new Bitmap(resource.getBitmapData("c_$_playerNo"))
      ..pivotX = center
      ..pivotY = center
      ..addTo(pnlAlive);

    reloadSnd = resource.getSound("ws_reload");
    emptySnd = resource.getSound("ws_empty");
    for (String weaponName in weaponNames) {
      weapon.add(new Bitmap(resource.getBitmapData("w_$weaponName"))
        ..pivotX = center
        ..pivotY = center
        ..visible = false
        ..addTo(pnlAlive));
      weaponSnd.add(resource.getSound("ws_$weaponName"));
    }
    weapon[currentWeapon].visible = true;

    head = new Bitmap(resource.getBitmapData("p_head"))
      ..pivotX = center
      ..pivotY = center
      ..addTo(pnlAlive);

    pnlDead.addTo(this);
    pnlDead.visible = false;
    pnlAlive.addTo(this);
  }

  bool get isDead {
    return _hpRatio < 1;
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
    num hrad = math.atan2(dy, dx) + math.PI / 2;
    num trad = this.rotation;

    num val = peg180(hrad - trad);
    val = val.abs() > math.PI / 2 ? val - math.PI : val;
    legs.rotation = peg180(val);
  }

  void move(num x, num y, num r) {
    if (isDead) return;
    fixLegRotation(x, y);
    splatter.rotation = peg180(splatter.rotation + (rotation - r));
    this.x = x;
    this.y = y;
    rotation = peg180(r);
    playerName.rotation = -rotation;

    if (!this.contains(pnlDead)) {
      pnlDead.x = this.x;
      pnlDead.y = this.y;
      pnlDead.rotation = this.rotation;
    }
  }


  void walk(bool walk) {

    // walk animation
    if (walk) {
      if (!legs.playing) legs.play();
    } else {
      legs.gotoAndStop(0);
    }

    // walk sound
    /*
    if (playerNo != 0) return;
    if (walk) walkSndCh = walkSnd.play(true);
    else if (walkSndCh != null) walkSndCh.stop();*/
  }

  void toggleFire(bool b) {
    if (b) fire();
  }

  void fire() {
    if (isDead || isFiring) return;

    Function firingTransition = (num ratio) {
      return 0.25 < ratio && ratio < 0.85 ? 1.0 : 0.0;
    };

    num time = .10;
    switch (currentWeapon) {
      case 0: time = .20; break;
      case 1: time = .10; break;
      case 2: time = .4; break;
      case 3: time = .4; break;
    }

    AnimationGroup fireAni = new AnimationGroup();
    if (ammoCount != 0)
      fireAni.add(new Tween(mflash, .1, firingTransition)..animate.alpha.to(100));
    fireAni.add(new Tween(weapon[currentWeapon], time, firingTransition)
      ..animate.y.to(4));
    fireAni.add(new Tween(torso, time, firingTransition)..animate.y.to(2));
    fireAni.onStart = () {
      if (ammoCount != 0)
        weaponSnd[currentWeapon].playSegment(0, .8, false);
      else
        emptySnd.playSegment(0, .8, false);
      isFiring = true;
    };
    fireAni.onComplete = () {
      isFiring = false;
      mflash.alpha = 0;
      torso.x = 0;
      stage.juggler.remove(fireAni);
    };
    stage.juggler.add(fireAni);
  }

  void switchWeapon(num id) {
    if (id == currentWeapon) return;
    weapon[currentWeapon].visible = false;
    currentWeapon = id < 0 || weapon.length < id ? 0 : id;
    reloadSnd.playSegment(0, .8, false);
    weapon[currentWeapon].visible = true;
  }

  void swapWeapon() {
    weapon[currentWeapon].visible = false;
    currentWeapon = currentWeapon + 1 >= weapon.length ? 0 : currentWeapon + 1;
    reloadSnd.playSegment(0, .8, false);
    weapon[currentWeapon].visible = true;
  }

  void _updateHpBar() {
    if (hpRatio < 1) return;
    num angle = math.PI / 4 * hpRatio / 100;
    num color = hpRatio / 100 < .4 ? Color.Red : Color.YellowGreen;
    hpBar.graphics.clear();
    hpBar
      ..graphics.arc(center, center, hpRadius, -angle, angle, false)
      ..graphics.strokeColor(color, 4);
  }

  num get hpRatio {
    return _hpRatio;
  }
  void set hpRatio(num hp) {
    _hpRatio = hp;
    _updateHpBar();
    pnlAlive.visible = !isDead;
    pnlDead.visible = isDead;
  }

  void takeDamage(num hp, num from) {
    if (hp == hpRatio) return;
    hpRatio = hp;
    if (hpRatio > 0 && hpRatio != 100) {
      splatter.rotation = peg180(from - rotation + math.PI);
      splatter.start(.2);
    }
  }

  void action(Cmd c) {
    if (c == null) return;
    num x = this.x + c.moveX * c.ms;
    num y = this.y + c.moveY * c.ms;
    num r = rotation + c.moveR * c.tr;
    if (c.mouseX != -1 && c.mouseY != -1) {
      r = math.PI - math.atan2(c.mouseX, c.mouseY);
    }

    walk(this.x != x || this.y != y || this.rotation != peg180(r));
    move(x, y, r);

    if (c.fire == 1) fire();
    if (c.swap == 1) swapWeapon();
  }
}
