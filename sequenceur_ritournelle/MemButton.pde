class MemButton extends Button {
  boolean _mem = false;
  boolean pushMem = false;
  int count = 0;
  int countSave = 0;

  MemButton () {
    x = 22*width/24;
    y = 9*height/16 - w/2;
    name = "MEM";
    c = color(255, 255, 255);
  }

  void display() {
    stroke(0);
    fill(c);
    rect(x, y, w, h);
    fill(0);
    text(name, x, y);
  }

  void update() {
    // le bouton mémoire fonctionne en toggle (comme pour les Pas)
    if (mousePressed) {
      if (overRect(x, y, w, h) && count == 0) {
        _mem = !_mem;
        count++;
      }
    }
    else {
      count=0;
    }

    // sauvegarde du pattern dans un fichier txt

    // le bouton mem est armé
    if (_mem == true) {
      c = color(255, 0, 0);

      if (pushMem == true && countSave == 0) {
        String[][] lines = new String[nbPistes][nb]; // nombre de pas par le nombre de pistes
        String[] memory = new String[nbPistes];
        for (int i=0; i<nbPistes; i++) {
          for (int j=0; j<nb; j++) {
            lines[i][j] = pas[i][j].toggle + "\t";
            memory[i] = join(lines[i], " ");
          }
        }
        saveStrings("patterns/pattern_" + numeroPatternEnCours + ".txt", memory);
        countSave++;
        _mem = false;
        println("save");
      }
    }
    else {
      c = color(255, 255, 255);
      countSave = 0;
      //pushMem = false;
    }
    //println("pushMem = "+pushMem+"  countSave = " + countSave);
  }
}