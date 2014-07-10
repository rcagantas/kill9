part of gglserver;

// Ammo

class Bullet extends WorldObject {

  num maxDistance;
  num startX, startY;
  bool _expired = false;
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

    }
    //reached max distance?
    if (!_expired) {
      var p2 = new math.Point(startX,startY);
      _expired = (new math.Point(x,y).distanceTo(p2) > BulletProps.DISTANCE);
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

  void fire() {
   print("firing some generic weapon");
   return null;
  }

  void stop() {

  }
}

class Pistol extends Weapon {

  var name = "Pistol";
  bool _pressed = false;

  Pistol(owner):super(owner);

  void fire() {
    if (_pressed) return;

    _pressed = true;
    print ("firing $name");
    var bullet = owner.myWorld.bullets.getBullet()
      ..init(owner.x, owner.y, owner.orientation, owner.radius);

    owner.myWorld.addObject(bullet);
  }

  void stop() {
    _pressed = false;
  }
}

class GrenadeLauncher extends Weapon {

  var name = "Grenade Launcher";

  GrenadeLauncher(owner):super(owner);

  void fire() {
    print ("firing $name");
    var grenade = new Grenade(10,300,owner.orientation,5)
        ..x = owner.x
        ..y = owner.y
        ..startX = owner.x
        ..startY = owner.y;

    owner.myWorld.addObject(grenade);

  }
}

