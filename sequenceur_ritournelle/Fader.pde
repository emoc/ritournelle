class Fader {
  float xB, yB;
  float x, y;
  int w = 15;
  int h = 240;
  int BPM;

  Fader() {
    x = 5*width/6;
    y = 4*height/8;
    xB = x;
    yB = y;
  }

  void display() {
    stroke(0);
    fill(255);

    rect(x, y, w, h);
    fill(0);
    rect(xB, yB, w, w);
    text("BPM", x, y-h/2-w/1.5);
    text(lecture.BPM, x, y-h/2-w/8);
  }

  void update() {
    if (overRect(xB, yB, w, w)) {
      if (mousePressed) {
        yB = constrain(mouseY, (y-h/2+w/2), (y+h/2-w/2));
        lecture.BPM = int(map(yB, (y+h/2-w/2), (y-h/2+w/2), 30, 200));
        //lecture.tempo = map(yB, (y+h/2-w/2), (y-h/2+w/2), 0.000001, 0.00009);
      }
    }
    if (overRect(x, y, w, h)) {
      if (mousePressed) {
        yB = constrain(mouseY, (y-h/2+w/2), (y+h/2-w/2));
      }
    }
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