part of giggl_server;

class WorldObject {
  num xVelocity;
  num yVelocity;
  num xLocation;
  num yLocation;
  num turnRate;
  num orientation;
  num radius;
  num movementSpeed;
  num turnSpeed;
  bool _forward = true;
  
  Subject eventMoved = new Subject();
  
  final _fullCircle = 2 * PI; 
    
  
  WorldObject (num x, num y, num orientation, num radius, num movementSpeed, num turnSpeed) {
    xLocation = x;
    yLocation = y;
    this.orientation = orientation;
    this.radius = radius;
    this.movementSpeed = movementSpeed;
    this.turnSpeed = turnSpeed;
   
    // new object always on standstill;
    
    xVelocity = 0;
    yVelocity = 0;
    turnRate = 0;
  }
  
  void moveForward() {
    xVelocity = movementSpeed * sin(orientation);
    yVelocity = - movementSpeed * cos(orientation);
    _forward = true;
  }
  
  void moveBackward() {
    xVelocity = - movementSpeed * sin(orientation);
    yVelocity = movementSpeed * cos(orientation);
    _forward = false;
  }
    
  void stopMove() {
    xVelocity = 0;
    yVelocity = 0;
  }
  
  void turnLeft() {
    turnRate = -turnSpeed;
  }
 
  void turnRight() {
    turnRate = turnSpeed;
  }
  
  void stopTurn() {
       turnRate = 0;
  }
    
  
  bool isMoving() {
    return !(xVelocity == 0 && yVelocity == 0);
  }
  
  bool isTurning() {
    return turnRate != 0;
  }
  void update(num elapsedTime) {
  
    if (isMoving()) {
      // recalculate based on orientation
      if (_forward) {
        moveForward();
      }
      else {
        moveBackward();
      }
      xLocation = xLocation + xVelocity * elapsedTime;
      yLocation = yLocation + yVelocity * elapsedTime;
    }
    
    if (isTurning()) {
      orientation = orientation + turnRate * elapsedTime;

      if (orientation > _fullCircle) {
        orientation = orientation - _fullCircle; 
      }
      else if (orientation < 0) {
        orientation = _fullCircle + orientation;
      }
    }
    
    if (isMoving() || isTurning()) {
      eventMoved.notify(this, GglEvent.ObjectMoved);
    }
  }
}