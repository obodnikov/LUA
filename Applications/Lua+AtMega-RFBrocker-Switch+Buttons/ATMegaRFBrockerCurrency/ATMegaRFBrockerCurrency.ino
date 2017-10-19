#define NextTime2Analog 30000

#include "RFControl.h"



unsigned long nextTimeAnalog = 0;



void setup() {
  Serial.begin(19200);
  RFControl::startReceiving(0);
  Serial.print("Start sniffing!\n");
}

void loop() {
  if(RFControl::hasData()) {
    unsigned int *timings;
    unsigned int timings_size;
    unsigned int pulse_length_divider = RFControl::getPulseLengthDivider();
    RFControl::getRaw(&timings, &timings_size);
    unsigned int buckets[8];
    RFControl::compressTimings(buckets, timings, timings_size);
/*    Serial.print("b: ");
    for(int i=0; i < 8; i++) {
      unsigned long bucket = buckets[i] * pulse_length_divider;
      Serial.print(bucket);
      Serial.write(' ');
    }
    Serial.print("\nt: ");
    for(int i=0; i < timings_size; i++) {
      Serial.write('0' + timings[i]);
    }
    Serial.write('\n');
    Serial.write('\n');
*/
    Serial.print(":send2mqtt:RFSniffer:");
    for(int i=0; i < 8; i++) {
      unsigned long bucket = buckets[i] * pulse_length_divider;
      Serial.print(bucket);
    }
    Serial.print(":ON:$\n");

    Serial.print(":send2mqtt:RFSniffer:code:");
    for(int i=0; i < 8; i++) {
      unsigned long bucket = buckets[i] * pulse_length_divider;
      Serial.print(bucket);
    }
    Serial.print(":$\n");



    RFControl::continueReceiving();
  }

  unsigned long now = millis();
  if (now > nextTimeAnalog){
    
    unsigned int Analog1 = analogRead(A1);
    unsigned int Analog2 = analogRead(A2);
    float analog1 = abs(((Analog1-512.0) * 5.0)/512.0);
    float analog2 = abs(((Analog2-512.0) * 5.0)/512.0);
    

//    int analog1 = analogRead(A1);
//    int analog2 = analogRead(A2);

    Serial.print(":send2mqtt:RFSniffer:analog1:");
    Serial.print(analog1);
    Serial.println(":$");

    Serial.print(":send2mqtt:RFSniffer:analog2:");
    Serial.print(analog2);
    Serial.println(":$");

    Serial.print(":send2mqtt:RFSniffer:A1:");
    Serial.print(Analog1);
    Serial.println(":$");

    Serial.print(":send2mqtt:RFSniffer:A2:");
    Serial.print(Analog2);
    Serial.println(":$");

    nextTimeAnalog = now + NextTime2Analog;
  }


}
