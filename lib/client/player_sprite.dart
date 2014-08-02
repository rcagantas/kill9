part of gglclient;

class PlayerSprite extends DisplayObjectContainer {
  static const num CENTER = 48.5; //center of player tile
  static const num OFFSET = 8;
  static const num HPRADIUS = 33;
  static num totalPlayers = -1;

  Bitmap head;
  Bitmap torso;
  String pre = ResourceHandler.pre;
  Map<String, Bitmap> weapons = new Map<String, Bitmap>();
  Map<String, Sound> weaponSound = new Map<String, Sound>();
  List<String> weaponNames = ['pistol','rifle','grenade','rocket'];
  String weapon = "pistol";
  FlipBook hip;
  FlipBook death;
  Shape arcHealth;
  TextField dbg, nameDisplay;
  bool dbgmode = false;
  bool _alive = true;
  num hp = 100;
  ParticleEmitter splatter, splatterAoe, spawnParts;
  Shape bloodPool;
  num playerNo = -1;
  bool _animatingFiring = false;

  PlayerSprite() {
    playerNo = totalPlayers + 1 < ResourceHandler.MAX_PLAYERS ? ++totalPlayers : ResourceHandler.MAX_PLAYERS;
    splatter = new ParticleEmitter(ResourceHandler.jsonBloodSplat)
      ..stop(true)
      ..addTo(this);
    stage.juggler.add(splatter);

    splatterAoe = new ParticleEmitter(ResourceHandler.jsonBloodSplatAoe)
      ..stop(true)
      ..addTo(this);
    stage.juggler.add(splatterAoe);

    arcHealth = new Shape()
      ..pivotX = CENTER
      ..pivotY = CENTER
      ..rotation = math.PI/2
      ..graphics.arc(CENTER, CENTER, HPRADIUS, -math.PI/4, math.PI/4, false)
      ..graphics.strokeColor(Color.YellowGreen, 4)
      ..addTo(this);

    hip = new FlipBook(ResourceHandler.ac_stride, 10)
      ..addTo(this)
      ..x = -OFFSET
      ..y = OFFSET
      ..pivotX = CENTER - OFFSET
      ..pivotY = CENTER + OFFSET
      ..gotoAndStop(0);
    stage.juggler.add(hip);

    torso = new Bitmap(resMgr.getBitmapData("${pre}${playerNo}_torso"))
      ..pivotX = CENTER
      ..pivotY = CENTER
      ..addTo(this);

    for (String weaponName in weaponNames) {
      Bitmap bmp = new Bitmap(resMgr.getBitmapData("${pre}_${weaponName}"))
        ..visible = weaponName == "pistol"? true: false
        ..pivotX = CENTER
        ..pivotY = CENTER
        ..addTo(this);
      weapons[weaponName] = bmp;
      weaponSound[weaponName] = resMgr.getSound("snd_${weaponName}");
    }

    weaponSound['reload'] = resMgr.getSound('snd_reload');

    head = new Bitmap(resMgr.getBitmapData("${pre}_head"))
      ..pivotX = CENTER
      ..pivotY = CENTER
      ..addTo(this);

    bloodPool = new Shape()
      ..x = 5
      ..y = 20
      ..visible = false
      ..graphics.circle(0, 0, 1)
      ..graphics.fillColor(Color.Maroon)
      ..addTo(this);

    death = ResourceHandler.flipbookDeath(playerNo, 10)
      ..x = -OFFSET
      ..y = OFFSET
      ..pivotX = CENTER - OFFSET
      ..pivotY = CENTER + OFFSET
      ..visible = false
      ..loop = false
      ..addTo(this)
      ..play();
    stage.juggler.add(death);

    spawnParts = new ParticleEmitter(ResourceHandler.jsonSpawn)
      ..stop(true)
      ..addTo(this);
    stage.juggler.add(spawnParts);


    x = stage.stageWidth/2;
    y = stage.stageHeight/2;

    TextFormat tf = new TextFormat('Open Sans', 10, Color.Black);
    dbg = new TextField()
      ..defaultTextFormat = tf
      ..x = 30
      ..y = 30
      ..width = 200
      ..height = 200
      ..wordWrap = true
      ..addTo(this);

    TextFormat tfn = new TextFormat('Open Sans', 15, Color.White);
    nameDisplay = new TextField()
      ..defaultTextFormat = tfn
      ..x = 0
      ..y = 30
      ..width = 200
      ..height = 50
      ..wordWrap = true
      ..addTo(this);
  }

  void move(num x, num y) {
    if (!hip.playing) hip.play();
    fixHipRotation(x, y);
    this.x = x;
    this.y = y;
  }

  void stopMoving() {
    hip.gotoAndStop(0);
    return;
  }

  void takeDamage(num dmg, num dmgFrom) {
    num h = hp - dmg < 0? 0 : hp - dmg;
    modHitPoints(h - dmg, dmgFrom);
  }

  void modHitPoints(num newHpRatio, num dmgFrom) {
    bool bleed = newHpRatio < hp;
    hp = newHpRatio;
    num angle = math.PI/4 * hp/100;
    num color = hp/100 < .4? Color.Red : Color.YellowGreen;
    arcHealth.graphics.clear();
    arcHealth
      ..graphics.arc(CENTER, CENTER, HPRADIUS, -angle, angle, false)
      ..graphics.strokeColor(color, 4);

    if (hp == 0) {
      alive = false;
      return;
    } else if (hp == 100) {
      return;
    }

    if (bleed) {
      if (dmgFrom == -1) splatterAoe.start(.3);
      else {
        splatter.rotation = peg180(dmgFrom - this.rotation - math.PI);
        splatter.start(.3);
      }
    }
  }

