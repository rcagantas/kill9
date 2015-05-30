part of gglclient2;

class FontLoader {
  async.Future load;

  FontLoader() {
    var completer = new async.Completer();
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

  start() {
    print("fonts loaded");
  }
}