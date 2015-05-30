part of gglclient;

class Diagnostics extends DisplayObjectContainer {
  num fps = null;
  TextFormat font11 = new TextFormat('Lato', 11, Color.Black);
  TextField dbg;

  Diagnostics() {
    stage.onEnterFrame.listen(onFrame);
    dbg = new TextField()
          ..defaultTextFormat = font11
          ..x = 30
          ..y = 30
          ..width = 200
          ..height = 200
          ..wordWrap = true
          ..text = "FPS";
  }

  bool get isLogging { return stage.contains(this); }

  void onFrame(EnterFrameEvent e) {
    this.addChild(dbg);
    fps = fps == null? 1.00 / e.passedTime : 0.05 / e.passedTime + 0.95 * fps;
    dbg.text = "FPS: ${fps.roundToDouble()}";
  }
}