part of gglworld;

abstract class Weapon {
  Actor owner;
  Weapon(this.owner);
  bool isFiring = false;
  bool isPressed = false;
  bool isAuto = false;
  int weaponType, bulletType;
  num ammo, firingRate;
  Timer fireTimer;

  void fire() {
    if (isAuto) {
      if (isPressed || ammo == 0 || owner.life == 0) return;
      isFiring = true;
      isPressed = true;
      fireAuto(null);
      fireTimer = new Timer.periodic(new Duration(milliseconds:firingRate), fireAuto);
    } else {
      fireOnce();
    }
  }

  void fireOnce() {
    isFiring = false;
    if (owner.life == 0 || isPressed) return;
    isPressed = true;

    var bullet = owner.myWorld.bullets.getBullet(bulletType)
      ..init(owner.x, owner.y, owner.orientation, owner.radius);

    owner.myWorld.addObject(bullet);
    isFiring = true;
    ammo = bulletType != BulletType.BULLET? ammo - 1: ammo;
  }

  void fireAuto(Timer timer) {
    var bullet = owner.myWorld.bullets.getBullet(bulletType)
      ..init(owner.x, owner.y, owner.orientation, owner.radius);

    owner.myWorld.addObject(bullet);
    ammo--;

    isFiring = true;
    if (ammo == 0 && timer != null) {
      timer.cancel();
      isFiring = false;
    }
  }

  void stop() {
    if (isAuto && isPressed && ammo > 0) {
      fireTimer.cancel();
    }
    isPressed = false;
    isFiring = false;
  }
}

class Pistol extends Weapon {
  Pistol(Actor owner) : super(owner) {
    weaponType = WeaponType.PISTOL;
    bulletType = BulletType.BULLET;
    isAuto = false;
  }
}

class Rifle extends Weapon {
  Rifle(Actor owner) : super(owner) {
    weaponType = WeaponType.RIFLE;
    bulletType = BulletType.BULLET;
    isAuto = true;
    firingRate = 100;
    ammo = 200;
  }
}

class GrenadeLauncher extends Weapon {
  GrenadeLauncher(Actor owner) : super(owner) {
    weaponType = WeaponType.GRENADE_LAUNCHER;
    bulletType = BulletType.GRENADE;
    isAuto = false;
    ammo = 40;
  }
}

class RocketLauncher extends Weapon {
  RocketLauncher(Actor owner) : super(owner) {
    weaponType = WeaponType.ROCKET_LAUNCHER;
    bulletType = BulletType.ROCKET;
    isAuto = false;
    ammo = 40;
  }
}

class Bullet extends WorldObject {
  int type;
  num startX, startY, maxDistance, damage;
  bool hitObject, hitActor, timedOut, _expired;

  Bullet(this.type) : super(BulletProps.RADIUS, BulletProps.SPEED, 0);

  void init(num x, num y, num orientation, num radius) {
    switch(type) {
      case BulletType.BULLET:
        maxDistance = BulletProps.DISTANCE;
        speed = BulletProps.SPEED;
        damage = BulletProps.DAMAGE;
        break;
      case BulletType.GRENADE:
      case BulletType.ROCKET:
        maxDistance = 700;
        speed = 400;
        damage = 20;
        break;
    }

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

  void checkCollideActor(num elapsedTime, Map objects) {
    objects.forEach((key,object) {
      if (key != this.hashCode && object is Actor) {
        if (object is Actor && object.life == 0) {}
        else if (willBump(object, elapsedTime)) {
          //print ("Player $key is hit");
          (object as Actor).takeDamage(damage, this.orientation);
          _expired = true;
          hitActor = _expired? true: false;
          if (hitActor)
            hitObject =
                type == BulletType.ROCKET ||
                type == BulletType.GRENADE?
              true: false;
        }
      }
    });
  }

  void checkCollideWalls(num elapsedTime) {
    if (!_expired && type == BulletType.GRENADE) {
      math.Point newPos = projectLocation(elapsedTime);
      if (myWorld.grid.bumpLeft(newPos.x, newPos.y, radius) ||
          myWorld.grid.bumpRight(newPos.x, newPos.y, radius))
        xVelocity = -xVelocity;
      if (myWorld.grid.bumpTop(newPos.x, newPos.y, radius) ||
          myWorld.grid.bumpBottom(newPos.x, newPos.y, radius))
        yVelocity = -yVelocity;
      return;
    }

    if (!_expired) {
      math.Point newPos = projectLocation(elapsedTime);
      _expired =  (myWorld.grid.bumpLeft(newPos.x, newPos.y, radius) ||
          myWorld.grid.bumpRight(newPos.x, newPos.y, radius)||
          myWorld.grid.bumpTop(newPos.x, newPos.y, radius) ||
          myWorld.grid.bumpBottom(newPos.x, newPos.y, radius));
      hitObject = _expired? true: false;
    }
  }

  void checkMaxDistance() {
    if (!_expired) {
      var p2 = new math.Point(startX,startY);
      _expired = (new math.Point(x,y).distanceTo(p2) > maxDistance);
      timedOut = _expired? true: false;
      hitObject = timedOut && type == BulletType.GRENADE ? true : false;
    }
  }

  void doPhysics(num elapsedTime, Map objects) {
    checkCollideActor(elapsedTime, objects);
    checkCollideWalls(elapsedTime);
    checkMaxDistance();
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
  Queue<Bullet> _grenades = new Queue();
  Queue<Bullet> _rockets = new Queue();
  int counter = 0;

  BulletFactory(int bulletCount) {
    for (int i = 0; i < bulletCount * .6; i++) {
      var bullet = new Bullet(BulletType.BULLET);
      _bullets.add(bullet);
    }
    for (int i = 0; i < bulletCount * .2; i++) {
      var bullet = new Bullet(BulletType.GRENADE);
      _grenades.add(bullet);
    }
    for (int i = 0; i < bulletCount * .2; i++) {
      var bullet = new Bullet(BulletType.ROCKET);
      _rockets.add(bullet);
    }
  }

  Bullet getBullet(int bulletType) {
    var bullet;
    switch(bulletType) {
      case BulletType.BULLET: bullet = _bullets.removeFirst(); break;
      case BulletType.GRENADE: bullet = _grenades.removeFirst(); break;
      case BulletType.ROCKET: bullet = _rockets.removeFirst(); break;
    }

    counter = counter + 1;
    return bullet;
  }

  void putBullet(Bullet bullet) {
    if (bullet == null) return;
    switch(bullet.type) {
      case BulletType.BULLET: _bullets.addLast(bullet); break;
      case BulletType.GRENADE: _grenades.addLast(bullet); break;
      case BulletType.ROCKET: _rockets.addLast(bullet); break;
    }
  }

  Iterable getBulletList() { return _bullets.map((e) => e.hashCode); }
  Iterable getGrenadeList() { return _grenades.map((e) => e.hashCode); }
  Iterable getRocketList() { return _rockets.map((e) => e.hashCode); }
}