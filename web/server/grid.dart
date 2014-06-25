part of giggl;

// Class to describe properties tile element in a grid map;

class Tile {
  int surfaceType;
  Tile(this.surfaceType);
}

// Represents a map consisting of tiles

class Grid
{
  List<Tile> _grid;
  int _width, _height;

  Grid(int width, int height) {
    _width = width;
    _height = height;
    _grid = new List(width * height);
  }

  Tile Get(int x, int y) {
    return _grid[ (y * _width) + x];
  }

  void Set(int x, int y, Tile tile) {
    _grid[ (y * _width) + x ] = tile;
  }

  int width() => _width;
  int height() => _height;
}