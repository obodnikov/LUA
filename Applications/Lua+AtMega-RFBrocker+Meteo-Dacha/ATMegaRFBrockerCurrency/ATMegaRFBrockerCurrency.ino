#define NextTime2Analog 30000

#include "RCSwitch.h"



unsigned long nextTimeAnalog = 0;

RCSwitch mySwitch = RCSwitch();

void setup() {
  Serial.begin(19200);
  mySwitch.enableReceive(0);
  Serial.print("Start sniffing!\n");
}

void loop() {

 
  if (mySwitch.available()) {

    unsigned long int value = mySwitch.getReceivedValue();
    Serial.print(":send2mqtt:RFSniffer:");
    Serial.print(value);
    Serial.print(":ON:$\n");

    Serial.print(":send2mqtt:RFSniffer:code:");
    Serial.print(value);
    Serial.print(":$\n");
    
    mySwitch.resetAvailable();
  }
    


}
