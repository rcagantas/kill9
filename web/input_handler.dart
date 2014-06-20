part of giggl;

class InputHandler {
  Map<int, bool> keyState = new Map<int, bool>();

  InputHandler() {
    stage.focus = stage;
    stage.onKeyDown.listen((e) => keyState[e.keyCode] = true);
    stage.onKeyUp.listen((e) => keyState[e.keyCode] = false);

    for(int i = 0; i < 255; i++) {
      keyState[i] = false;
    }

    stage.onEnterFrame.listen((EnterFrameEvent e) {
      var fps = null;
      fps = fps == null
          ? 1.00 / e.passedTime
          : 0.05 / e.passedTime + 0.95 * fps;
      html.querySelector('#fps').innerHtml = 'fps: ${fps.round()}';
    });
  }
}

