import controlP5.*;
import processing.serial.*;
import java.util.Date;

class Slide {
  color c = color(random(50, 255));
  int[] px = new int[8*8];

  int get(int x, int y) {
    return px[y * 8 + x];
  }
  void set(int x, int y, int c) {
    px[y * 8 + x] = c;
  }
  int[] bits() {
    int[] frame = new int[8];
    for (int i=0; i<8; i++) {
      int p = 0;
      for (int j=0; j<8; j++) {
        p *= 2;
        p += px[j * 8 + i];
      }
      frame[i] = p;
    }

    return frame;
  }
  String frameString() {
    String f = "";
    for (int i=0; i<8; i++) {
      int p = 0;
      for (int j=0; j<8; j++) {
        p *= 2;
        p += px[j * 8 + i];
      }
      f += p;
      if (i!=7) {
        f += ",";
      }
    }
    f += "\n";
    return f;
  }
  Slide() {
    clear();
  }
  Slide(int[] pxs) {
    for (int i=0; i<8*8; i++) {
      px[i] = pxs[i];
    }
  }
  Slide(String str) {
    int[] values = int(split(str, ","));

    for (int i=0; i<values.length; i++) {
      String bs = binary(values[i], 8);
      for (int j=0; j<bs.length(); j++) {
        int k = parseInt(bs.substring(j, j+1));
        set(i, j, k);
      }
    }
  }
  void clear() {
    for (int i=0; i<8*8; i++) {
      px[i] = 0;
    }
  }
  void export() {
    print("{\n");
    for (int i=0; i<8*8; i++) {
      if (i%8==0) print("   B");
      print(px[i]);
      if (i%8==7 && i!=63) {
        println(",");
      }
    }
    print("\n}");
  }
}


ArrayList slides = new ArrayList();
Serial myPort;
int lastSend = millis();
int screenW = 500;
int screenH = 500;
int dVal = 0;
ControlP5 cp5;
DropdownList d1;
boolean addOnClick = false;
String animationPath = "data/animations/";
// ----------------------------------------------
void setup() {
  size(800, 500);


  cp5 = new ControlP5(this);
  d1 = cp5.addDropdownList("Animations").setPosition(screenW+50, 10).setSize(100, height).setBarHeight(30).setItemHeight(30);
  loadAnimationFiles();

  cp5.addButton("Add-Click-off").setPosition(screenW+180, 10).setSize(100, 30);



  String[] ports = Serial.list();
  String portName = ports[3];
  for (int i=0; i<ports.length; i++) {
    println(ports[i]);
  }
  myPort = new Serial(this, portName, 9600);
  slides.add(new Slide());
}

boolean bPlay = false;
int c = 0;
int lastTime = millis();
float t = 0;
ArrayList animationsFiles = new ArrayList();

// ----------------------------------------------
void loadAnimationFiles() {
  d1.clear();
  animationsFiles = new ArrayList();
  File folder = new File(dataPath("animations"));
  File[] files = folder.listFiles();

  int k = 0;
  for (int i=0; i<files.length; i++) {
    if (!files[i].getName().toLowerCase().equals(".ds_store")) {
      d1.addItem(files[i].getName(), k);
      animationsFiles.add(files[i].getName());
      k ++;
    }
  }
  loadAnimation(files[1].getName());
  d1.close();
}

// ----------------------------------------------
void draw() {
  background(0);
  if (slides.size() == 0) return;
  Slide slide = (Slide)slides.get(c);

  if (bPlay) {
    if (millis() - lastTime > 100) {
      c ++;
      c %= slides.size();
      lastTime = millis();
    }
  }

  /*
  float div = (float)mouseX / (float)width;
   for (int i=0; i<8; i++) {
   for (int j=0; j<8; j++) {
   int c = (int)round(noise((float)(i*div)-t, (float)j*div));
   println(c);
   slide.set(i, j, c);
   }
   }
   t += 0.05;
   */

  float cellSize = screenW / 8;
  for (int i=0; i<8; i++) {
    for (int j=0; j<8; j++) {

      float x = map(i, 0, 8, 0, screenW);
      float y = map(j, 0, 8, 0, screenH);

      int g = slide.get(i, j);

      if (g == 0) {
        fill(0);
      } else {
        fill(slide.c);
      }
      rect(x, y, cellSize, cellSize);

      noFill();
      stroke(255);
      rect(x, y, cellSize, cellSize);
    }
  }

  if (millis() - lastSend > 80) {
    lastSend = millis();
    if (myPort!=null) {
      myPort.write(slide.frameString());
    }
  }
}

