/* Bouton pour effacer le pattern en cours */

class CleanButton extends Button {
  int count = 0;

  CleanButton() {
    x = 22*width/24;
    y = 14*height/16 - w/2;
    name = "×";
    c = color(255, 255, 255);
  }

  void display() {
    stroke(0);
    fill(c);
    rect(x, y, w, h);
    fill(0);
    text(name, x, y+h/8);
  }

  void update() {
    if (mousePressed) {
      if (overRect(x, y, w, h) && count == 0) {    
        c = color(255, 0, 0);
        // on efface le pattern en cours (toggle = false)
        for (int i = 0; i<nbPistes; i++) {
          for (int j = 0; j<nb; j++) {
            pas[i][j].toggle = false;
          }
        }
        count ++;
      }
    }
    else {
      c = color(255, 255, 255);
      count = 0;
    }
  }
}
