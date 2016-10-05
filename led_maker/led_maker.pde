
import java.io.File;

class Slide {
  PImage image;
  int[] px = new int[8*8];
  int get(int x, int y) {
    return px[y * 8 + x];
  }
  Slide(String file) {
    image = loadImage(file);
    //image.resize(8, 8);
    image.loadPixels();

    for (int i=0; i<8; i++) {
      for (int j=0; j<8; j++) {
        color c = image.get(i, j);
        int g = ((int)red(c) + (int)green(c) + (int)blue(c)) / 3;
        px[j * 8 + i] = g>200 ? 0 : 1;
      }
    }

    print("{");
    for (int i=0; i<8*8; i++) {
      if (i%8==0) print("B");
      print(px[i]);
      if (i%8==7 && i!=63) {
        println(",");
      }
    }
    println("},\n");
  }
}


Slide[] slides = new Slide[16];

void setup() {
  size(800, 800);

  File dir = new File(dataPath("images/"));
  File [] files = dir.listFiles();
  int t = 0;
  for (int i = 0; i < files.length; i++) {
    if (!files[i].getName().equals(".DS_Store")) {
      t ++;
    }
  }

  if (t>0) {
    println("int images["+t+"][64] = {"); 
    slides = new Slide[t];
    t = 0;

    for (int i = 0; i < files.length; i++) {
      String file = files[i].getAbsolutePath();
      if (!files[i].getName().equals(".DS_Store")) {
        slides[t] = new Slide(file);
        //println(file);
        t ++;
      }
    }
    println("}");
  } else {
    noLoop();
    println("Error no files");
    exit();
  }
}

int c = 0;
void draw() {

  Slide slide = slides[c];
  c ++;
  c %= slides.length;
  for (int i=0; i<8; i++) {
    for (int j=0; j<8; j++) {

      int g = slide.get(i, j);

      float x = map(i, 0, 8, 0, width);
      float y = map(j, 0, 8, 0, height);



      if (g == 0) {
        fill(0);
      } else {
        fill(255);
      }
      rect(x, y, width/7, height/7);

      noFill();
      stroke(255);
      rect(x, y, width/7, height/7);
    }
  }


  //image(slide.image, 0, 0, 300, 300);
}