part of giggl;

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