  void deathAnimation() {
    math.Random rand = new math.Random();
    num scale1 = 15 + rand.nextInt(10);
    Tween poolAni = new Tween(bloodPool, 3.0, TransitionFunction.linear)
      ..animate.scaleX.to(scale1)
      ..animate.scaleY.to(scale1 + 5)
      ..animate.rotation.to(rand.nextDouble());
    Tween fadeAni = new Tween(this, 3.0, TransitionFunction.linear)
      ..animate.alpha.to(0);
    AnimationChain c = new AnimationChain();
    c.add(poolAni);
    c.add(fadeAni);
    stage.juggler.add(c);
  }

  void spawnAnimation() {
    this.alpha = 100;
    spawnParts.start(.5);
  }

  void set alive(bool b) {
    _alive = b;
    weapons[weapon].visible =
    head.visible =
    torso.visible =
    hip.visible =
    arcHealth.visible = b;
    death.visible =
    bloodPool.visible = !b;
    if (!_alive) {
      death.visible = true;
      bloodPool.visible = true;
      death.gotoAndPlay(0);
      deathAnimation();
    } else {
      modHitPoints(100, 0);
      spawnAnimation();
    }
  }

  bool get alive { return _alive; }

  void fixHipRotation(num x, num y) {
    num dx = x - this.x;
    num dy = y - this.y;
    if (dx == 0 && dy == 0) return;
    num hrad = math.atan2(dy, dx) + math.PI/2;
    num trad = this.rotation;

    num val = peg180(hrad - trad);
    val = val.abs() > math.PI/2? val - math.PI: val;
    hip.rotation = peg180(val);
    displayAngles();
  }

  void turn(num r) {
    if (this.rotation == r) return;
    this.rotation = peg180(r);
    dbg.rotation = -this.rotation;
    nameDisplay.rotation = -this.rotation;
    fixHipRotation(this.x, this.y);
    displayAngles();
  }

  void turnToPoint(num dx, num dy) {
    turn(math.PI - math.atan2(dx - x, dy - y));
  }

  void turnFromCenter(num dx, num dy) {
    turn(math.PI - math.atan2(dx - stage.stageWidth/2, dy - stage.stageHeight/2));
  }

  void turnAdd(num r) { turn(this.rotation + r); }

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

  void displayAngles() {
    if (!dbgmode) return;
    dbg.text = "all: ${(this.rotation * 180/math.PI).toStringAsFixed(2)}\n" +
      "hip: ${(hip.rotation * 180/math.PI).toStringAsFixed(2)}\n" +
      "spatter: ${(splatter.rotation * 180/math.PI).toStringAsFixed(2)}";
  }

  String cycleWeapon() {
    num index = weaponNames.indexOf(weapon);
    String newWeapon = weaponNames[index + 1 >= weaponNames.length? 0 : index + 1];
    setWeaponStr(newWeapon);
    return newWeapon;
  }

  bool setWeapon(num weaponType) {
    String newWeapon;
    switch(weaponType) {
      case WeaponType.PISTOL: newWeapon = "pistol"; break;
      case WeaponType.RIFLE: newWeapon = "rifle"; break;
      case WeaponType.GRENADE_LAUNCHER: newWeapon = "grenade"; break;
      case WeaponType.ROCKET_LAUNCHER: newWeapon = "rocket"; break;
    }
    return setWeaponStr(newWeapon);
  }

  bool setWeaponStr(String newWeapon) {
    if (newWeapon == weapon) return false;
    if (weaponNames.contains(newWeapon)) {
      weapons[weapon].visible = false;
      weapon = newWeapon;
      weapons[weapon].visible = true;
      weaponSound['reload'].play(false);
      return true;
    }
    return false;
  }

  void firingAnimation() {
    num time = .08;
    var transition = (ratio) {
      if (ratio < .45) return 0;
      else if (ratio > .95) return 0;
      else return 1;
    };

    AnimationGroup fireAni = new AnimationGroup();
    fireAni.add(new Tween(weapons[weapon], time, transition)..animate.y.to(3));
    fireAni.add(new Tween(torso, time, transition)..animate.y.to(3));
    fireAni.onStart = () => _animatingFiring = true;
    fireAni.onComplete = () => _animatingFiring = false;
    stage.juggler.add(fireAni);
  }

  void firingAnimation1() {
    num time = 0.02;

    AnimationGroup pull = new AnimationGroup();
    pull.add(new Tween(torso, time, TransitionFunction.linear)..animate.y.to(3));
    pull.add(new Tween(weapons[weapon], time, TransitionFunction.linear)..animate.y.to(3));

    AnimationGroup push = new AnimationGroup();
    push.add(new Tween(torso, time, TransitionFunction.linear)..animate.y.to(0));
    push.add(new Tween(weapons[weapon], time, TransitionFunction.linear)..animate.y.to(0));

    AnimationChain fireAni = new AnimationChain();
    pull.delay = time;
    fireAni.add(pull);
    push.delay = time;
    fireAni.add(push);
    fireAni.onStart = () => _animatingFiring = true;
    fireAni.onComplete = () => _animatingFiring = false;
    stage.juggler.add(fireAni);
  }

  void fire() {
    if (_animatingFiring) return;
    firingAnimation();
    weaponSound[weapon].play(false);
  }
}