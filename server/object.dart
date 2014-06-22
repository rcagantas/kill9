part of giggl_server;



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
  
  final _fullCircle = 2 * PI; 
    
  WorldObject (this.radius,this.speed, this.turnRate);
  
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
  
  WorldActor(num radius,num speed, num turnRate):super(radius, speed, turnRate)
  {
    weapon = new Pistol(this);
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

  void stopLefRightMove () {
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
    orientation = PI - atan2(xPt-x, yPt-y);
  }
  
  void stopTurn() {
    angleVelocity = 0;  
  }
  
  void update(num elapsedTime) {
    // do some funky stuff here
    super.update(elapsedTime);
  }

}


class Projectile extends WorldObject {
  Projectile(num radius,num speed, num direction):super(radius, speed, 0) {
    xVelocity = speed * sin(direction);
    yVelocity = speed * cos(direction);
  }
}
