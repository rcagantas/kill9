part of gglworld;

class WorldObject {

  // reference to the world
  World myWorld;

  int objectType;

  // velocity
  num xVelocity = 0;
  num yVelocity = 0;
  num angleVelocity = 0;

  // position and orientation
  num x = 0;
  num y = 0;
  num radius;
  num orientation = 0; // orientation in radians, 0 points up, angle expressed clockwise

  // speed and turn rate (ideally constant for a specific instance of an object)
  num speed;
  num turnRate;

  // observable events;
  Subject movementEvent = new Subject();

  final _fullCircle = 2 * math.PI;

  String name;

  WorldObject (this.radius,this.speed, this.turnRate);

  math.Point projectLocation(elapsedTime) {
    return new math.Point(
        x + xVelocity * elapsedTime,
        y + yVelocity * elapsedTime);
  }

  void doPhysics(num elapsedTime, Map objects) {

  }

  void update(num elapsedTime) {

    x = x + xVelocity * elapsedTime;
    y = y + yVelocity * elapsedTime;

    orientation = orientation + angleVelocity * elapsedTime;

    if (orientation > _fullCircle) {
      orientation = orientation - _fullCircle;
    }
    else if (orientation < 0) {
      orientation = _fullCircle + orientation;
    }
    //if (xVelocity !=0  || yVelocity !=0 || angleVelocity != 0) {
      movementEvent.notify(this, GglEvent.OBJECT_MOVED);
    //}
  }

  bool isInView(num ox, num oy, num length) {
    num w = WorldConst.VIEWPORT_WIDTH/2;
    num h = WorldConst.VIEWPORT_HEIGHT/2;
    num minX = ox - w, maxX = ox + w;
    num minY = oy - h, maxY = oy + h;
    return
          (minX - length < x) && (x < maxX + length) &&
          (minY - length < y) && (y < maxY + length);
  }

  bool willBump(WorldObject object, num elapsedTime) {
    math.Point p1 = this.projectLocation(elapsedTime);
    math.Point p2 = new math.Point(object.x, object.y);

    return (p1.distanceTo(p2) < (radius + object.radius));
  }
}

class WeaponDrop extends WorldObject {

  int weaponType;
  math.Random random = new math.Random();

  WeaponDrop(World world):super(ActorProps.RADIUS,0,0) {
    myWorld = world;
  }

  void spawn(World myWorld) {
    this.myWorld = myWorld;
    // roll random weapon;
    math.Random random = new math.Random();

    weaponType = random.nextInt(3) + 1;
    // respawn to random location;
    myWorld.addObject(this);
    myWorld.spawnRandomly(this);
    print("[world ${myWorld.hashCode}] weapon drop ${this.hashCode} " +
        "of type ${weaponType} at ${this.x},${this.y}");
  }

  void pickedUp(Actor actor) {
    actor.addWeapon(weaponType);
    myWorld.removeObject(this);
  }
}

class Actor extends WorldObject {
  List<Weapon> weapons = new List<Weapon>();
  num weaponIndex = 0;
  Weapon weapon;

  num _xVelocityHolder = 0;
  num _yVelocityHolder = 0;
  num _45degreeSpeed = 0;

  static const int MAX_LIFE = 100;
  int life = 100;
  int killCount = 0;
  int deathCount = 0;
  num damageFrom = 0;
  num index = 0;

  Actor():
    super(ActorProps.RADIUS,
        ActorProps.SPEED,
        ActorProps.TURN_RATE)
  {
    weapon = new Pistol(this);
    weapons.add(weapon);

    _45degreeSpeed = speed * math.sin(math.PI/4);
  }

  void addWeapon(int type) {
    bool found = false;
    if (weapon.weaponType == type) {
      found = true;
      weapon.addAmmo();
    }

    weapons.forEach((w) {
      if (w.weaponType == type) {
        found = true;
        w.addAmmo();
      }
    });

    if (found) {
      switchWeaponTo(type);
    } else {
      Weapon newWeapon = null;

      if (type == WeaponType.GRENADE_LAUNCHER)
        newWeapon = new GrenadeLauncher(this);
      else if (type == WeaponType.RIFLE)
        newWeapon = new Rifle(this);
      else if (type == WeaponType.ROCKET_LAUNCHER)
        newWeapon = new RocketLauncher(this);

      if (newWeapon != null) {
        weapons.add(newWeapon);
        switchWeaponTo(type);
      }
    }
  }

  void switchWeaponTo(num type) {
    while (weapon.weaponType != type) {
      switchWeapon();
    }
  }

  void switchWeapon() {
    if (life == 0 || weapons.isEmpty) return;
    weaponIndex++;
    if (weaponIndex >= weapons.length) weaponIndex = 0;
    weapon = weapons[weaponIndex];
  }

  void moveLeft() {
    if (yVelocity > 0) {
      xVelocity = -_45degreeSpeed;
      yVelocity = _45degreeSpeed;
    } else if (yVelocity < 0) {
      xVelocity = -_45degreeSpeed;
      yVelocity = - _45degreeSpeed;
    } else {
      xVelocity = -speed;
    }
  }

