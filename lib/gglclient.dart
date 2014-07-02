library gglclient;

import 'package:stagexl/stagexl.dart';
import 'dart:html' as html;
import 'dart:math' as math;
import 'package:stagexl_particle/stagexl_particle.dart';

part './client/client.dart';
part './client/player.dart';
part './client/input_handler.dart';
part './client/resource_handler.dart';
part './client/tilesheet.dart';

/**
 * global variables
 */
final html.CanvasElement canvas = html.querySelector('#gglstage');
final Stage stage = new Stage(canvas);
final ResourceManager resMgr = new ResourceManager();
final RenderLoop renderLoop = new RenderLoop();