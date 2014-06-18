part of giggl;

class Player extends FlipBook {
  Player()
    :super(ResourceHandler.bmpStride, 10) {
    stage.juggler.add(this);
  }
}