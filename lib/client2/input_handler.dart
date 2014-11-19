part of gglclient2;

class InputHandler {
  Map<num, bool> key = new Map<num, bool>();
  List<Function> _cbList = [];
  TextField dbg;

  bool mouseL = false;
  num mainId = 0;
  Cmd cmd = new Cmd();

  void addListener(void action(Cmd)) {
    _cbList.add(action);
  }

  InputHandler() {
    for (num i = 0; i < 255; i++) key[i] = false;

    dbg = new TextField()
        ..defaultTextFormat = diagnostics.font11
        ..x = 300
        ..y = 30
        ..width = 200
        ..height = 200
        ..wordWrap = true;

    stage.focus = stage;
    stage.onKeyDown.listen(_process);
    stage.onKeyUp.listen(_process);
    stage.onMouseDown.listen((e) { mouseL = true; makeCmd(); });
    stage.onMouseUp.listen((e) { mouseL = false; makeCmd(); });
    stage.onMouseRightClick.listen((e) { cmd.swap = true; });
    stage.onMouseMove.listen((e) {
      cmd.mouseX = e.stageX - stage.stageWidth/2;
      cmd.mouseY = e.stageY - stage.stageHeight/2;
      makeCmd();
    });
    stage.onExitFrame.listen(_updater);
    print("loading input handler");
  }

  void _process(KeyboardEvent e) {
    key[e.keyCode] = e.type == KeyboardEvent.KEY_DOWN ? true : false;
    makeCmd();
  }

  num trival(num neg, num pos) {
    if (key[pos] && key[neg]) return 0;
    else if (key[pos]) return 1;
    else if (key[neg]) return -1;
    return 0;
  }

  void makeCmd() {
    cmd.id = mainId;
    cmd.moveY = trival(87, 83);   // down, up
    cmd.moveX = trival(65, 68);   // left, right
    cmd.rotate = trival(37, 39);  // turn left, right
    cmd.fire = key[38] || mouseL; // fire
    cmd.swap = key[40];           // swap weapon
    dbg.text = "${cmd}\n" + "pressed:${pressed()}";
  }

  String pressed() {
    String s = "";
    for (num k in key.keys) {
      if (key[k]) s += "$k ";
    }
    return s;
  }

  void removeListeners() { _cbList.clear(); }

  bool alternate = false;

  void _updater(ExitFrameEvent e) {
    alternate = !alternate;
    if (alternate) return;
    diagnostics.addChild(dbg);
    for (Function f in _cbList) {
      f(cmd);
    }
    cmd.swap = false;
    cmd.mouseX = -1;
    cmd.mouseY = -1;
  }
}
