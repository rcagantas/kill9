part of gglclient;

class BulletSprite extends Shape {
  BulletSprite() {
    this.pivotX = this.pivotY = 0;
    this.graphics.ellipse(0, 0, 3, 6);
    this.graphics.fillColor(Color.White);
  }
}