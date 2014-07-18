part of gglworld;

// Ammo

class Bullet extends WorldObject {

  num maxDistance;
  num startX, startY;
  bool _expired = false;
  bool hitObject = false, hitActor = false, timedOut = false;
  int damage;

  Bullet():super(BulletProps.RADIUS,BulletProps.SPEED,0);

  void init(num x, num y, num orientation, num radius) {
    xVelocity = speed * math.sin(orientation);
    yVelocity = -speed * math.cos(orientation);
    this.x = x + (radius * math.sin(orientation));
    this.y = y - (radius * math.cos(orientation));
    this.orientation = orientation;
    this.startX = this.x;
    this.startY = this.y;
    hitObject =
    hitActor =
    timedOut =
    _expired = false;
  }

  void doPhysics(num elapsedTime, Map objects) {

    //hit someone?
    objects.forEach((key,object) {
      if (key != this.hashCode && object is Actor) {
        if (object is Actor && object.life == 0) {}
        else if (willBump(object, elapsedTime)) {
          print ("Player $key is hit");
          (object as Actor).takeDamage(BulletProps.DAMAGE, this.orientation);
          _expired = true;
          hitActor = _expired? true: false;
        }
      }
    });

    //hit walls?
    if (!_expired) {
      math.Point newPos = projectLocation(elapsedTime);
      _expired =  (myWorld.grid.bumpLeft(newPos.x, newPos.y, radius) ||
          myWorld.grid.bumpRight(newPos.x, newPos.y, radius)||
          myWorld.grid.bumpTop(newPos.x, newPos.y, radius) ||
          myWorld.grid.bumpBottom(newPos.x, newPos.y, radius));
      hitObject = _expired? true: false;
    }
    //reached max distance?
    if (!_expired) {
      var p2 = new math.Point(startX,startY);
      _expired = (new math.Point(x,y).distanceTo(p2) > BulletProps.DISTANCE);
      timedOut = _expired? true: false;
    }
  }

  void update(elapsedTime) {
    if (!_expired) {
      super.update(elapsedTime);
    }
    else {
      myWorld.bullets.putBullet(this);
      myWorld.removeObject(this);
    }
  }
}

class BulletFactory {

  Queue<Bullet> _bullets = new Queue();
  int counter = 0;

  BulletFactory(int bulletCount) {
    for (int i = 0; i < bulletCount; i++) {
      var bullet = new Bullet();
      _bullets.add(bullet);
    }
  }

  Bullet getBullet() {
    var bullet = _bullets.removeFirst();
    counter = counter + 1;

    print("Borrowed ${_bullets.length}: Total fire: $counter");

    return bullet;
  }

  void putBullet(Bullet bullet) {
    if (bullet == null) {
      print ("this should not happen");
    }
    _bullets.addLast(bullet);
    print("Returned: ${_bullets.length}");
  }

  Iterable getBulletList()
  {
    return _bullets.map((e)=>e.hashCode);
  }
}

class Grenade extends WorldObject {

  num maxDistance;
  num expireTime;
  num startX, startY;

  Subject expires = new Subject();

  Grenade(radius, speed, orientation, expireTime):super(radius,speed,0) {
    this.orientation = orientation;
    this.maxDistance = 0;
    this.expireTime = expireTime;

    xVelocity = speed * math.sin(orientation);
    yVelocity = -speed * math.cos(orientation);
  }

  void update(elapsedTime) {

    var p1 = new math.Point(x,y);
    var p2 = new math.Point(startX,startY);

    if (expireTime < 0) {
      myWorld.removeObject(this);
      expires.notify(this, GglEvent.GRENADE_EXPIRES);

      return;
    }

    var newLoc = projectLocation(elapsedTime);

    if (myWorld.grid.bumpLeft(newLoc.x, y, radius) ||
        myWorld.grid.bumpRight(newLoc.x, y, radius)) {
      xVelocity = -xVelocity;
    }

    if (myWorld.grid.bumpTop(x, newLoc.y, radius) ||
        myWorld.grid.bumpBottom(x, newLoc.y, radius)) {
      yVelocity = -yVelocity;
    }

    super.update(elapsedTime);

    expireTime = expireTime - elapsedTime;
  }
}

// Weapons

class Weapon {

  Actor owner;
  Weapon(this.owner);
  bool isFiring = false;
  int weaponType;
  num ammo;

  void fire() {
   print("firing some generic weapon");
   return null;
  }

  void stop() {
    isFiring = false;
  }
}

class Pistol extends Weapon {

  var name = "Pistol";
  bool _pressed = false;

  Pistol(owner):super(owner) {
    weaponType = WeaponType.PISTOL;
    ammo = 0;
  }

  void fire() {
    isFiring = false;
    if (_pressed || owner.life == 0) return;

    _pressed = true;
    print ("firing $name");
    var bullet = owner.myWorld.bullets.getBullet()
      ..init(owner.x, owner.y, owner.orientation, owner.radius);

    owner.myWorld.addObject(bullet);
    isFiring = true;
  }

  void stop() {
    _pressed = false;
    isFiring = false;
  }
}

class Rifle extends Weapon {

  var name = "Rifle";
  bool _pressed = false;

  Rifle(owner):super(owner) {
    weaponType = WeaponType.RIFLE;
    ammo = 200;
  }

  Timer fireTimer;

  void fire() {
    if (_pressed || ammo == 0 || owner.life == 0) return;
    isFiring = true;
    _pressed = true;
    _fire(null);
    fireTimer = new Timer.periodic(new Duration(milliseconds:100), _fire);
  }



  void stop() {
    if (_pressed && ammo > 0){
      fireTimer.cancel();
    }
    isFiring = false;
    _pressed = false;
  }

  void _fire(Timer timer) {
    var bullet = owner.myWorld.bullets.getBullet()
      ..init(owner.x, owner.y, owner.orientation, owner.radius);

    owner.myWorld.addObject(bullet);
    ammo = ammo - 1;

    isFiring = true;
    if (ammo == 0 && timer != null) {
      timer.cancel();
      isFiring = false;
    }
  }
}

class GrenadeLauncher extends Weapon {

  var name = "Grenade Launcher";

  GrenadeLauncher(owner):super(owner) {
    weaponType = WeaponType.GRENADE_LAUNCHER;
  }

  void fire() {
    isFiring = false;
    print ("firing $name");
    var grenade = new Grenade(10,300,owner.orientation,5)
        ..x = owner.x
        ..y = owner.y
        ..startX = owner.x
        ..startY = owner.y;

    owner.myWorld.addObject(grenade);
    isFiring = true;
  }
}

