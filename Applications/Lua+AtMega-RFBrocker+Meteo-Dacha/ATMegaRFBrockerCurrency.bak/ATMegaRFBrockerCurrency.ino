#define NextTime2Analog 30000

// #include "RFControl.h"



unsigned long nextTimeAnalog = 0;

#include "RCSwitch.h"


RCSwitch mySwitch = RCSwitch();

void setup() {
  Serial.begin(19200);
//  RFControl::startReceiving(0);
  mySwitch.enableReceive(0);
  Serial.print("Start sniffing!\n");
}

void loop() {
/*  if(RFControl::hasData()) {
    unsigned int *timings;
    unsigned int timings_size;
    unsigned int pulse_length_divider = RFControl::getPulseLengthDivider();
    RFControl::getRaw(&timings, &timings_size);
    unsigned int buckets[8];
    RFControl::compressTimings(buckets, timings, timings_size);
    Serial.print("b: ");
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

/*  unsigned long now = millis();
  if (now > nextTimeAnalog){
    float analog1 = (abs(analogRead(A1)-512) * 30)/512;
    float analog2 = (abs(analogRead(A2)-512) * 30)/512;

    Serial.print(":send2mqtt:RFSniffer:analog1:");
    Serial.print(analog1,2);
    Serial.println(":$");

    Serial.print(":send2mqtt:RFSniffer:analog2:");
    Serial.print(analog2,2);
    Serial.println(":$");

    nextTimeAnalog = now + NextTime2Analog;
  }
*/

if (mySwitch.available()) {

Serial.print(":send2mqtt:RFSniffer:");
Serial.print(mySwitch.getReceivedValue());
Serial.print(":ON:$\n");

Serial.print(":send2mqtt:RFSniffer:code:");
Serial.print(mySwitch.getReceivedValue());
Serial.print(":$\n");


//  output(mySwitch.getReceivedValue(), mySwitch.getReceivedBitlength(), mySwitch.getReceivedDelay(), mySwitch.getReceivedRawdata(),mySwitch.getReceivedProtocol());

  mySwitch.resetAvailable();
}


}
