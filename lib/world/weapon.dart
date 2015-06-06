part of gglworld;

abstract class AmmoBehavior {
   void applyPhysics(Bullet bullet, num elapsedTime, Map objects);
}

class BulletBehavior implements AmmoBehavior {
  void applyPhysics(Bullet bullet, num elapsedTime, Map objects) {
    //hit someone?
    objects.forEach((key,object) {
      if (key != this.hashCode && object is Actor) {
        if (object is Actor && object.life == 0) {}
        else if (bullet.willBump(object, elapsedTime)) {
          (object as Actor).takeDamage(BulletProps.DAMAGE, bullet);
          bullet.expired = true;
          bullet.hitActor = bullet.expired? true: false;
        }
      }
    });

    //hit walls?
    if (!bullet.expired) {
      math.Point newPos = bullet.projectLocation(elapsedTime);
      bullet.expired =  (bullet.myWorld.grid.bumpLeft(newPos.x, newPos.y, bullet.radius) ||
          bullet.myWorld.grid.bumpRight(newPos.x, newPos.y, bullet.radius)||
          bullet.myWorld.grid.bumpTop(newPos.x, newPos.y, bullet.radius) ||
          bullet.myWorld.grid.bumpBottom(newPos.x, newPos.y, bullet.radius));
      bullet.hitObject = bullet.expired? true: false;
    }

    //reached max distance?
    if (!bullet.expired) {
      var p2 = new math.Point(bullet.startX,bullet.startY);
      bullet.expired = (new math.Point(bullet.x,bullet.y).distanceTo(p2) > BulletProps.DISTANCE);
      bullet.timedOut = bullet.expired? true: false;
    }
  }
}

class GrenadeBehavior implements AmmoBehavior {

  void doAOEDamage(Bullet bullet, Map objects, num elapsedTime) {
    WorldObject ref = new WorldObject(300,0,0);
    ref.x = bullet.x;
    ref.y = bullet.y;
    ref.xVelocity = bullet.xVelocity;
    ref.yVelocity = bullet.yVelocity;

    objects.forEach((key,object) {
      if (!(object is Actor)) {}
      else if (object is Actor && object.life == 0) {}
      else  {
        ref.radius = GrenadeProps.AOE;
        if (ref.willBump(object, elapsedTime)) {
          (object as Actor).takeDamage(GrenadeProps.DAMAGE, bullet);
          ref.radius = GrenadeProps.AOE/3 * 2;
          if (ref.willBump(object, elapsedTime)) {
            (object as Actor).takeDamage(GrenadeProps.DAMAGE, bullet);
            ref.radius = GrenadeProps.AOE/3;
            if (ref.willBump(object, elapsedTime)) {
              (object as Actor).takeDamage(GrenadeProps.DAMAGE, bullet);
            }
          }
        }
      }
    });
  }

  void applyPhysics(Bullet bullet, num elapsedTime, Map objects) {

    // expired?

    bullet.expireTime = bullet.expireTime - elapsedTime;

    if (bullet.expireTime <0) {
      // check damage
      bullet.expired = true;
      bullet.hitObject = true;
      bullet.timedOut = true;
    }

    if(!bullet.expired) {
      objects.forEach((key,object) {
        if (key != this.hashCode && object is Actor) {
          if (object is Actor && object.life == 0) {}
          else if (bullet.willBump(object, elapsedTime)) {
            bullet.expired = true;
            bullet.hitObject = true;
          }
        }
      });
    }

    if(!bullet.expired) {

      // bumped walls?

      //var p1 = new math.Point(bullet.x,bullet.y);
      //var p2 = new math.Point(bullet.startX,bullet.startY);

      var newLoc = bullet.projectLocation(elapsedTime);

      if (bullet.myWorld.grid.bumpLeft(newLoc.x, bullet.y, bullet.radius) ||
          bullet.myWorld.grid.bumpRight(newLoc.x, bullet.y, bullet.radius)) {
        bullet.xVelocity = -bullet.xVelocity;
      }

      if (bullet.myWorld.grid.bumpTop(bullet.x, newLoc.y, bullet.radius) ||
          bullet.myWorld.grid.bumpBottom(bullet.x, newLoc.y, bullet.radius)) {
        bullet.yVelocity = -bullet.yVelocity;
      }
    } else {
      doAOEDamage(bullet, objects, elapsedTime);
    }
  }
}

class RocketBehavior implements AmmoBehavior {

