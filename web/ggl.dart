import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'gglclient.dart';

void main() {
  var canvas = html.querySelector('#gglstage');
  var stage = new Stage(canvas);
  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  var client = new GglClient(stage);
}
