class Lecture {
  float x;
  int y;
  int w = 11, h = 11;
  float tempo;
  int BPM = 100;

  Lecture(int _x) {
    x = _x;
    y = 60 - (pas[0][0].h * 2);
  }

  void display() {
    noStroke();
    fill(0);
    float delaiEntre2Temps = 60000 / BPM;// délai entre 2 temps de la mesure en millis
    float d = (pas[0][3].x - pas[0][0].x); // distance entre 2 temps de la mesure : ici 4 "pas" soit 25 pixels * 4 = 100.
    float vitesse =   (d / delaiEntre2Temps) * 1000 ; // vitesse en pixels par secondes.
    float V = vitesse / frameRate;// adapté à la vitesse du sketch

    if (x < pas[0][nb-1].x + pas[0][nb-1].w/2 + 2.5) // 2.5 correspond aux espaces entre chaque pas (20 - 15 = 5 --> 5/2 = 2.5)
      x += V;
    else
      x = pas[0][0].x - pas[0][0].w/2 - 2.5;         // on rembobine en faisant attention de partir depuis le début de la séquence et d'arriver bien à la fin !!!


    ellipse(pas[0][0].x, pas[0][0].y - pas[0][0].h, 8, 8); 
    ellipse(pas[0][4].x, pas[0][4].y - pas[0][0].h, 8, 8); 
    ellipse(pas[0][8].x, pas[0][8].y - pas[0][0].h, 8, 8); 
    ellipse(pas[0][12].x, pas[0][12].y - pas[0][0].h, 8, 8);
    ellipse(pas[0][16].x, pas[0][16].y - pas[0][0].h, 8, 8);
    ellipse(pas[0][20].x, pas[0][20].y - pas[0][0].h, 8, 8);
    ellipse(pas[0][24].x, pas[0][24].y - pas[0][0].h, 8, 8);
    ellipse(pas[0][28].x, pas[0][28].y - pas[0][0].h, 8, 8);
    //ellipse(x, 15, 12, 5);
  }


  void update() {
    for (int i=0; i<nb; i++) {
      float d = dist(this.x, this.y, pas[0][i].x, pas[0][i].y);
      for (int j=0; j<nbPistes; j++) {
        // ici on évalu la distance entre l'ellipse qui joue le role de tête de lecture et la première ligne de pas
        if (d < 11) {          
          pas[j][i].couleur = 0;
        }
        else {
          pas[j][i].couleur = 255;
        }
      }
    }
  }
}