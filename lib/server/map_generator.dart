part of gglserver;

class MapGenerator {
  static List<num> createSimpleRandom(
      num width, num height,
      num passableMin, num passableMax) {
    List<num> surface = [];
    math.Random rand = new math.Random();
    for (num i = 0; i < width; i++) {
      for (num j = 0; j < height; j++) {
        num chance = rand.nextDouble();
        num type = (chance * 10).toInt();

        if (passableMin < i && i < passableMax &&
            passableMin < j && j < passableMax) {
          type = Surface.PASSABLE;
        }
        if (type > Surface.OBSCURING) type = Surface.PASSABLE;
        surface.add(type);
      }
    }
    return surface;
  }
}