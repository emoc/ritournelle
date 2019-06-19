/* les pas de chaque pistes */

class Pas {
  int x;
  int y;
  int h = 15;
  int w = 15;
  boolean toggle = false;
  int  count = 0;
  int countNote = 0;
  int couleur = 255;
  char note;

  Pas(int _x, int _y, char _note) {
    x = _x;
    y = _y;
    note = _note;
  }

  void display() {
    fill(couleur);
    stroke(0);
    strokeWeight(1);
    rect(x, y, w, h);
  }

  void update() {
    if (mousePressed) {
      if (overRect(x, y, w, h) && count == 0) {
        toggle = !toggle;
        count++;
      }
    }
    else {
      count=0;
    }
    if (toggle) {
      strokeWeight(2);
      line(x-w/2, y-h/2, x+w/2, y+h/2);
      line(x+w/2, y-h/2, x-w/2, y+h/2);

      if (couleur == 0) {
        if ( countNote == 0) {
          arduino.write(note);
          if (DEBUG) println("note envoyée depuis processing (caractère) : " + note);
          countNote++;
        }
      }
      else {
        countNote=0;
      }
    }
  }

  boolean overRect(int _x, int _y, int _w, int _h) 
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
