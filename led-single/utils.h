#pragma once
#include "./global.h"

int countString(String str, String del) {
  int i = 0;
  char * s = const_cast<char*>(str.c_str());
  const char * d = const_cast<const char*>(del.c_str());
  char * token;
  char * rest;
  while (token = strtok_r(s, d, &rest)) {
    i ++;
    s = rest;
  }
  return i;

}
long stringToHEX(String hexstring) {
  return (long) strtol( &hexstring[1], NULL, 16);
}
void createFromValues(String command, Frame * frame) {
  char * str = const_cast<char*>(command.c_str());
  char * token; char * rest;
  int k = 0;
  long color;
  float duration, delayAmount;
  while (token = strtok_r(str, "|", &rest)) {
    str = rest;
    if (k == 0) {
      color = stringToHEX(token);
    }
    else if (k == 1) {
      duration = atof(token);
    }
    else if (k == 2) {
      delayAmount = atof(token);
    }
    k ++;
  }

  frame->color.set(color);
  frame->duration = duration;
  frame->delayAmount = delayAmount;
  //Serial.print(color); Serial.print(",");
  //Serial.print(duration); Serial.println(",");
}

int calcTotalFrames(String command) {
  char * str = const_cast<char*>(command.c_str());
  char * token; char * rest;
  int c = 0;
  while (token = strtok_r(str, ",", &rest)) {
    c ++;
  }
  return c;
}

void createFromCommand(String command, int * totalFrames) {

  char * str = const_cast<char*>(command.c_str());
  char * token; char * rest;
  int c = 0;
  while (token = strtok_r(str, ",", &rest)) {
    str = rest;
    //Serial.println(token);
    createFromValues(token, &frames[c]);
    Serial.print("Color: ");
    Serial.println(frames[c].color.toString());

    Serial.print("Duration: ");
    Serial.println(frames[c].duration);
    Serial.println();
    c ++;
  }
  (*totalFrames) = c;


}

double noEasing (double t, double b, double c, double d) {
  return c * t / d + b;
}
double easeIn (double t, double b , double c, double d) {
  return c * (t /= d) * t + b;
}
double easeInOut(double t, double b , double c, double d) {
  if ((t /= d / 2) < 1) return c / 2 * t * t * t + b;
  return c / 2 * ((t -= 2) * t * t + 2) + b;
}