  void doAOEDamage(Bullet bullet, Map objects, num elapsedTime) {
    WorldObject ref = new WorldObject(300,0,0);
    ref.x = bullet.x;
    ref.y = bullet.y;
    ref.xVelocity = bullet.xVelocity;
    ref.yVelocity = bullet.yVelocity;

    objects.forEach((key,object) {
      if (!(object is Actor)) {}
      else if (object is Actor && object.life == 0) {}
      else  {
        ref.radius = RocketProps.AOE;
        if (ref.willBump(object, elapsedTime)) {
          (object as Actor).takeDamage(GrenadeProps.DAMAGE, bullet);
          ref.radius = RocketProps.AOE/3 * 2;
          if (ref.willBump(object, elapsedTime)) {
            (object as Actor).takeDamage(GrenadeProps.DAMAGE, bullet);
            ref.radius = RocketProps.AOE/3;
            if (ref.willBump(object, elapsedTime)) {
              (object as Actor).takeDamage(GrenadeProps.DAMAGE, bullet);
            }
          }
        }
      }
    });
  }

  void applyPhysics(Bullet bullet, num elapsedTime, Map objects) {

    if(!bullet.expired) {
      objects.forEach((key,object) {
        if (key != this.hashCode && object is Actor) {
          if (object is Actor && object.life == 0) {}
          else if (bullet.willBump(object, elapsedTime)) {
            bullet.expired = true;
            bullet.hitObject = true;
          }
        }
      });
    }

    if(!bullet.expired) {

      math.Point newPos = bullet.projectLocation(elapsedTime);
      bullet.expired =  (bullet.myWorld.grid.bumpLeft(newPos.x, newPos.y, bullet.radius) ||
          bullet.myWorld.grid.bumpRight(newPos.x, newPos.y, bullet.radius)||
          bullet.myWorld.grid.bumpTop(newPos.x, newPos.y, bullet.radius) ||
          bullet.myWorld.grid.bumpBottom(newPos.x, newPos.y, bullet.radius));
      bullet.hitObject = bullet.expired? true: false;
    }

    if (!bullet.expired) {
      var p2 = new math.Point(bullet.startX,bullet.startY);
      bullet.expired = (new math.Point(bullet.x,bullet.y).distanceTo(p2) > BulletProps.DISTANCE);
      bullet.timedOut = bullet.expired? true: false;
    }

    if (bullet.expired) {
      doAOEDamage(bullet, objects, elapsedTime);
    }
  }
}

class Bullet extends WorldObject {
  int _type;
  num maxDistance;
  num expireTime;
  num startX, startY;
  bool expired = false;
  bool hitObject = false, hitActor = false, timedOut = false;
  int damage;
  Map behaviors;
  Weapon fromWeapon;
  int owner;

  Bullet():super(BulletProps.RADIUS,BulletProps.SPEED,0);

  void set type(int bulletType) {
    if (bulletType == BulletType.GRENADE) {
      radius = GrenadeProps.RADIUS;
      speed = GrenadeProps.SPEED;
      damage = GrenadeProps.DAMAGE;
      expireTime = GrenadeProps.EXPIRE_SEC;
      _type = BulletType.GRENADE;
    } else if (bulletType == BulletType.ROCKET) {
      radius = RocketProps.RADIUS;
      speed = RocketProps.SPEED;
      damage = RocketProps.DAMAGE;
      maxDistance = RocketProps.DISTANCE;
      _type = BulletType.ROCKET;
    } else {
      // default to regular bullets
      radius = BulletProps.RADIUS;
      speed = BulletProps.SPEED;
      damage = BulletProps.DAMAGE;
      maxDistance = BulletProps.DISTANCE;
      _type = BulletType.BULLET;
    }
  }

  num get type { return _type; }

  void init(num x, num y, num orientation, num radius, Weapon weapon) {
    xVelocity = speed * math.sin(orientation);
    yVelocity = -speed * math.cos(orientation);
    this.x = x + ((radius + this.radius) * math.sin(orientation));
    this.y = y - ((radius + this.radius) * math.cos(orientation));
    this.orientation = orientation;
    this.startX = this.x;
    this.startY = this.y;
    hitObject =
    hitActor =
    timedOut =
    expired = false;
    fromWeapon = weapon;
  }

  void doPhysics(num elapsedTime, Map objects) {
    AmmoBehavior behavior = behaviors[type];
    behavior.applyPhysics(this, elapsedTime, objects);
  }

  void update(elapsedTime) {
    if (!expired) {
      super.update(elapsedTime);
    } else {
      myWorld.bullets.putBullet(this);
      myWorld.removeObject(this);
    }
  }
}

