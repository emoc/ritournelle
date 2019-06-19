
class PatternButton extends Button {
  int id;
  int posX, posY;
  boolean memorize = false;
  int count = 0;
  String [] load_mem;
  int index = 0;//pour naviguer dans le fichier de memoire txt

  PatternButton(int _id) {
    id = _id+1;
    posX = 16*width/19 + w/2;
    posY = (4*height/16 - w/2);

    // petit algorithme pour calculer les coordonnées des 9 patternButtons (de la façon la plus élégante possible :) )
    x = posX + id*w;
    y = posY;

    if (id > 3 && id < 7) { 
      x = posX-(3*w) + id*w;
      y = posY + w;
    }
    if (id>6) {
      x = posX-(6*w) + id*w;
      y = posY + (2*w);
    }


    name = str(id);
    c = color(255, 255, 255);
  }

  void display() {
    fill(c);
    rect(x, y, w, h);
    fill(0);
    text(name, x, y);
  }
  void update() {

    if (overRect(x, y, w, h)) {
      c = color(200, 200, 200);

      if (mousePressed) {
        c = color(0, 0, 0);
        numeroPatternEnCours = this.id;
        
        recall();
        memorize();
      }

      else {
        count = 0;
        index = 0;
        memButton.pushMem = false;
      }
    }

    else {
      c = color(255, 255, 255);
    }
  }


  void recall() {
    // on rappelle un pattern uniquement si la mémorisation n'est pas activée !!!
    if (memButton._mem == false) {
      // on charge la mémoire du pattern à partir du fichier txt
      load_mem = loadStrings("patterns/pattern_"+ this.id + ".txt");
      // on récupère les valeur de chaque toggle
      if (index < load_mem.length) {
        String [] positions = split(load_mem[index], '\t');
        String [] new_positions = shorten(positions);
        for (int i = 0; i<new_positions.length; i++) {
          String load_toggle = trim(positions[i]);
          pas[index][i].toggle = false;
          pas[index][i].toggle = boolean(load_toggle); // on assigne les toggle du fichier txt aux toggles des pas
          // println(load_toggle+"   "+pas[index][i].toggle);
          //println(load_mem.length+"   "+new_positions.length);
        }
      }
      index++;
    }
  }

  void memorize() {
    // on peut mémoriser le pattern si le bouton mem est activé (le count permet d'activer pushmem un court instant)
    if (memButton._mem == true && count == 0) {
      memButton.pushMem = true;
      count++;
    }
  }
}