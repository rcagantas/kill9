library giggl;

import 'package:stagexl/stagexl.dart';
import 'dart:html' as html;
import 'dart:math' as math;

part 'client.dart';
part 'actor.dart';
part 'input_handler.dart';
part 'resource_handler.dart';

/**
 * global variables
 */
final html.CanvasElement canvas = html.querySelector('#gglstage');
final Stage stage = new Stage(canvas);
final ResourceManager resMgr = new ResourceManager();
final RenderLoop renderLoop = new RenderLoop();