  void moveUp () {
    if (xVelocity > 0) {
      xVelocity = _45degreeSpeed;
      yVelocity = -_45degreeSpeed;
    } else if (xVelocity < 0) {
      xVelocity = -_45degreeSpeed;
      yVelocity = -_45degreeSpeed;
    } else {
      yVelocity = -speed;
    }
  }

  void moveRight() {
    if (yVelocity > 0) {
      xVelocity = _45degreeSpeed;
      yVelocity = _45degreeSpeed;
    } else if (yVelocity < 0) {
      xVelocity = _45degreeSpeed;
      yVelocity = - _45degreeSpeed;
    } else {
      xVelocity = speed;
    }
  }

  void moveDown () {
    if (xVelocity > 0) {
      xVelocity = _45degreeSpeed;
      yVelocity = _45degreeSpeed;
    } else if (xVelocity < 0) {
      xVelocity = -_45degreeSpeed;
      yVelocity = _45degreeSpeed;
    } else {
      yVelocity = speed;
    }
  }

  void stopLeftRightMove () {
    xVelocity = 0;
    if (yVelocity < 0)
      yVelocity = -speed;
    else if (yVelocity > 0)
      yVelocity = speed;
  }

  void stopTopDownMove () {
    yVelocity = 0;
    if (xVelocity < 0)
      xVelocity = -speed;
    else if (xVelocity > 0)
      xVelocity = speed;
  }

  bool isMoving() {
    return xVelocity != 0 || yVelocity != 0;
  }

  void turnClockwise() {
    angleVelocity = turnRate;
  }

  void turnCounterClockwise() {
    angleVelocity = -turnRate;
  }

  void turnIncrement(num increment) {
    if (life == 0) return;
    orientation += increment;
  }

  void turnToPoint(num xPt,num yPt) {
    if (life == 0) return;
    orientation = math.PI - math.atan2(xPt-x, yPt-y);
  }

  void stopTurn() {
    angleVelocity = 0;
  }

  void _pauseLeftRightMove() {
    _xVelocityHolder = xVelocity;
    xVelocity = 0;
  }

  void _resumeLeftRightMove() {
    if (_xVelocityHolder == 0) return;

    xVelocity = _xVelocityHolder;
    _xVelocityHolder = 0;
  }

  void _pauseTopDownMove() {
    _yVelocityHolder = yVelocity;
    yVelocity = 0;
  }

  void _resumeTopDownMove() {
    if (_yVelocityHolder == 0) return;

    yVelocity = _yVelocityHolder;
    _yVelocityHolder = 0;
  }

  void takeDamage(int damage, Bullet dmgFrom) {
    life = life - damage;
    damageFrom = math.atan2(dmgFrom.y - y, dmgFrom.x - x) - math.PI/2;

    if (life <= 0) {
      deathCount = deathCount + 1;
      dmgFrom.fromWeapon.owner.killCount = dmgFrom.fromWeapon.owner.killCount + 1;
      life = 0;
      new Timer(new Duration(seconds: 10), () {
        if (myWorld == null) return;
        myWorld.spawnRandomly(this);
        life = 100;
      });
      print ("[world ${myWorld.hashCode}] ${dmgFrom.fromWeapon.owner.hashCode} (${dmgFrom.fromWeapon.owner.killCount} kills) -> $hashCode ($deathCount death)");
    }
  }

  void doPhysics(num elapsedTime, Map objects) {
    
    if (life == 0 || myWorld == null) return;

    objects.forEach((key,object) {
      if (key != this.hashCode) {
        if (object is Actor && object.life == 0) {
          // walk over dead body
        } else if (object is WeaponDrop &&
          willBump(object, elapsedTime)) {
          // pick up weapon
          object.pickedUp(this);
          print("[world ${myWorld.hashCode}] ${this.hashCode} picked up weapon ${object.weaponType}");
        } else if (willBump(object, elapsedTime) ) {
          _pauseLeftRightMove();
          _pauseTopDownMove();
        }
      }
    });

    // wall collision
    var newLoc = projectLocation(elapsedTime);

    if(newLoc.x < x) {
      if (myWorld.grid.bumpLeft(newLoc.x, y, radius)) {
        _pauseLeftRightMove();
      }
    }
    else if (newLoc.x > x) {
      if (myWorld.grid.bumpRight(newLoc.x, y, radius)) {
        _pauseLeftRightMove();
      }
    }

    if(newLoc.y < y) {
      if (myWorld.grid.bumpTop(x, newLoc.y, radius)) {
        _pauseTopDownMove();
      }
    }
    else if(newLoc.y > y) {
      if (myWorld.grid.bumpBottom(x, newLoc.y, radius)) {
        _pauseTopDownMove();
      }
    }

    super.doPhysics(elapsedTime, objects);
  }

  void update(num elapsedTime) {
    if (life == 0) return;
    super.update(elapsedTime);

    _resumeTopDownMove();
    _resumeLeftRightMove();
  }

}

