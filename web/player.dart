part of giggl;

class Player extends FlipBook {
  Player()
    :super(ResourceHandler.bmpStride, 10) {
    this.x = 1; // initialize just in case
    this.y = 1;
    stage.juggler.add(this);
  }
}