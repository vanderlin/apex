
#include <Wire.h>
#include "Adafruit_LEDBackpack.h"
#include "Adafruit_GFX.h"

Adafruit_8x8matrix matrix = Adafruit_8x8matrix();
unsigned char prev[8];
void setup() {
  Serial.begin(9600);
  delay(100);
  Serial.println("8x8 LED Matrix Test");
  matrix.begin(0x70);  // pass in the address

  matrix.clear();
  matrix.writeDisplay();
}

int a = 0;
void loop() {


  /*
    unsigned char k = random(0, 255);
    Serial.println(k);
    unsigned char pxs[8] = {k, 0, 0, 0, 0, 0, 0, 255};
    matrix.drawBitmap(0, 0, pxs, 8, 8, LED_ON);
  */

  int len = Serial.available();

  if (len > 0) {
    String s = Serial.readStringUntil('\n');
    String val = "";
    int count = 0;
    unsigned char pxs[8];
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
    matrix.clear();
    matrix.drawBitmap(0, 0, pxs, 8, 8, LED_ON);
    matrix.writeDisplay();

  }

  /*
    if (Serial.available() > 0) {
    unsigned char bits[len];
    memset(bits, 0, len);
    for (int i = 0; i < len; i++) {
      while (Serial.available() == 0) {}
      bits[i] = Serial.read();
    }
    matrix.clear();
    matrix.drawBitmap(0, 0, bits, 8, 8, LED_ON);
    matrix.writeDisplay();
    }*/


  delay(10);


}
