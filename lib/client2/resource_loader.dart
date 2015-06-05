part of gglclient2;


/**
 * web colors of players
0 3366FF
1 66FFCC
2 990099
3 FFFF33
4 FF6600
5 FF66CC
6 999933
7 66CCFF
8 006600
9 996600
 */
class ResourceLoader {
  ResourceLoader() {}

  void load() {
    String sprites = "assets/sprites2";
    String sounds = "assets/sounds2";
    String tiles = "assets/tiles2";

    for (num i = 0; i < 6; i++)
      resource.addBitmapData("p_stride$i", "$sprites/p_stride$i.png");

    resource.addBitmapData("w_pistol", "$sprites/w_pistol.png");
    resource.addBitmapData("w_rifle", "$sprites/w_rifle.png");
    resource.addBitmapData("w_grenade", "$sprites/w_grenade.png");
    resource.addBitmapData("w_rocket", "$sprites/w_rocket.png");

    resource.addBitmapData("p_torso", "$sprites/p_torso.png");
    resource.addBitmapData("p_dead", "$sprites/p_dead.png");
    resource.addBitmapData("p_head", "$sprites/p_head.png");
    resource.addBitmapData("p_mflash", "$sprites/p_mflash.png");

    resource.addBitmapData("wb_bullet", "$sprites/wb_bullet.png");
    resource.addBitmapData("wb_grenade", "$sprites/wb_grenade.png");
    resource.addBitmapData("wb_rocket", "$sprites/wb_rocket.png");

    resource.addSound("ws_reload", "$sounds/ws_reload.wav");
    resource.addSound("ws_pistol", "$sounds/ws_pistol.wav");
    resource.addSound("ws_rifle", "$sounds/ws_rifle.wav");
    resource.addSound("ws_grenade", "$sounds/ws_grenade.wav");
    resource.addSound("ws_rocket", "$sounds/ws_rocket.wav");
    resource.addSound("ws_hit", "$sounds/ws_hit.wav");
    resource.addSound("ws_explode", "$sounds/ws_explode.wav");
    resource.addSound("ws_empty", "$sounds/ws_empty.wav");
    resource.addSound("ws_footsteps", "$sounds/ws_footsteps.wav");

    resource.addBitmapData("wd_pistol", "$sprites/wd_pistol.png");
    resource.addBitmapData("wd_rifle", "$sprites/wd_rifle.png");
    resource.addBitmapData("wd_grenade", "$sprites/wd_grenade.png");
    resource.addBitmapData("wd_rocket", "$sprites/wd_rocket.png");

    resource.addBitmapData("t_crate", "$tiles/crate.png");
    resource.addBitmapData("t_tree", "$tiles/tree.png");
    resource.addBitmapData("t_floor", "$tiles/floor.png");

    for (int i = 0; i < 10; i++) {
      resource.addBitmapData("c_$i", "$sprites/c_$i.png");
      resource.addBitmapData("cd_$i", "$sprites/cd_$i.png");
    }
  }
}