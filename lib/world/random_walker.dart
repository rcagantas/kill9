part of gglworld;

class RandomWalker extends Actor {

  //Actor player;
  math.Random random = new math.Random();
  Timer _timer = null, _fireTimer = null, _stopTimer = null;

  RandomWalker();

  void start() {
    if (_timer == null) {
      _timer = new Timer.periodic(new Duration(milliseconds: 2000), _walkRandomly);
    }
  }

  void stop() {
    if (_timer != null)     _timer.cancel();
    if (_fireTimer != null) _fireTimer.cancel();
    if (_stopTimer != null) _stopTimer.cancel();
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