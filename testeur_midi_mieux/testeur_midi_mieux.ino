/*
 * Résidence Ritournelle, Nantes / Ping, atelier partagé du Breil, 18 juin 2019
 * Circuit pour tester l'envoi de commandes midi au prototype de Ritournelle
 * Les commandes MIDI sont envoyées directement sans passer par la lib. MIDI
 * 
 * arduino 1.8.5 @ Kirin, debian 9 stretch
 *  + lib SoftwareSerial 1.0 http://www.arduino.cc/en/Reference/SoftwareSerial
 *  
 */

#define BROCHE_LED   7             // led indiquant l'envoi d'un message

#include <SoftwareSerial.h>
SoftwareSerial midiSerial(2, 3);   // RX, TX

byte note = 0;                     // note actuellement jouée
int duree_note = 300;              // durée de chaque note
int duree_led = 100;               // durée de la led

// Notes jouées
byte notes[16] = {60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75};

void setup() {
  pinMode(BROCHE_LED, OUTPUT);
  midiSerial.begin(31250);
}

void loop() {

  // Choisir une note avec un tirage au sort et une répartition statistique
  byte hasard = random(100);
  if (hasard < 20)                      note = notes[0];
  else if (hasard >= 20 && hasard < 40) note = notes[1];
  else if (hasard >= 40 && hasard < 60) note = notes[2];
  else if (hasard >= 60 && hasard < 80) note = notes[3];
  else                                  note = notes[4];

  // Déclencher les messages MIDI
  midiMessage(0x90, note, 0x45);  // Note On 0x9n, n : canal entre 0 et F
  digitalWrite(BROCHE_LED, HIGH);
  delay(duree_led);               // durée de la led
  digitalWrite(BROCHE_LED, LOW);
  delay(duree_note - duree_led);    
  midiMessage(0x80, note, 0x00);  // Note Off 0x8n, n : canal entre 0 et F
  delay(duree_note * 3);          // durée du silence entre 2 notes
}

// Envoi des messages MIDI sur le port série
void midiMessage(byte cmd, byte data1, byte data2) {
  midiSerial.write(cmd);
  midiSerial.write(data1);
  midiSerial.write(data2);
}


