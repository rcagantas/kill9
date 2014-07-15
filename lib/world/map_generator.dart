part of gglworld;

class MapGenerator {
  static List<num> createSimpleRandomSurface(num width, num height) {
    List<num> surface = [];
    math.Random rand = new math.Random();
    for (num i = 0; i < height; i++) {
      for (num j = 0; j < width; j++) {
        num chance = rand.nextDouble();
        num type = (chance * 10).toInt();

        num passableMin = 7;
        num passableMax = 12;
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
