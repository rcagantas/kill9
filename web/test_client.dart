import 'giggl.dart';
import 'package:stagexl/stagexl.dart';

InputHandler kb;
Client client;

void main() {
  kb = new InputHandler();
  client = new Client();
  stage.onKeyUp.listen(onKeyUp);
  stage.onEnterFrame.listen(onFrame);
}


void onFrame(Event e) {
  Actor p1 = client.p1;
  if (p1 == null) return;
  num ix = 0, iy = 0, ih = 0, it = 0, inc = 2, rinc = 0.1;
  if (kb.keyState[87]) { iy = inc; }
  if (kb.keyState[83]) { iy = -inc; }
  if (kb.keyState[65]) { ix = inc; }
  if (kb.keyState[68]) { ix = -inc; }
  if (kb.keyState[37]) { it = -rinc; }
  if (kb.keyState[39]) { it = rinc; }
  p1.move(p1.x - ix, p1.y - iy);
  p1.torsoRotate(it);
}

void onKeyUp(KeyboardEvent event) {
  Actor p1 = client.p1;
  if (p1 == null) return;
  if (event.keyCode == 40) { p1.cycleWeapon(); }
  if (event.keyCode == 39 || event.keyCode == 40)
    event.stopImmediatePropagation();
}
