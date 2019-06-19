/*
 * Séquenceur pour Ritournelle v0.9 / Nantes, atelier partagé de PiNG, 18 juin 2019
 *   Envoi de messages sur le port série pour déclencher des sons 
 *     + réception des messages de debug envoyé par le circuit de Ritournelle
 
Correspondances entre les caractères, les notes MIDI, les broches activées sur arduino, les broches des 4066
 
piste -> caractère envoyé -> note MIDI -> broche arduino -> broches d'entrée -> broches de sortie associées
 1 -> A -> 60 -> 4  -> 1:13 -> 1 & 2 du 1er 4066
 2 -> Z -> 61 -> 5  -> 1:12 -> 3 & 4 du 1er 4066
 3 -> E -> 62 -> 6  -> 1:6  -> 8 & 9 du 1er 4066
 4 -> R -> 63 -> 7  -> 1:5  -> 10 & 11 du 1er 4066
 5 -> T -> 64 -> 8  -> 2:13 -> 1 & 2 du 2nd 4066
 6 -> Y -> 65 -> 9  -> 2:12 -> 3 & 3 du 2nd 4066
 7 -> I -> 66 -> 10 -> 2:6  -> 8 & 9 du 2nd 4066
 8 -> U -> 67 -> 11 -> 2:5  -> 10 & 11 du 2nd 4066
 9 -> 0 -> 68 -> 12 -> 3:13 -> 1 & 2 du 3e 4066
 10-> P -> 69 -> 13 -> 3:12 -> 3 & 4 du 3e 4066
 11-> Q -> 70 -> A0 -> 3:6  -> 8 & 9 du 3e 4066
 12-> S -> 71 -> A1 -> 3:5  -> 10 & 11 du 3e 4066
 13-> D -> 72 -> A2 -> 4:13 -> 1 & 2 du 4e 4066
 14-> F -> 73 -> A3 -> 4:12 -> 3 & 4 du 4e 4066
 15-> G -> 74 -> A4 -> 4:6  -> 8 & 9 du 4e 4066
 16-> H -> 75 -> A5 -> 4:5  -> 10 & 11 du 4e 4066  
 
*/

boolean DEBUG = true;

import processing.serial.*;

int nb = 32;
int nbPistes = 16;
int nbPattern = 9;
int x = 20; // distance entre chaque pas
int numeroPatternEnCours = 0;
int tempo = 80;
// un pas représente juste un temps sur une piste, c'est pour cela qu'il y a en a 16 par pistes
// il y a 12 pistes donc 12 * 16 pas
Pas pas [][] = new Pas[nbPistes][nb];
char tone [] = {
  'A', 'Z', 'E', 'R', 'T', 'Y', 'I', 'U', 'O', 'P', 'Q', 'S', 'D', 'F', 'G', 'H'
};
int numPiste[] = {
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
};

Lecture lecture;
Fader faderBPM;
Serial arduino;  
MemButton memButton;
CleanButton cleanButton;
PatternButton patternButton [] = new PatternButton[nbPattern];

void setup() {
  size(850, 400);

  if (DEBUG) println("Ports série disponibles : ");
  if (DEBUG) printArray(Serial.list());
  rectMode(CENTER);
  textAlign(CENTER);
  stroke(0);
  arduino = new Serial(this, Serial.list()[5], 57600);
  arduino.bufferUntil('\n'); 

  for (int i=0; i<nb; i++) {
    for (int j=0; j<nbPistes; j++) {
      pas[j][i] = new Pas(30 + x*i, 40 + x*j, tone[j]);
    }
  }
  lecture = new Lecture(30);
  faderBPM = new Fader();
  memButton = new MemButton();
  cleanButton = new CleanButton();

  for (int i=0; i<nbPattern; i++) {
    patternButton[i] = new PatternButton(i);
  }
}

void draw() {
  background(200);
  for (int i=0; i<nb; i++) {
    for (int j=0; j<nbPistes; j++) {
      pas[j][i].display(); 
      pas[j][i].update();
      fill(0);
      text(numPiste[j], 10, pas[j][0].y + pas[0][0].w/3);
    }
  }
  faderBPM.display();
  faderBPM.update();

  memButton.display();
  memButton.update();

  cleanButton.display();
  cleanButton.update();

  for (int i=0; i<nbPattern; i++) {
    patternButton[i].display();
    patternButton[i].update();
  }

  text("PATTERN", patternButton[0].posX + patternButton[0].w*2, patternButton[0].posY - patternButton[0].w*3/2);
  text(numeroPatternEnCours, patternButton[0].posX + patternButton[0].w*2, patternButton[0].posY - patternButton[0].w);

  play();
}

void play() {
  lecture.display();
  lecture.update();
}

void serialEvent (Serial port) {
  if (port == arduino) {
    String inBuffer = port.readStringUntil('\n');
    if (inBuffer != null) {
      if (DEBUG) print(inBuffer);
    }
  }
}
