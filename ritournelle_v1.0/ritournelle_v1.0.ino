/*
 *  Ritournelle v0.9 / Nantes, atelier partagé de PiNG, 17 juin 2019
 *  version 0.8 : réception des messages pour déclencher les notes par le port MIDI
 *  version 0.9 : + réception des messages pour déclencher les notes par le port USB
 *  arduino 1.8.5 / 
 *    + lib. MIDI v4.3.1, François Best 2016, licence MIT, https://github.com/FortySevenEffects/arduino_midi_library/
 *       - doc : http://fortyseveneffects.github.io/arduino_midi_library/
 *    + lib. SoftwareSerial 1.0, http://www.arduino.cc/en/Reference/SoftwareSerial
 *    
 *    Réception de notes MIDI pour activer des contacts de jouets sonores
 *    entrée : une prise MIDI DIN5, reliée à un port Software Serial de l'arduino
 *    sortie : 16 activateurs de contacts (2 broches par activateur)
 *    Seuls les messages MIDI NOTE ON sont utilisés, les messages NOTE OFF sont déclenchés automatiquement
 *    
 *     
 *    info de debug disponibles sur le port série hardware de l'arduino (connexion USB)
 *    Ce programme n'utilise pas delay() en dehors du setup()
 *    
 *    Note : avec le SQ-1 relié en USB on peut voir le flux de données reçues sur linux
 *      avec 'aseqdump -p 20:0' (ou 20:0 est connu grâce à 'aconnect -i') 

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

// ************* options à définir (true / false) *************************************

// DEBUG OR NOT DEBUG ?
#define DEBUG           true

// MIDI HARDWARE ?
#define MIDISEQ         true

// Réception USB ?
#define SEQ             true

// *************************************************************************************

// Déclaration des broches utilisées par le circuit
//   On utilise uniquement le RX du port série logiciel, alors on désactive le TX pour libérer cette broche
//   cette broche et l'utiliser pour une broche (toutes les autres sont occupées)
//   Comme alternative moins bidouille, on pourrait utiliser la lib. modifée de Nick Gammon
//   cf. http://forum.arduino.cc/index.php?topic=112013.0 
#if MIDISEQ
  #define BROCHE_SOFTWARESERIAL_RX   2       // Réception MIDI sur cette broche
  #define BROCHE_SOFTWARESERIAL_TX   2       // !! Désactivée, cf. https://forum.arduino.cc/index.php?topic=214787
#endif
#define BROCHE_LED_MIDI            3       // informe de la réception d'un message midi reconnu comme valide

unsigned long led_moment_on = 0;           // pour redéclencher la led sans utiliser delay() (non-bloquant)       
const long led_duree = 80;                 // durée de led allumée       
unsigned long maintenant;                  // (non-bloquant)          

const int nombre_sorties = 16;             // 16 sorties sont utilisées pour activer 4 x 4066
int broches[nombre_sorties] = {            // dans l'ordre, ces broches seront activées par les notes MIDI de 60 à 75
  4, 5, 6, 7, 8, 9, 10, 11, 12, 13, A0, A1, A2, A3, A4, A5
};
unsigned long notes[nombre_sorties] = {    // le moment ou un note off doit être envoyé (non-bloquant)
  0, 0, 0, 0,     0, 0, 0, 0,     0, 0, 0, 0,     0, 0, 0, 0    
};

// Définir une entrée MIDI sur un port série logiciel
#if MIDISEQ
  #include <MIDI.h>
  #include <SoftwareSerial.h>
  SoftwareSerial software_serial(BROCHE_SOFTWARESERIAL_RX, BROCHE_SOFTWARESERIAL_TX); // RX, TX
  MIDI_CREATE_INSTANCE(SoftwareSerial, software_serial, MIDI);
#endif

int delai = 100; // delai d'activation d'une sortie
String source = "";                         // Utilisé pour les messages de debug

#if SEQ 
  byte octet_entrant = 0;    // for incoming serial data
  char commande[nombre_sorties] = {'A', 'Z', 'E', 'R', 'T', 'Y', 'I', 'U', 'O', 'P', 'Q', 'S', 'D', 'F', 'G', 'H'}; 
#endif


void setup() {
  
  #if DEBUG || SEQ
    Serial.begin(57600);
  #endif
  
  // Définir le type entrée/sortie des toutes les broches utilisées
  pinMode(BROCHE_LED_MIDI, OUTPUT);
  for (int i = 0; i < nombre_sorties; i++) {
    pinMode(broches[i], OUTPUT);
  }

  #if MIDISEQ
    // Déclarer les messages MIDI reconnus 
    MIDI.setHandleNoteOn(declencherSon);  // Nom de la fonction associée à un évènement MIDI "Note On"
    //MIDI.setHandleNoteOff(handleNoteOff);
    MIDI.begin(MIDI_CHANNEL_OMNI);        // Déclencher la réception du MIDI sur tous les canaux
  #endif

  #if DEBUG
    // Test de la led de réception MIDI
    digitalWrite(BROCHE_LED_MIDI, HIGH);
    delay(500);
    digitalWrite(BROCHE_LED_MIDI,  LOW);
    
    // Activer chaque sortie, l'une après l'autre pour vérifier que les sons sont déclenchés
    // ! durée 4 secondes
    for(int i = 0; i < nombre_sorties; i++){
      digitalWrite(broches[i], HIGH);
      digitalWrite(BROCHE_LED_MIDI, HIGH);
      delay(100);
      digitalWrite(broches[i], LOW);
      digitalWrite(BROCHE_LED_MIDI,  LOW);
      delay(150);
    };
  
    Serial.println("Ritournelle v0.6 / reception MIDI");
  #endif
  
  delay(1000);
}

void loop() {

  // Combien de millisecondes se sont écoulées depuis le lancement du sketch ? 
  maintenant = millis(); 
  
  // Eteindre la led si nécessaire
  if (led_moment_on > 0 && (maintenant - led_moment_on >= led_duree)) {
    led_moment_on = 0;
    digitalWrite(BROCHE_LED_MIDI, LOW);
  }

  // Arrêter les notes si nécessaire
  for (int i=0; i < nombre_sorties; i++) {
    if (notes[i] > 0 && maintenant - notes[i] > delai) {
      notes[i] = 0;
      digitalWrite(broches[i], LOW); 
    }
  }

  #if MIDISEQ
    // Lire les messages MIDI reçus
    MIDI.read();
  #endif

  #if SEQ
    if(Serial.available() > 0){
      octet_entrant = Serial.read();
      for(int i=0; i<nombre_sorties; i++){
        if(octet_entrant == commande[i]){
          source = "usb";
          declencherSon(1, i+60, 127);
        } 
      }
    }
  #endif
}

void declencherSon(byte canal, byte note, byte velocite) {
  
  #if DEBUG
    Serial.print("midi in (");
    if (source != "") {
      Serial.print("usb) : ");
      source = "";
    } else Serial.print("midi) : ");
    Serial.print(canal, DEC);
    Serial.print(" ");
    Serial.print(note, DEC);
    Serial.print(" ");
    Serial.print(velocite, DEC);
    Serial.print(" / ");
  #endif
  
  int broche_a_activer = note - 60;
  
  if (broche_a_activer >= 0 && broche_a_activer <= 15) {
    led_moment_on = millis();
    digitalWrite(BROCHE_LED_MIDI, HIGH);
    digitalWrite(broches[broche_a_activer], HIGH);
    notes[broche_a_activer] = millis();

    #if DEBUG
      Serial.print("sortie activee : ");
      Serial.println(broches[broche_a_activer]);
    #endif
  }
}