// ----------------------------------------------
void loadAnimation(String file) {
  String[] frames = loadStrings(animationPath+"/"+file);
  slides.clear();
  for (int i=0; i<frames.length; i++) {
    if (frames[i].length() >0) {
      Slide slide = new Slide(frames[i]);
      slides.add(slide);
    }
  }
}

// ----------------------------------------------
void controlEvent(ControlEvent theEvent) {
println(theEvent.getController().getName());
  if (theEvent.getController().getName() == "Animations") {
    int index = (int)theEvent.getController().getValue();

    println("Select Animations: "+index);
    String file = (String)animationsFiles.get(index);
    loadAnimation(file);
    d1.close();
  } else if (theEvent.getController().getName().equals("Add-Click-off")) {
    addOnClick = !addOnClick;
    theEvent.getController().setLabel(addOnClick?"Add-Click-on":"Add-Click-off");
  }
  
}

// ----------------------------------------------
void keyPressed() {
  if (key == ' ') {
    addSlide();
    //println(c);
  } 
  // ------------------------------
  else if (key == 'e') {
    println("static const uint8_t PROGMEM\nimages["+slides.size()+"][64] = {\n"); 
    for (int i=0; i<slides.size(); i++) {
      Slide s = (Slide)slides.get(i);
      s.export();
      if (i!=slides.size()-1) {
        println(",");
      }
    }
    println("\n};");
  } 
  // ------------------------------
  else if (key == 'n') {
    slides.clear();
    c = 0;
    println("New n"+slides.size());
  } 
  // ------------------------------
  else if (key == 'c' && slides.size() > 0) {
    Slide slide = (Slide)slides.get(c);
    slide.clear();
  } 
  // ------------------------------
  else if (key == 'p') {
    if (bPlay) {
      bPlay = false;
      c = slides.size()-1;
    } else {
      c = 0;
      lastTime = millis();
      bPlay = true;
    }
  } 
  // ------------------------------
  else if (key == 's') {
    String filename = animationPath+Long.toString(new Date().getTime())+".txt";
    String[] str = new String[slides.size()];
    for (int i=0; i<slides.size(); i++) {
      str[i] = ((Slide)slides.get(i)).frameString();
    }
    saveStrings(filename, str);
    loadAnimationFiles();
  } 
  // ------------------------------
  else if (keyCode == RIGHT) {
    if (c < slides.size()-1) c ++;
    println(c);
  } 
  // ------------------------------
  else if (keyCode == LEFT) {
    if (c > 0) c --;
    println(c);
  }
}


// ----------------------------------------------
void addSlide() {
  if (slides.size()>0) {
    Slide slide = (Slide)slides.get(c);
    slides.add(new Slide(slide.px));
  } else {
    slides.add(new Slide());
  }
  c = slides.size()-1;
}

boolean insideGrid() {
  return mouseX < screenW && mouseX > 0 && mouseY < screenH && mouseY > 0;
}

// ----------------------------------------------
void drawOnGrid(int v) {
  if (slides.size()==0) return;
  Slide slide = (Slide)slides.get(c);
  int x = (int)map(mouseX, 0, screenW, 0, 8);
  x = constrain(x, 0, 7);
  int y = (int)map(mouseY, 0, screenH, 0, 8);
  y = constrain(y, 0, 7);
  slide.set(x, y, v);
}

// ----------------------------------------------
void mousePressed() {
  if (insideGrid() && slides.size()>0) {
    Slide slide = (Slide)slides.get(c);
    int x = (int)map(mouseX, 0, screenW, 0, 8);
    x = constrain(x, 0, 8);
    int y = (int)map(mouseY, 0, screenH, 0, 8);
    y = constrain(y, 0, 8); 
    dVal = slide.get(x, y)==0?1:0;
    drawOnGrid(dVal);
    if(addOnClick) addSlide();
  }
}

void mouseDragged() {
  if (insideGrid()) {
    drawOnGrid(dVal);
  }
}