class BulletFactory {

  Queue<Bullet> _bullets = new Queue();
  Map bulletBehaviors;
  int counter = 0;

  BulletFactory(int bulletCount, this.bulletBehaviors) {
    for (int i = 0; i < bulletCount; i++) addBullet();
  }

  void addBullet() {
    var bullet = new Bullet()
      ..behaviors = bulletBehaviors;
    _bullets.add(bullet);
  }

  Bullet getBullet() {
    if (_bullets.isEmpty) addBullet();
    var bullet = _bullets.removeFirst();
    counter = counter + 1;
    // print("Borrowed ${_bullets.length}: Total fire: $counter");
    return bullet;
  }

  void putBullet(Bullet bullet) {
    if (bullet == null) {
      print ("this should not happen");
    }
    _bullets.addLast(bullet);
    // print("Returned: ${_bullets.length}");
  }

  Iterable getBulletIter() {
    return _bullets.map((e) => e.hashCode);
  }
}

// Weapons

class Weapon {

  Actor owner;
  Weapon(this.owner);
  bool isFiring = false;
  bool isPressed = false;
  int weaponType;
  num ammo;

  void fire() {
   print("firing some generic weapon");
   return null;
  }

  void stop() {
    isFiring = false;
  }

  void addAmmo() {
    // do nothing
  }
}

class WeaponImpl extends Weapon {
  Timer reloader;
  num ammo = 0;
  num weaponType = WeaponType.PISTOL;
  num bulletType = BulletType.BULLET;
  num addtlAmmo = 0;
  num reloadTime = 1000 * .20;
  bool isAutomatic = false;
  bool limited = true;

  WeaponImpl(Actor owner) : super(owner);

  void addAmmo() {
    ammo += addtlAmmo;
  }

  void fire() {
    if (owner.life == 0) return;
    if (!isAutomatic) _fireSingle();
    else _fireAuto();
  }

  void _fireSingle() {
    if (isPressed) {
      isFiring = false;
      return;
    }
    isPressed = true;
    if (reloader != null) return;
    shootProjectile();
  }

  void _fireAuto() {
    if (reloader != null) return;
    shootProjectile();
  }

  void stop() {
    isFiring = false;
    isPressed = false;
  }

  void shootProjectile() {
    isFiring = true;
    if (ammo == 0) return;
    var bullet = owner.myWorld.bullets.getBullet()
      ..type = bulletType
      ..owner = owner.hashCode
      ..init(owner.x, owner.y,
          owner.orientation, owner.radius + 5, this);

    owner.myWorld.addObject(bullet);
    if (limited && ammo > 0) ammo--;

    reloader = new Timer(
        new Duration(milliseconds: reloadTime),
        _reload);
  }

  void _reload() {
    reloader.cancel();
    reloader = null;
  }
}


class Pistol extends WeaponImpl {
  Pistol(Actor owner) : super(owner) {
    ammo = 999;
    weaponType = WeaponType.PISTOL;
    bulletType = BulletType.BULLET;
    reloadTime = WeaponReloadTime.PISTOL;
    isAutomatic = true;
    limited = false;
  }
}

class Rifle extends WeaponImpl {
  Rifle(Actor owner) : super(owner) {
    ammo = WeaponAmmo.RIFLE_AMMO;
    weaponType = WeaponType.RIFLE;
    bulletType = BulletType.BULLET;
    reloadTime = WeaponReloadTime.RIFLE;
    addtlAmmo = WeaponAmmo.RIFLE_AMMO;
    isAutomatic = true;
  }
}

class GrenadeLauncher extends WeaponImpl {
  GrenadeLauncher(Actor owner) : super(owner) {
    ammo = WeaponAmmo.GRENADE_AMMO;
    weaponType = WeaponType.GRENADE_LAUNCHER;
    bulletType = BulletType.GRENADE;
    reloadTime = WeaponReloadTime.GRENADE_LAUNCHER;
    addtlAmmo = WeaponAmmo.GRENADE_AMMO;
  }
}

class RocketLauncher extends WeaponImpl {
  RocketLauncher(Actor owner) : super(owner) {
    ammo = WeaponAmmo.ROCKET_AMMO;
    weaponType = WeaponType.ROCKET_LAUNCHER;
    bulletType = BulletType.ROCKET;
    reloadTime = WeaponReloadTime.ROCKET_LAUNCHER;
    addtlAmmo = WeaponAmmo.ROCKET_AMMO;
  }
}
