part of gglclient2;

class DebugWindow extends DisplayObjectContainer {
  TextFormat font = new TextFormat('Lato', 11, Color.Azure, strokeColor:Color.Black, strokeWidth:2);
  TextField inputField;
  num fps = null;
  String serverMessage = "";

  DebugWindow() {
    inputField = new TextField()
      ..defaultTextFormat = font
      ..x = 10
      ..y = 10
      ..width = 500
      ..height = 300
      ..wordWrap = true
      ..addTo(this);

    stage.onEnterFrame.listen(onFrame);
  }

  void onFrame(EnterFrameEvent e) {
    fps = fps == null? 1.00 / e.passedTime : 0.05 / e.passedTime + 0.95 * fps;
    String fpsText = "FPS: ${fps.roundToDouble()}";
    String eol = "\n";
    inputField.text =
        input.cmd.toString() + eol +
        fpsText + eol + serverMessage;
  }
}
