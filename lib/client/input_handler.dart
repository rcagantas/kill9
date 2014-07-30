part of gglclient;

class InputHandler {
  Map<num, bool> keyState = new Map<num, bool>();
  num mouseX = 0, mouseY = 0;
  bool mouseL = false, mouseR = false;
  TextField dbg;
  Function cbStateChange = null;
  CommandFrame _cmdFrame = new CommandFrame();

  InputHandler() {
    stage.focus = stage;
    stage.onKeyDown.listen(_keyHandler);
    stage.onKeyUp.listen(_keyHandler);
    stage.onMouseMove.listen((e) {mouseX = e.stageX; mouseY = e.stageY; _sc(); });
    stage.onMouseDown.listen((e) { mouseL = true; _sc(); });
    stage.onMouseUp.listen((e) { mouseL = false; _sc(); });

    for(num i = 0; i < 255; i++) keyState[i] = false;

    var fps = null;
    stage.onEnterFrame.listen((EnterFrameEvent e) {
      String keyPressed = "keypressed: ";
      for (num i = 0; i < 255; i++)
        if (keyState[i]) keyPressed += "$i ";

      fps = fps == null
          ? 1.00 / e.passedTime
          : 0.05 / e.passedTime + 0.95 * fps;

      dbg.text = "fps: ${fps.round()}\n" +
          keyPressed;
    });

    TextFormat tf = new TextFormat('Open Sans', 14, Color.Black);
    dbg = new TextField()
      ..defaultTextFormat = tf
      ..x = 30
      ..y = 30
      ..width = 200
      ..height = 200
      ..wordWrap = true
      ..addTo(stage);
  }

  void _keyHandler(KeyboardEvent e) {
    keyState[e.keyCode] = e.type == KeyboardEvent.KEY_DOWN? true: false;
    _sc();
  }

  void _sc() {
    if (keyState[87]) _cmdFrame.moveY = -1;
    else if (keyState[83]) _cmdFrame.moveY = 1;
    else _cmdFrame.moveY = 0;

    if (keyState[65]) _cmdFrame.moveX = -1;
    else if (keyState[68]) _cmdFrame.moveX = 1;
    else _cmdFrame.moveX = 0;

    if (keyState[37]) _cmdFrame.orientation = -1;
    else if (keyState[39]) _cmdFrame.orientation = 1;
    else _cmdFrame.orientation = 0;

    if (keyState[38] || mouseL) _cmdFrame.fire = true;
    if (keyState[38] && mouseL) _cmdFrame.fire = false;

    if (cbStateChange != null) cbStateChange(_cmdFrame);
  }
}

