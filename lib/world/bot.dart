part of gglworld;

class Bot extends Actor {
  math.Random random = new math.Random();
  Cmd c = new Cmd();
  
  Bot() { 
    new Timer.periodic(new Duration(milliseconds: Frame.rate), sendCmd); 
    new Timer.periodic(new Duration(milliseconds: Frame.rate * 3), doBotThings);
  }
  
  void doBotThings(Timer timer) {
    c.id = this.hashCode;
    if (random.nextBool()) {
      if (this.weapon.ammo == 0) c.swap = 1;
      c.fire = 1;
    }
    if (random.nextBool()) c.moveX = random.nextInt(3)-1;
    if (random.nextBool()) c.moveY = random.nextInt(3)-1;
    if (random.nextBool()) c.moveR = random.nextInt(3)-1;
  }
  
  void sendCmd(Timer timer) {
    if (this.myWorld == null) return;
    c.name = this.name;
    this.myWorld.action2(c);
    c.fire = 0;
    c.swap = 0;
  }
}

class SmarterBot extends Bot {
    
  num distance(num x1, num y1, num x2, num y2) {
    return math.sqrt(math.pow(x1-x2, 2) + math.pow(y1-y2,2));
  }
  
  num variance(num max) {
    num sign = random.nextBool()? 1: -1;
    return sign * random.nextInt(max);
  }

  void doBotThings(Timer timer) {
    if (this.myWorld == null) return;
    num ammoCount = double.MAX_FINITE;
    c.id = this.hashCode;

    num distanceToNearestPlayer = double.MAX_FINITE;
    num distanceToWeaponDrop = double.MAX_FINITE;
    
    Frame pf = this.myWorld.getFrameDetail(this.hashCode);
    num mx, my, ex, ey, wx, wy;
    
    pf.visibleObjects.forEach((obj) {
      if (obj is ActorInFrame) {
        if (obj.id == hashCode) { 
          mx = obj.x; my = obj.y;
          ammoCount = obj.weaponAmmo;
        } 
      }
    });
    
    pf.visibleObjects.forEach((obj) {
      if (obj.id != this.hashCode && // not self
          obj is ActorInFrame &&     // is player
          obj.lifeRatio > 0) {       // is alive
        num de = distance(mx, my, obj.x, obj.y);
        if (de < distanceToNearestPlayer) {
          distanceToNearestPlayer = de;
          ex = obj.x; ey = obj.y;
        }       
      } else if (obj is WeaponDropInFrame) {
        num dw = distance(mx, my, obj.x, obj.y);
        if (dw < distanceToWeaponDrop) {
          distanceToWeaponDrop = dw;
          wx = obj.x; wy = obj.y;
        }
      }
    });
    

    if (distanceToWeaponDrop < double.MAX_FINITE) {
      c.moveX = (mx < wx? 1: -1) + variance(5);
      c.moveY = (my < wy? 1: -1) + variance(5);
    } else if (distanceToNearestPlayer < double.MAX_FINITE &&
        distanceToNearestPlayer > 200) {
      c.moveX = mx < ex? 1: -1;
      c.moveY = my < ey? 1: -1;      
    } else {
      if (random.nextBool()) c.moveX = random.nextInt(3)-1;
      if (random.nextBool()) c.moveY = random.nextInt(3)-1;
      if (random.nextBool()) c.moveR = random.nextInt(3)-1;
    }
    
    if (distanceToNearestPlayer < double.MAX_FINITE) {
      if (ammoCount == 0) c.swap = 1;
      c.fire = 1;
      c.mouseX = ex + variance(5) - mx;
      c.mouseY = ey + variance(5) - my;
    } else {
      c.fire = 0;
    }
  }  
}

class RandomWalker extends Bot {
  //Actor player;
  math.Random random = new math.Random();
  Timer _timer = null, _fireTimer = null, _stopTimer = null;

  void start() {
    if (_timer == null) {
      _timer = new Timer.periodic(new Duration(milliseconds: 2000), _walkRandomly);
    }
  }

  void stop() {
    if (_timer != null)     _timer.cancel();
    if (_fireTimer != null) _fireTimer.cancel();
    if (_stopTimer != null) _stopTimer.cancel();
    _timer = null;
    _fireTimer = null;
    _stopTimer = null;
  }

  void _stopFiring(Timer timer) {
    this.weapon.stop();
  }

  void _fire(Timer timer) {
    if (this.life == 0) return;
    var fire = random.nextInt(2);
    if (fire == 0) {
      while (this.weapon.ammo == 0) this.switchWeapon();
      this.weapon.fire();
    }
  }

  void _walkRandomly(Timer timer)  {
    this.stopLeftRightMove();
    this.stopTopDownMove();
    this.stopTurn();

    if (_fireTimer == null) {
      _fireTimer = new Timer.periodic(new Duration(milliseconds: 200), _fire);
      _stopTimer = new Timer.periodic(new Duration(milliseconds: 10), _stopFiring);
    }

    var move = random.nextInt(3);

    if (move == 0) {
      this.moveLeft();
    } else if (move == 1) {
      this.moveRight();
    }

    move = random.nextInt(3);

    if (move == 0) {
      this.moveUp();
    } else if (move == 1) {
      this.moveDown();
    }

    move = random.nextInt(3);

    if (move == 0) {
      this.turnClockwise();
    } else if (move == 1) {
      this.turnCounterClockwise();
    }
  }
}