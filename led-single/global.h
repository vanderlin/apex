#pragma once

class Color {
  public:
    double r, g, b;
    Color() {
      set(0, 0, 0);
    }
    Color(double r, double g, double b) {
      this->r = r;
      this->g = g;
      this->b = b;
    }
    double operator=(double val) {
      r = val;
      g = val;
      b = val;
    }

    Color operator=(Color c) {
      this->r = c.r;
      this->g = c.g;
      this->b = c.b;
    }

    void set(double r, double g, double b) {
      this->r = r;
      this->g = g;
      this->b = b;
    }
    void set(char * hexstring) {
      long hex = (long) strtol( &hexstring[1], NULL, 16);
      set(hex);
    }
    void set(long hex) {
      this->r = hex >> 16;
      this->g = hex >> 8 & 0xFF;
      this->b = hex & 0xFF;
    }
    void set(Color c) {
      this->r = c.r;
      this->g = c.g;
      this->b = c.b;
    }
    String toString() {
      String _r = String(r, 1);
      String _g = String(g, 1);
      String _b = String(b, 1);
      return _r + ", " + _g + ", " + _b;
    }
};

class Frame {
  public:
    Color color;
    float delayAmount;
    double duration;
    Frame() {
      delayAmount = 0;
      duration = 0;
      color = 0;
    }
};

Frame frames[30];
