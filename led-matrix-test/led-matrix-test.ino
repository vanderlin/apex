
#include <Wire.h>
#include "Adafruit_LEDBackpack.h"
#include "Adafruit_GFX.h"

Adafruit_8x8matrix matrix = Adafruit_8x8matrix();

void setup() {
  Serial.begin(9600);
  delay(100);
  Serial.println("8x8 LED Matrix");
  matrix.begin(0x70);  // pass in the address
  matrix.clear();
  matrix.writeDisplay();
}

int t = 0;
void loop() {
  Wire.setClock(400000);

  t = !t;

  for (int i = 0; i < 8; i++) {


    for (int j = 0; j < 8; j++) {
      matrix.clear();
      matrix.drawPixel(i, j, 1);
      int b = map(j, 0, 8, 1, 15);
      matrix.setBrightness(b);
      matrix.writeDisplay();
    }


    //    delay(100);
  }


}
