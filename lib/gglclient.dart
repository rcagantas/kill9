library gglclient;

import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:math' as math;
import 'package:stagexl/stagexl.dart';
import 'dart:async';
import 'package:stagexl_particle/stagexl_particle.dart';
import 'package:giggl/gglcommon.dart';

part 'client/diagnostics.dart';
part 'client/font_loader.dart';
part 'client/input_handler.dart';
part 'client/resource_loader.dart';
part 'client/player_sprite.dart';
part 'client/particle_loader.dart';
part 'client/arena.dart';
part 'client/bullet_sprite.dart';
part 'client/weapon_drop_sprite.dart';

final FontLoader fontLoader = new FontLoader();
final Stage stage = new Stage(html.querySelector("#maincanvas"));
final ResourceManager resource = new ResourceManager();
final ResourceLoader resLoader = new ResourceLoader();
final Diagnostics diagnostics = new Diagnostics();
final InputHandler input = new InputHandler();
