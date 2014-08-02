library gglclient;

import 'dart:html' as html;
import 'dart:math' as math;
import 'package:stagexl/stagexl.dart';
import 'package:stagexl_particle/stagexl_particle.dart';
import 'package:giggl/gglcommon.dart';

part 'client/arena.dart';
part 'client/player_sprite.dart';
part 'client/input_handler.dart';
part 'client/resource_handler.dart';
part 'client/tile_sheet.dart';
part 'client/bullet_sprite.dart';
part 'client/mini_map.dart';
part 'client/net_client.dart';

/**
 * global variables
 */
final html.CanvasElement canvas = html.querySelector('#gglstage');
final Stage stage = new Stage(canvas/*, webGL: true*/);
final ResourceManager resMgr = new ResourceManager();
final RenderLoop renderLoop = new RenderLoop();