part of giggl;

class GglStage {
  static Stage _stage;
  static Stage getInstance() {
    if (_stage == null) {
      var canvas = html.querySelector('#gglstage');
      _stage = new Stage(canvas);
    }
    return _stage;
  }
}
