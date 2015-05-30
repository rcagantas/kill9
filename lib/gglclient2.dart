library gglclient2;

import 'package:stagexl/stagexl.dart';
import 'package:stagexl_particle/stagexl_particle.dart';
import 'dart:async' as async;
import 'dart:js' as js;
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:giggl/gglcommon.dart';

part 'client2/input_handler.dart';
part 'client2/font_loader.dart';
part 'client2/debug_window.dart';
part 'client2/resource_loader.dart';
part 'client2/player_sprite.dart';
part 'client2/particle_loader.dart';
part 'client2/bullet_sprite.dart';
part 'client2/drop_sprite.dart';
part 'client2/arena.dart';
part 'client2/hud_layer.dart';

final Stage stage = new Stage(html.querySelector("#maincanvas"));
final ResourceManager resource = new ResourceManager();
final ResourceLoader resourceLoader = new ResourceLoader();
final FontLoader fonts = new FontLoader();
final DebugWindow debugWindow = new DebugWindow();
final InputHandler input = new InputHandler();

