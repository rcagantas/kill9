part of gglclient;

class FontLoader {
  bool isReady = false;
  Future load;

  FontLoader() {
    var completer = new Completer();
    var googleFontFamilies = ['Open Sans','Montserrat','Lato','Lobster'];

    js.JsObject webFont = js.context["WebFont"];
    js.JsObject webFontConfig = new js.JsObject.jsify({
      "google": { "families": googleFontFamilies },
      "loading": () => print("loading fonts"),
      "active": () => completer.complete(null),
      "inactive": () => completer.completeError("Error loading fonts"),
    });

    if (webFont != null) {
      webFont.callMethod("load", [webFontConfig]);
      completer.future.then((_) => start());
      load = completer.future;
    }
  }

  start() { isReady = true; }
}