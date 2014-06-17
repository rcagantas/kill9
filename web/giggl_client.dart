library giggl;

import 'package:stagexl/stagexl.dart';
import 'dart:html' as html;

part 'client.dart';
part 'player.dart';

/**
 * global variables
 */
final html.CanvasElement canvas = html.querySelector('#gglstage');
final Stage stage = new Stage(canvas);
final ResourceManager resMgr = new ResourceManager();

