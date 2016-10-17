
#include <Wire.h>
#include "Adafruit_LEDBackpack.h"
#include "Adafruit_GFX.h"

Adafruit_8x8matrix matrix = Adafruit_8x8matrix();
unsigned char pxs[8];


// ------------------------------------------------------------------------
void setup() {
  Serial.begin(9600);
  delay(100);
  Serial.println("8x8 LED Matrix");
  matrix.begin(0x70);
  matrix.clear();
  matrix.writeDisplay();
  memset(pxs, 0, 8);
}

// ------------------------------------------------------------------------
void loop() {

  int len = Serial.available();

  if (len > 0) {
    String s = Serial.readStringUntil('\n');
    String val = "";
    int count = 0;
    for (int i = 0; i < s.length(); i++) {
      char c = s[i];
      if (c != ',') {
        val += String(c);
      }
      if (c == ',' || c == '\n' || i == s.length() - 1) {
        pxs[count] = val.toInt();
        count ++;
        val = "";
      }
    }
  }
  
  matrix.clear();
  matrix.drawBitmap(0, 0, pxs, 8, 8, LED_ON);
  matrix.writeDisplay();
  
}
