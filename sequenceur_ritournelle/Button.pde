class Button {
  int x, y, w, h;
  String name;
  color c;


  Button() {
    w = h = 25;
  }

  boolean overRect(float _x, float _y, int _w, int _h) 
  {
    if (mouseX >= _x - _w/2 && mouseX <= _x + w/2 && 
      mouseY >= _y - _h/2 && mouseY <= _y + _h/2) {
      return true;
    } 
    else {
      return false;
    }
  }
}