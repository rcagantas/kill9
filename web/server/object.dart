part of giggl;

class WorldObject {

  // reference to the world
  World myWorld;

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

  WorldObject (this.radius,this.speed, this.turnRate);

  math.Point projectLocation(elapsedTime)
  {
    return new math.Point(x + xVelocity * elapsedTime, y + yVelocity * elapsedTime);
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
      movementEvent.notify(this, GglEvent.ObjectMoved);
    //}
  }
}

class WorldActor extends WorldObject
{

  Weapon weapon;
  
  num _xVelocityHolder = 0;
  num _yVelocityHolder = 0;

  WorldActor(num radius,num speed, num turnRate):super(radius, speed, turnRate)
  {
    weapon = new GrenadeLauncher(this);
  }

  void moveLeft() {
    xVelocity = -speed;
  }

  void moveUp () {
    yVelocity = -speed;
  }

  void moveRight() {
    xVelocity = speed;
  }

  void moveDown () {
    yVelocity = speed;
  }

  void stopLeftRightMove () {
    xVelocity = 0;
  }

  void stopTopDownMove () {
    yVelocity = 0;
  }

  void turnClockwise() {
    angleVelocity = turnRate;
  }

  void turnCounterClockise() {
    angleVelocity = -turnRate;
  }

  void turnToPoint(num xPt,num yPt)
  {
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

  void update(num elapsedTime) {
    // do some funky stuff here

    var newLoc = projectLocation(elapsedTime);

    if(newLoc.x < x) {
      if (myWorld.grid.bumpLeft(newLoc.x, y, radius)) {
        _pauseLeftRightMove();
        print ("bumpedLeft");
      }
    }
    else if (newLoc.x > x) {
      if (myWorld.grid.bumpRight(newLoc.x, y, radius)) {
        _pauseLeftRightMove();
        print ("bumpedRight");

      }
    }
    
    if(newLoc.y < y) {
      if (myWorld.grid.bumpTop(x, newLoc.y, radius)) {
        _pauseTopDownMove();
        print ("bumpedTop");
      }
    }
    else if(newLoc.y > y) {
      if (myWorld.grid.bumpBottom(x, newLoc.y, radius)) {
        _pauseTopDownMove();
        print ("bumpedBottom");
      }
    }
    
    super.update(elapsedTime);
    
    _resumeTopDownMove();
    _resumeLeftRightMove();
  }

}


class Projectile extends WorldObject {
  Projectile(num radius,num speed, num direction):super(radius, speed, 0) {
    xVelocity = speed * math.sin(direction);
    yVelocity = speed * math.cos(direction);
  }
}
