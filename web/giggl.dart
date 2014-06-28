library giggl;

import 'package:stagexl/stagexl.dart';
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:async';


part 'client/client.dart';
part 'client/player.dart';
part 'client/input_handler.dart';
part 'client/resource_handler.dart';

part 'server/constants.dart';
part 'server/grid.dart';
part 'server/world.dart';
part 'server/object.dart';
part 'server/utility.dart';
part 'server/weapon.dart';

/**
 * global variables
 */
final html.CanvasElement canvas = html.querySelector('#gglstage');
final Stage stage = new Stage(canvas);
final ResourceManager resMgr = new ResourceManager();
final RenderLoop renderLoop = new RenderLoop();