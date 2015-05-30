part of gglclient2;


class InputHandler {
  Map<num, bool> key = new Map<num, bool>();
  List<Function> _cbList = [];

  bool mouseL;
  bool mouseR;
  num mouseX = -1;
  num mouseY = -1;
  Cmd cmd = new Cmd();

  InputHandler() {}

  void addListener(void action(Cmd)) {
    _cbList.add(action);
  }

  void removeAllListeners() {
    _cbList.clear();
  }

  void init() {
    for (num i = 0; i < 255; i++) key[i] = false;
    stage.focus = stage;
    stage.onKeyDown.listen(_processKeyboard);
    stage.onKeyUp.listen(_processKeyboard);
    stage.onMouseDown.listen((e) { mouseL = true; });
    stage.onMouseUp.listen((e) { mouseL = false; });
    stage.onMouseRightDown.listen((e) { mouseR = true; });
    stage.onMouseMove.listen((e) {
      mouseX = e.stageX - stage.stageWidth/2;
      mouseY = e.stageY - stage.stageHeight/2;
    });
    stage.onExitFrame.listen(_updater);
    new async.Timer.periodic(new Duration(milliseconds: 16), makeCmd);
  }

  void _processKeyboard(KeyboardEvent e) {
    key[e.keyCode] = e.type == KeyboardEvent.KEY_DOWN ? true : false;
    key[40] = e.keyCode == 40 && e.type == KeyboardEvent.KEY_UP ? true : false;
    e.stopImmediatePropagation();
  }

  void _updater(ExitFrameEvent event) {
  }

  num triValue(num neg, num pos) {
    if (key[pos] && key[neg]) return 0;
    else if (key[pos]) return 1;
    else if (key[neg]) return -1;
    return 0;
  }

  void makeCmd(async.Timer timer) {
    cmd.moveY = triValue(87, 83);  // down, up
    cmd.moveX = triValue(65, 68);  // left, right
    cmd.moveR = triValue(37, 39);  // turn left, right
    cmd.fire = key[38] || mouseL? 1 : 0; // fire
    cmd.swap = key[40] || mouseR? 1 : 0; // swap weapon
    cmd.mouseX = mouseX;
    cmd.mouseY = mouseY;
    debugWindow.inputField.text = cmd.toString();
    for (Function f in _cbList) f(cmd);
    mouseX = mouseY = -1;         // reset the mouse XY
    key[40] = false;              // reset the swap key
    mouseR = false;               // reset the mouse R
  }
}