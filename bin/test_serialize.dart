
import 'package:giggl/gglcommon.dart';

void main() {
  Frame a = new Frame();

  a.playerId = 12345;
  a.topX = 10.123;
  a.topY = 10.456;
  a.visibleObjects = new List();

  ActorInFrame b = new ActorInFrame();

  b.id = 100001;
  b.x = 101;
  b.y = 102;
  b.orientation= 0.95 ;
  b.lifeRatio = 50 ;
  b.weaponType = WeaponType.PISTOL;
  b.weaponAmmo = 100;
  b.damageFrom = 1.5;
  b.isFiring = true;
  b.isMoving = true;


  BulletInFrame c = new BulletInFrame();

  c.id = 100002;
  c.x = 201;
  c.y = 202;
  c.orientation = 1.0;
  c.type = BulletType.GRENADE;
  c.hitObject = false;
  c.hitActor = false;
  c.timedOut = false;

  a.visibleObjects.add(b);
  a.visibleObjects.add(c);

  print(a.toString());

  Frame d = new Frame.fromString(a.toString());


  print(d.toString());
}