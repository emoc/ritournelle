/*
 * Résidence Ritournelle, Nantes / Ping, atelier partagé du Breil, 18 juin 2019
 * Circuit pour tester l'envoi de commandes midi au prototype de Ritournelle
 * Les commandes MIDI sont envoyées directement sans passer par la lib. MIDI
 * 
 * arduino 1.8.5 @ Kirin, debian 9 stretch
 *  + lib SoftwareSerial 1.0 http://www.arduino.cc/en/Reference/SoftwareSerial
 *  
 */

#define BROCHE_LED   7           // led indiquant l'envoi d'un message

#include <SoftwareSerial.h>
byte note = 0;
SoftwareSerial midiSerial(2, 3); // RX, TX

void setup() {
  pinMode(BROCHE_LED, OUTPUT);
  midiSerial.begin(31250);
}

void loop() {
  //note = random(60, 75);        // les 16 notes correspondant aux 16 sorties de Ritournelle
  note = 60;                      // premier test avec juste une note
  int dd = random(150, 300);      // durée de chaque note
  midiMessage(0x90, note, 0x45);  // Note On 0x9n, n : canal entre 0 et F
  digitalWrite(BROCHE_LED, HIGH);
  delay(dd);                      // durée de la note
  
  midiMessage(0x80, note, 0x00);  // Note Off 0x8n, n : canal entre 0 et F
  digitalWrite(BROCHE_LED, LOW);
  delay(dd * 3);                  // durée du silence entre 2 notes
}

// Envoi des messages MIDI sur le port série
void midiMessage(byte cmd, byte data1, byte data2) {
  midiSerial.write(cmd);
  midiSerial.write(data1);
  midiSerial.write(data2);
}


