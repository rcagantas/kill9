part of gglclient;

class DropSprite extends DisplayObjectContainer {
  Shape proxyShape;
  DropSprite() {
    proxyShape = new Shape()
      ..graphics.strokeColor(Color.Red)
      ..graphics.rect(0, 0, 50, 50)
      ..addTo(this);
  }
}