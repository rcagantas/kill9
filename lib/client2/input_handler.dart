part of gglclient2;

class Cmd {
  num moveX = 0, moveY = 0, rotate = 0;
  bool fire = false, swap = false;

  String toString() {
    return "moveX: $moveX; moveY: $moveY; rotate: $rotate\n" +
        "fire: $fire; swap: $swap";
  }

  bool equals(Cmd c) {
    return this.toString() == c.toString();
  }
}

class InputHandler {
  Map<num, bool> key = new Map<num, bool>();
  List<Function> cbList = [];
  TextField dbg;

  Cmd cmd = new Cmd();

  InputHandler() {
    for (num i = 0; i < 255; i++) key[i] = false;

    stage.onEnterFrame.listen(_updater);
    dbg = new TextField()
        ..defaultTextFormat = diagnostics.font11
        ..x = 300
        ..y = 30
        ..width = 200
        ..height = 200
        ..wordWrap = true;
    diagnostics.addChild(dbg);

    stage.focus = stage;
    stage.onEnterFrame.listen(_reset);
    stage.onKeyDown.listen(_process);
    stage.onKeyUp.listen(_process);
    print("loading input handler");
  }

  void _process(KeyboardEvent e) {
    key[e.keyCode] = e.type == KeyboardEvent.KEY_DOWN ? true : false;
    makeCmd();
  }

  void _reset(EnterFrameEvent event) {
    cmd.swap = false;
  }

  num trival(num neg, num pos) {
    if (key[pos] && key[neg]) return 0;
    else if (key[pos]) return 1;
    else if (key[neg]) return -1;
    return 0;
  }

  void makeCmd() {
    cmd.moveY = trival(87, 83);   // down, up
    cmd.moveX = trival(65, 68);   // left, right
    cmd.rotate = trival(37, 39);  // turn left, right
    cmd.fire = key[38];           // fire
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

  void _updater(EnterFrameEvent e) {
    for (Function f in cbList) {
      f(cmd);
    }
  }
}
