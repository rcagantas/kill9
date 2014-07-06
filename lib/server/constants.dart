part of gglserver;

class Surface
{
  static const int Passable = 0;
  static const int NotPassable = 1;
}

class GglEvent
{
  static const int ObjectMoved = 1;
  static const int GrenadeExpires = 2;
}

class ActorProps {
  static const num speed = 300;
  static const num turnRate = 2;
  static const num radius = 20;
}

class WeaponType {
  static const int Pistol = 0;
  static const int Rifle = 1;
  static const int GrenadeLauncher = 2;
  static const int RocketLauncher = 3;
}

class WorldConst {
  static const int gridWidth = 20;
  static const int gridHeight = 20;
  static const num tileSize = 100;
  static const num viewPortWidth = 640;
  static const num viewPortHeight = 480;
}

class BulletProps {
  static const num radius = 2;
  static const num speed = 1500;
  static const num distance = 1000;
  static const num damage = 10;
}



