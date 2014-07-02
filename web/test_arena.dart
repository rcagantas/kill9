import 'package:stagexl/stagexl.dart';
import 'package:giggl/gglclient.dart';


Arena client;
InputHandler io;
PlayerSprite p1;

void main() {
  ResourceHandler.init();
  resMgr.load().then((_) {
    renderLoop.addStage(stage);
    client = new Arena();
    client.createRandomMap(10, 10);
    p1 = client.p1;

    stage.onKeyUp.listen(onKeyUp);
    stage.onEnterFrame.listen(onFrame);
    stage.onMouseMove.listen(onMouseMove);
    stage.onMouseRightClick.listen((e) => p1 != null? p1.cycleWeapon() : 0);
    io = new InputHandler();
  });
}

void onFrame(Event e) {
  if (p1 == null) return;
  handleInput();
}

void handleInput() {
  num ix = 0, iy = 0, ih = 0, it = 0, inc = 4, rinc = 0.1;
  if (io.keyState[87]) { iy = -inc; }
  if (io.keyState[83]) { iy = inc; }
  if (io.keyState[65]) { ix = -inc; }
  if (io.keyState[68]) { ix = inc; }
  if (io.keyState[37]) { it = -rinc; }
  if (io.keyState[39]) { it = rinc; }
  if (io.keyState[38] || io.mouseL) { p1.fire(); }
  if (io.keyState[69]) { p1.takeDamage(1); }
  client.move(client.x - ix, client.y - iy);
  p1.move(p1.x + ix, p1.y + iy);
  p1.turnAdd(it);
}

void onKeyUp(KeyboardEvent e) {
  if (p1 == null) return;
  if (e.keyCode == 40) { p1.cycleWeapon(); }
  if (e.keyCode == 38 || e.keyCode == 40) {
    p1.resetTorso();
  }
}

void onMouseMove(MouseEvent e) {
  if (p1 == null) return;
  p1.turnToPoint(e.stageX, e.stageY);
}
