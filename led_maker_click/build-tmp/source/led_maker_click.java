import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import processing.serial.*; 
import java.util.Date; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class led_maker_click extends PApplet {





int ROWS = 8;
int COLS = 8;
int TOTAL = (ROWS * COLS);
int screenW = 250;
int screenH = 250;
float cellSize = floor(screenW / COLS);
boolean rotateScreen = true;

class Cell {
    int index;
    float radius;
    PVector pt = new PVector();
    boolean isOn = true;
    Cell() {
    }
    public boolean inside(float x, float y) {
        return dist(pt.x, pt.y, x, y) < radius/2;
    }
    public int val() {
        return isOn ? 1 : 0;
    }
    public int setVal(int v) {
        isOn = v == 1 ? true : false;
        return val();
    }
    public void draw() {

        pushMatrix();
        if(rotateScreen) {
            rectMode(CENTER);
            translate(pt.x, pt.y);
        }
        else {
            rectMode(CORNER);
            translate(pt.x-radius/2, pt.y-radius/2);
        }
        rotate(rotateScreen?radians(45):0);
        fill(0);
        rect(0, 0, radius, radius);
        popMatrix();

        if(inside(mouseX, mouseY)) {
            fill(255, 0, 255);
        }
        else {
            fill(185);
        }
        
        if(isOn) {
            fill(255, 255, 0);
        }
        ellipse(pt.x, pt.y, radius/1.3f, radius/1.3f);

        fill(0);
        ellipse(pt.x, pt.y, 1, 1);
    }
}

class Slide {
    int c = color(random(50, 255));
    Cell[] cells = new Cell[TOTAL];
    int index = 0;
    float radius = cellSize;
    
    public int get(int x, int y) {
        return cells[y * COLS + x].val();
    }
    public void set(int x, int y, int c) {
        cells[y * COLS + x].setVal(c);
    }
    
    public int[] bits() {
        int[] frame = new int[ROWS];
        for (int i=0; i<ROWS; i++) {
            int p = 0;
            for (int j=0; j<COLS; j++) {
                p *= 2;
                p += cells[j * COLS + i].val();
            }
            frame[i] = p;
        }
        return frame;
    }

    public String frameString() {
        String f = "";
        for (int i=0; i<8; i++) {
            int p = 0;
            for (int j=0; j<8; j++) {
                p *= 2;
                p += cells[j * 8 + i].val();
            }
            f += p;
            if (i!=7) {
                f += ",";
            }
        }
        f += "\n";
        return f;
    }

    Slide() { clear(); }

    Slide(Cell[] in) {
        clear();
        for (int i=0; i<TOTAL; i++) {
            cells[i].setVal(in[i].val());
        }
    }

    Slide(String str) {
        clear();
        int[] values = PApplet.parseInt(split(str, ","));
        for (int i=0; i<values.length; i++) {
            String bs = binary(values[i], 8);
            for (int j=0; j<bs.length(); j++) {
                int k = parseInt(bs.substring(j, j+1));
                set(i, j, k);
            }
        }
    }

    public void clear() {
        for (int i=0; i<TOTAL; i++) { 
            cells[i] = new Cell();
            cells[i].isOn = false;
        }
    }

  public void draw() {

    float gridSize = screenW;
    float centerX = (500 - screenW)/2;
    float centerY = (500 - screenH)/2;
    for(int i=0; i<COLS; i++) {
        for(int j=0; j<ROWS; j++) {
            int index = j * COLS + i;
            Cell cell = cells[index];
            float x = map(i, 0, COLS-1, 0.0f, screenW);
            float y = map(j, 0, ROWS-1, 0.0f, screenH);

            cell.index = index;
            cell.pt.set(x, y);

            if(rotateScreen) {
                cell.pt = translatePoint(cell.pt, -gridSize/2, -gridSize/2);
                cell.pt = rotatePoint(cell.pt, radians(45));
                cell.pt = translatePoint(cell.pt, gridSize/2, gridSize/2);

                cell.pt.x += centerX;
                cell.pt.y += centerY;
            }
            else {
                cell.pt.set(centerX+x, centerY+y);
            }

            cell.radius = radius;
            cell.draw();
        }
    }
  }
  public void export() {
    print("{\n");
    for (int i=0; i<TOTAL; i++) {
      if (i%ROWS==0) print("   B");
      print(cells[i].val());
      if (i%ROWS==ROWS-1 && i!=TOTAL-1) {
        println(",");
      }
    }
    print("\n}");
  }
}

// ------------------------------------------------------------------------
ArrayList slides = new ArrayList();
Serial myPort;
int lastSend = millis();

int dVal = 0;
ControlP5 cp5;
DropdownList d1;
boolean addOnClick = false;
String animationPath = "data/animations/";
float guiOffsetX = 500;

// ------------------------------------------------------------------------
public void setup() {
    

    cp5 = new ControlP5(this);
    // GUI
    float ypos = 10;
    d1 = cp5.addDropdownList("Animations").setPosition(guiOffsetX+50, 10).setSize(100, height).setBarHeight(30).setItemHeight(30);

    // load all the animations file
    loadAnimationFiles();

    cp5.addButton("Add-Click-off").setPosition(guiOffsetX+180, ypos).setSize(100, 30);  ypos += 40;
    cp5.addButton("Rotate").setPosition(guiOffsetX+180, ypos).setSize(100, 30);         ypos += 40;


    // load all the com - ports - need to add to GUI
    String[] ports = Serial.list();
    String portName = ports[3];
    for (int i=0; i<ports.length; i++) {
        println(i, ports[i]);
    }
    myPort = new Serial(this, portName, 9600);

    // start with one slide
    slides.add(new Slide());

    loadAnimation((String)animationsFiles.get(0));
}


// ------------------------------------------------------------------------
boolean bPlay = false;
int c = 0;
int lastTime = millis();
float t = 0;
ArrayList animationsFiles = new ArrayList();

// ----------------------------------------------
public void loadAnimationFiles() {
  d1.clear();
  animationsFiles = new ArrayList();
  File folder = new File(dataPath("animations"));
  File[] files = folder.listFiles();

  int k = 0;
  for (int i=0; i<files.length; i++) {
    if (files[i].getName().toLowerCase().indexOf(".txt")>0) {
      d1.addItem(files[i].getName(), k);
      animationsFiles.add(files[i].getName());
      k ++;
    }
  }
  loadAnimation(files[1].getName());
  d1.close();
}


// ----------------------------------------------
public void draw() {
    background(120);
    if (slides.size() == 0) return;
    Slide slide = (Slide)slides.get(c);

    if (bPlay) {
        if (millis() - lastTime > 100) {
            c ++; c %= slides.size();
            lastTime = millis();
        }
    }

   slide.draw();

    fill(255, 0, 0);
    ellipse(mouseX, mouseY, 3, 3);

    if (millis() - lastSend > 80) {
        lastSend = millis();
        if (myPort!=null) {
            myPort.write(slide.frameString());
        }
    }
    
    fill(0);
    String info = "";
    info += "press (n) to add new frame\n";
    info += "press (s) to save animation\n";
    info += "press (c) to clear frame\n";
    info += "press (n) to start over\n";
    info += "press (arrow left/right) to change frames\n";
    text(info, guiOffsetX+50, 100);


    text("Frame "+c, 20, height-20);
}



// ------------------------------------------------------------------------
public void loadAnimation(String file) {
  String[] frames = loadStrings(animationPath+"/"+file);
  slides.clear();
  for (int i=0; i<frames.length; i++) {
    if (frames[i].length() >0) {
      Slide slide = new Slide(frames[i]);
      slides.add(slide);
    }
  }
}

// ------------------------------------------------------------------------
public void controlEvent(ControlEvent theEvent) {
  
  println(theEvent.getController().getName());

  if (theEvent.getController().getName() == "Animations") {
    int index = (int)theEvent.getController().getValue();
    println("Select Animations: "+index);
    String file = (String)animationsFiles.get(index);
    loadAnimation(file);
    d1.close();
  } 
  else if (theEvent.getController().getName().equals("Add-Click-off")) {
    addOnClick = !addOnClick;
    theEvent.getController().setLabel(addOnClick?"Add-Click-on":"Add-Click-off");
  }
  else if (theEvent.getController().getName().equals("Rotate")) {
    rotateScreen = !rotateScreen;
  }
}

// ----------------------------------------------
public void keyPressed() {
  if (key == ' ') {
    addSlide();
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
    slides.add(new Slide());
    println("New "+slides.size());
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
    loadAnimation((String)animationsFiles.get(animationsFiles.size()-1));

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
public void addSlide() {
  if (slides.size()>0) {
    Slide slide = (Slide)slides.get(c);
    slides.add(new Slide(slide.cells));
  } else {
    slides.add(new Slide());
  }
  c = slides.size()-1;
}

// ----------------------------------------------
public boolean insideGrid() {
  return mouseX < 547;
}

// ----------------------------------------------
public void drawOnGrid(int v) {
    Slide slide = (Slide)slides.get(c);
    for (int i = 0; i < slide.cells.length; ++i) {
        Cell cell = slide.cells[i];
        if(cell.inside(mouseX, mouseY)) {
            cell.setVal(v);
        }
    }
}

// ----------------------------------------------
public void mousePressed() {
    if (insideGrid() && slides.size()>0) {
        Slide slide = (Slide)slides.get(c);
        for (int i = 0; i < slide.cells.length; ++i) {
            Cell cell = slide.cells[i];
            if(cell.inside(mouseX, mouseY)) {
                cell.isOn = !cell.isOn;
                dVal = cell.val();
                if(addOnClick) {
                    addSlide();
                }
            } 
        }
    }
}

public void mouseDragged() {
  if (insideGrid() && slides.size()>0) {
    drawOnGrid(dVal);
  }
}

// ------------------------------------------------------------------------
public PVector rotatePoint(PVector p, float a) {
    float mx = p.x;
    float my = p.y;
    float rx = mx*cos(a) - my*sin(a);
    float ry = mx*sin(a) + my*cos(a);
    return new PVector(rx, ry);
}

// ------------------------------------------------------------------------
public PVector translatePoint(PVector p, float tx, float ty) {
    return new PVector(p.x+tx, p.y+ty);
}
  public void settings() {  size(800, 500); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "led_maker_click" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
