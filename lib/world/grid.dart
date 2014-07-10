part of gglworld;

// Class to describe properties tile element in a grid map;

class Tile {
  int surfaceType;
  Tile(this.surfaceType);
}

// Represents a map consisting of tiles

class Grid
{
  Map _grid;
  int _width, _height, _tileWidth;

  Grid(int width, int height, int tileWidth) {
    _width = width;
    _height = height;
    _grid = new Map();
    _tileWidth = tileWidth;
  }

  Tile get(int x, int y) {
    return _grid[ (y * _width) + x];
  }

  void set(int x, int y, Tile tile) {
    _grid[ (y * _width) + x ] = tile;
  }

  bool passable(int x, int y) {
    if (x < 0 || x >= _width || y <0 || y >= _height)
      return false;

    var tile = get(x,y);

    if (tile == null)
      return true;

    return tile.surfaceType != Surface.NON_PASSABLE;
  }


  bool bumpLeft(num x, num y, num radius) {
    int gridX = (x / _tileWidth).floor();
    int gridY = (y / _tileWidth).floor();

    int gridYBot = ((y + radius)/ _tileWidth).floor();
    int gridYTop = ((y - radius)/ _tileWidth).floor();

    if (!passable(gridX,gridY))
      return true;

    if (!passable(gridX-1,gridY) && ( (x - radius) - (gridX * _tileWidth) < 0))
      return true;

    if (gridYBot > gridY) {
      if (!passable(gridX-1,gridY+1) && ( (x - radius) - (gridX * _tileWidth) < 0))
        return true;
    }

    if(gridYTop < gridY) {
      return (!passable(gridX-1,gridY-1) && ( (x - radius) - (gridX * _tileWidth) < 0));
    }

    return false;
  }

  bool bumpRight(num x, num y, num radius) {
      int gridX = (x / _tileWidth).floor();
      int gridY = (y / _tileWidth).floor();

      int gridYBot = ((y + radius)/ _tileWidth).floor();
      int gridYTop = ((y - radius)/ _tileWidth).floor();

      if (!passable(gridX,gridY))
        return true;

      if (!passable(gridX+1,gridY) && ( ((gridX + 1) * _tileWidth) - (x + radius) <= 0))
        return true;

      if (gridYBot > gridY) {
        if (!passable(gridX+1,gridY+1) && ( ((gridX + 1) * _tileWidth) - (x + radius) <= 0))
          return true;
      }

      if(gridYTop < gridY) {
        return (!passable(gridX+1,gridY-1) && ( ((gridX + 1) * _tileWidth) - (x + radius) <= 0));
      }

      return false;

  }

  bool bumpTop(num x, num y, num radius) {
      int gridX = (x / _tileWidth).floor();
      int gridY = (y / _tileWidth).floor();

      int gridXRight = ((x + radius)/ _tileWidth).floor();
      int gridXLeft = ((x - radius)/ _tileWidth).floor();

      if (!passable(gridX,gridY))
        return true;

      if (!passable(gridX,gridY-1) && ( (y - radius) - (gridY * _tileWidth) <= 0))
        return true;

      if (gridXRight > gridX) {
        if (!passable(gridX+1,gridY-1) && ( (y - radius) - (gridY * _tileWidth) <= 0))
          return true;
      }

      if(gridXLeft < gridX) {
        return (!passable(gridX-1,gridY-1) && ( (y - radius) - (gridY * _tileWidth) <= 0));
      }

      return false;
  }

  bool bumpBottom(num x, num y, num radius) {
      int gridX = (x / _tileWidth).floor();
      int gridY = (y / _tileWidth).floor();

      int gridXRight = ((x + radius)/ _tileWidth).floor();
      int gridXLeft = ((x - radius)/ _tileWidth).floor();

      if (!passable(gridX,gridY))
        return true;

      if (!passable(gridX,gridY+1) && ( ((gridY + 1) * _tileWidth) - (y + radius) <= 0))
        return true;

      if (gridXRight > gridX) {
        if (!passable(gridX+1,gridY+1) && ( ((gridY + 1) * _tileWidth) - (y + radius) <= 0))
          return true;
      }

      if(gridXLeft < gridX) {
        return (!passable(gridX-1,gridY+1) && ( ((gridY + 1) * _tileWidth) - (y + radius) <= 0));
      }

      return false;
  }


  int width() => _width;
  int height() => _height;
  int tileWidth() => _tileWidth;
}