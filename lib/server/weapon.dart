part of gglserver;

// base classes

class Weapon {

  WorldActor owner;

  Weapon(this.owner);

  WorldObject fire() {
    print("firing some generic weapon");
    return null;
  }
}

class Bullet extends WorldObject {

  num maxDistance;
  num startX, startY;

  Bullet(radius, speed, orientation, maxDistance):super(radius,speed,0) {
    this.orientation = orientation;
    this.maxDistance = maxDistance;

    xVelocity = speed * math.sin(orientation);
    yVelocity = -speed * math.cos(orientation);
  }

  void update(elapsedTime) {
    var p1 = new Point(x,y);
    var p2 = new Point(startX,startY);
    if (p1.distanceTo(p2) < maxDistance) {
      super.update(elapsedTime);
    }
    else {
      myWorld.removeObject(this);
    }
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

    var p1 = new Point(x,y);
    var p2 = new Point(startX,startY);

    if (expireTime < 0) {
      myWorld.removeObject(this);
      expires.notify(this, GglEvent.GrenadeExpires);

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

// specifics

class Pistol extends Weapon {

  var name = "Pistol";

  Pistol(owner):super(owner);

  WorldObject fire() {
    print ("firing $name");
    var bullet = new Bullet(10,1200,owner.orientation,1000)
        ..x = owner.x
        ..y = owner.y
        ..startX = owner.x
        ..startY = owner.y;

    owner.myWorld.addObject(bullet);

    return bullet;

  }
}

class GrenadeLauncher extends Weapon {

  var name = "Grenade Launcher";

  GrenadeLauncher(owner):super(owner);

  WorldObject fire() {
    print ("firing $name");
    var grenade = new Grenade(10,300,owner.orientation,5)
        ..x = owner.x
        ..y = owner.y
        ..startX = owner.x
        ..startY = owner.y;

    owner.myWorld.addObject(grenade);

    return grenade;

  }
}

