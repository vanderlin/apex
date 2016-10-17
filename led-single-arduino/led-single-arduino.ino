/*
  Pixie reads data in at 115.2k serial, 8N1.
  Byte order is R1, G1, B1, R2, G2, B2, ... where the first triplet is the
  color of the LED that's closest to the controller. 1ms of silence triggers
  latch. 2 seconds silence (or overheating) triggers LED off (for safety).

  Do not look into Pixie with remaining eye!
*/
#include "./global.h"
#include "./utils.h"
#include "SoftwareSerial.h"
#include "Adafruit_Pixie.h"

#define NUMPIXELS 1
#define PIXIEPIN  6
SoftwareSerial pixieSerial(-1, PIXIEPIN);
Adafruit_Pixie strip = Adafruit_Pixie(NUMPIXELS, &pixieSerial);

// lets say we start at black!

String cmds = "#FF0000|2.5|3,#00FF00|3.5|2,#FF00FF|0.5|0.2";
int frameCount = 0;
int totalFrames = 0;

int count = 0;
double startV = 0;
double endV = 255;
double startTime = millis();
double delayAmount = 0;
double delayStartTime = millis();
bool inDelay = false;
double duration = 3.0;
Color color(0, 0, 0);
Color start;
Color end;

Color diff;
float prop = 0;
float value = 0;
float desValue = 255;
boolean temp = false;
boolean hasAnimation = false;
// ------------------------------------------------------------------------
void setup() {

  Serial.begin(9600);
  delay(1000);
  Serial.println("Boot");

  pixieSerial.begin(115200);
  strip.setBrightness(200);


  // color | ramp up time | pause time, etc...
  setupNewAnimation("#FF0000|1|1,#000000|1|1");

}

// ------------------------------------------------------------------------
void setupNewAnimation(String cmds) {
  createFromCommand(cmds, &totalFrames);
  Serial.print("Total Frames ");
  Serial.println(totalFrames);
  Serial.println("Apex Single Pixel");
  startTime = millis();
  delayStartTime = millis();
  frameCount = 0;

  Frame frame = frames[frameCount];
  duration = frame.duration;
  delayAmount = frame.delayAmount;
  start.set(0, 0, 0); // we start at black
  end.set(frame.color);
  hasAnimation = true;
}


// ------------------------------------------------------------------------
void loop() {


  int len = Serial.available();

  
  if (len > 0) {

    String s = Serial.readStringUntil('\n');

    // if this is a single color just set it and return + "\n"
    if (s.length() == 8) {
      char * str = const_cast<char*>(s.c_str());
      Color c;
      c.set(str);
      strip.setPixelColor(0, c.r, c.g, c.b);
      strip.show();
      hasAnimation = false;
      return;
    }

    setupNewAnimation(s);
    return;
  }
  
  if(!hasAnimation) {
    return;
  }
  

  double currentTime = (millis() - startTime) / 1000.0;
  float factor = easeInOut(currentTime, 0.0, 1.0, duration);

  color.r = start.r + (end.r - start.r) * factor;
  color.g = start.g + (end.g - start.g) * factor;
  color.b = start.b + (end.b - start.b) * factor;

  if (currentTime >= duration) {

    // we are done lock it out
    color = end;

    // do the delay
    if (currentTime >= duration + delayAmount) {
      //Serial.println("Done with delay");
      //Serial.println(delayAmount);
      startTime = millis();

      frameCount ++;
      frameCount %= totalFrames;

      Frame frame = frames[frameCount];
      duration = frame.duration;
      delayAmount = frame.delayAmount;
      color = end;
      start = end;
      end.set(frame.color);

    }

  }

  strip.setPixelColor(0, color.r, color.g, color.b);
  strip.show();

}


