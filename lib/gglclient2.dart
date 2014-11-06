library gglclient2;

import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:math' as math;
import 'package:stagexl/stagexl.dart';
import 'dart:async';

part 'client2/diagnostics.dart';
part 'client2/font_loader.dart';
part 'client2/input_handler.dart';
part 'client2/resource_loader.dart';
part 'client2/player_sprite.dart';

final FontLoader fontLoader = new FontLoader();
final Stage stage = new Stage(html.querySelector("#maincanvas"));
final ResourceManager resource = new ResourceManager();
final ResourceLoader resLoader = new ResourceLoader();
final Diagnostics diagnostics = new Diagnostics();
final InputHandler input = new InputHandler();
