part of gglworld;

class RandomWalker {

  Actor player;
  math.Random random = new math.Random();
  Timer _timer, _fireTimer = null, _stopTimer;

  RandomWalker(this.player);

  void start() {
    if (_timer == null) {
      _timer = new Timer.periodic(new Duration(milliseconds: 2000), _walkRandomly);
    }
  }

  void stop() {
    _timer.cancel();
    _fireTimer.cancel();
    _stopTimer.cancel();
  }

  void _stopFiring(Timer timer) {
    player.weapon.stop();
  }

  void _fire(Timer timer) {
    if (player.life == 0) return;
    var fire = random.nextInt(2);
    if (fire == 0) player.weapon.fire();
  }

  void _walkRandomly(Timer timer)  {
    player.stopLeftRightMove();
    player.stopTopDownMove();
    player.stopTurn();

    if (_fireTimer == null) {
      _fireTimer = new Timer.periodic(new Duration(milliseconds: 200), _fire);
      _stopTimer = new Timer.periodic(new Duration(milliseconds: 10), _stopFiring);
    }

    var move = random.nextInt(3);

    if (move == 0) {
      player.moveLeft();
    } else if (move == 1) {
      player.moveRight();
    }

    move = random.nextInt(3);

    if (move == 0) {
      player.moveUp();
    } else if (move == 1) {
      player.moveDown();
    }

    move = random.nextInt(3);

    if (move == 0) {
      player.turnClockwise();
    } else if (move == 1) {
      player.turnCounterClockwise();
    }
  }
}