import controlP5.*;
import processing.serial.*;
import java.util.Date;

int ROWS = 8;
int COLS = 8;
int TOTAL = (ROWS * COLS);
int screenW = 250;
int screenH = 250;
float cellSize = floor(screenW / COLS);
boolean rotateScreen = true;
float thumbnailSize = 80;
Modal modal = new Modal();
String loadedFileName = "";
float changeTime = 100;

class Slide {
    float delay = 0.01;
    float ramp = 0.01;
    color c = color(random(50, 255), random(50, 255), random(50, 255));
    int index = 0;
    float radius = cellSize;
    
    String frameString() {
        String f = "";
        f += hexColor();
        f += "|"+ramp; // ramp up
        f += "|"+delay; // delay

        /*
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
        f += "|"+delay+"\n";
        */
        return f;
    }
    String hexColor() {
        return "#"+hex(c, 6);
    }
    Slide() { clear(); }
    Slide(String str) { clear(); }
    Slide(Slide slide) { }
    
    void clear() {
    }

    // -------------------------------------
    void drawThumb(float x, float y, float w, float h) {
        
        noStroke();
        fill(c);
        rect(x, y, w, h);

        /*
        float sqW = rotateScreen ? sqrt(2) * (w/2) : w;
        float r = (sqW/COLS);
        
        pushMatrix();
        if(rotateScreen) {
            translate(x + w/2, y);                
            rotate(radians(rotateScreen?45:0));
        }
        else {
            translate(x, y);                
        }
  
        for(int i=0; i<COLS; i++) {
            for(int j=0; j<ROWS; j++) {
                Cell cell = cells[j * COLS + i];
                float px = map(i, 0, COLS, 0.0, sqW);
                float py = map(j, 0, ROWS, 0.0, sqW);   
                
                noStroke();
                if(cell.isOn) {
                    fill(255, 255, 0);
                }
                else {
                    fill(120);
                }
                rect(px, py, r, r);

                noFill();
                stroke(100);
                rect(px, py, r, r);
               
            }
        }
        popMatrix();*/
    }

    // -------------------------------------
    void draw() {

    }

}

// ------------------------------------------------------------------------
ArrayList slides = new ArrayList();
Serial myPort;
int lastSend = millis();

int dVal = 0;
ControlP5 cp5;
DropdownList d1;
DropdownList portsDropList;
boolean addOnClick = false;
String animationPath = "data/animations/";
float guiOffsetX = 500;
float guiYPos;
Textfield tf, rampTF;
// ------------------------------------------------------------------------
boolean bPlay = false;
int c = 0;
int lastTime = millis();
float t = 0;
ArrayList animationsFiles = new ArrayList();
float slideDelayStartTime = 0;
ColorWheel colorWheel;
// ------------------------------------------------------------------------
void setup() {

    size(800, 600);
    PFont font = createFont("arial", 12);
    
    cp5 = new ControlP5(this);
    cp5.setFont(font);
    cp5.setColorForeground(0xff000000);
    cp5.setColorBackground(100);
    cp5.setColorActive(0xff000000);

    // GUI
    float ypos = 10;
    d1 = cp5.addDropdownList("animations").setPosition(guiOffsetX, 50).setSize(140, height).setBarHeight(30).setItemHeight(30);
    portsDropList = cp5.addDropdownList("ports").setPosition(guiOffsetX, 10).setSize(140, height).setBarHeight(30).setItemHeight(30); 
    
    // color whell 
    colorWheel = cp5.addColorWheel("color" , 250 , 10 , 200 ).setRGB(color(128,0,255));
    
    // send 
    cp5.addButton("send").setPosition(guiOffsetX+180, ypos).setSize(100, 30);  ypos += 40;

    // load all the animations file
    loadAnimationFiles();

    tf = cp5.addTextfield("delay")
            .setPosition(guiOffsetX, ypos)
            .setSize(40, 20)
            .setFont(font)
            .setLabel("")
            .setAutoClear(false)
            .setInputFilter(ControlP5.FLOAT);

    rampTF = cp5.addTextfield("ramp")
            .setPosition(guiOffsetX, ypos)
            .setSize(40, 20)
            .setFont(font)
            .setLabel("")
            .setAutoClear(false)
            .setInputFilter(ControlP5.FLOAT);
    
    ypos += 40;
    guiYPos = ypos + 50;

    // load all the com - ports - need to add to GUI
    String[] ports = Serial.list();
    String portName = ports[3];
    for (int i=0; i<ports.length; i++) {
        println(i, ports[i]);
        portsDropList.addItem(ports[i], i);
    }
    portsDropList.setValue(3);
    portsDropList.close();
    
    // myPort = new Serial(this, portName, 9600);

    // start with one slide
    slides.add(new Slide());

}


// ----------------------------------------------
void draw() {
    background(120);
   
    if (slides.size() == 0) return;
    Slide slide = (Slide)slides.get(c);
    float t = millis() - lastTime;

    if (bPlay) {
        if (t > changeTime) {
            if(t > (slide.delay*1000.0) + changeTime) {
                c ++; 
                c %= slides.size();
                lastTime = millis();    
            }
        }
    }

   slide.draw();

    fill(255, 0, 0);
    ellipse(mouseX, mouseY, 3, 3);

    
    fill(0);
    String info = "";
    info += "press (n) to add new frame\n";
    info += "press (s) to save animation\n";
    info += "press (c) to clear frame\n";
    info += "press (n) to start over\n";
    info += "press (d) to delete frame\n";
    info += "press (arrow left/right) to change frames\n";
    text(info, guiOffsetX, guiYPos);



    float w = thumbnailSize;
    float top = height-(w+20);
    rectMode(CORNER);
    noFill();
    stroke(255);
    rect(0, top-1, width, 20);
    
    int maxInWidth = int(width / w);
    int indexOffset = c >= maxInWidth ? (c - maxInWidth + 1) : 0;
    float offset = (indexOffset) * w;
    for(int i = 0; i<slides.size(); i++) {
        Slide s = (Slide)slides.get(i);
        float x = (i * w) - offset;
        float y = height-w;
        noStroke();
        
        boolean inside = insideRect(mouseX, mouseY, x, y, w, w);
        fill(inside?200:0);
        rect(x, y, w, w);
        s.drawThumb(x, y, w, w);

        noFill();
        stroke(255);
        line(x, height, x, top);

        if(c == i) {
            noFill();
            fill(255);
            rect(x, top-1, w, 20);
        }
        fill(0);
        textAlign(CENTER);
        text("Frame "+i, x+(w/2), top+15);
        if(c == i) {
            
            noStroke();
            fill(0);
            rect(x, top-22, w, 20);
            fill(100);
            rect(x, top-42, w, 20);

            textAlign(LEFT);
            fill(255);
            text("Ramp ", x+3, top-28);
            rampTF.setPosition(x+39, top-42);
            
            text("Delay ", x+3, top-8);
            tf.setPosition(x+39, top-22);
            

            if(t > changeTime && bPlay) {
                float m = map(t, 0, (slide.delay*1000.0) + changeTime, 0.0, 1.0);
                noStroke();
                fill(255, 255, 0);
                rect(x, top-24, w*m, 2);
            }
        }
        textAlign(LEFT);
    }

    // what frame are we on?
    fill(255);
    text("Frame "+c+"/"+(slides.size()-1), 15, 20);
    
    if(colorWheel.isMousePressed()) {
        slide.c = colorWheel.getRGB();
        if (millis() - lastSend > 80) {
            lastSend = millis();
            sendSingleColor(slide);
        }
    }
    if(tf.isFocus() == false) {
        tf.setText(str(slide.delay));
    }
    if(rampTF.isFocus() == false) {
        rampTF.setText(str(slide.ramp));
    }
    modal.draw();
}

// ------------------------------------------------------------------------
void sendSingleColor(Slide slide) {
    myPort.write(slide.hexColor()+"\n");
    println("Hex: "+slide.hexColor()+"\n");
}

// ------------------------------------------------------------------------
void loadAnimationFiles() {
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

// ------------------------------------------------------------------------
void loadAnimation(String file) {
  String[] frames = loadStrings(animationPath+"/"+file);
  slides.clear();
  for (int i=0; i<frames.length; i++) {
    if (frames[i].length() >0) {
      Slide slide = new Slide(frames[i]);
      slides.add(slide);
    }
  }
  loadedFileName = file;
}

// ------------------------------------------------------------------------
void onTextFieldChange(ControlEvent event) {

}

// ------------------------------------------------------------------------
void controlEvent(ControlEvent theEvent) {
  
    String name = theEvent.getController().getName();
    println(name);
    if(name == "ports") {
        if(myPort!=null) {
            myPort.clear();
            myPort.stop();
        }
        String[] ports = Serial.list();
        int index = (int)theEvent.getController().getValue();
        println("index: "+index);
        myPort = new Serial(this, ports[index], 9600);
    }
    else if (name == "animations") {
        int index = (int)theEvent.getController().getValue();
        println("Select Animations: "+index);
        String file = (String)animationsFiles.get(index);
        loadAnimation(file);
        d1.close();
    } 
    else if (name.equals("send")) {
        if (myPort!=null) {
            String cmd = "";
            for (int i = 0; i < slides.size(); ++i) {
                Slide slide = (Slide)slides.get(i);
                cmd += slide.frameString();
                if(i != slides.size()-1) {
                    cmd += ",";
                }
            }
            println("Command: "+cmd);
            myPort.write(cmd);

        }
    }
    else if(name.equals("delay")) {
        String str = tf.getStringValue();
        float v = float(str);
        if (!Float.isNaN(v)) { 
            Slide s = (Slide)slides.get(c);
            s.delay = v;
        }
    }
    else if(name.equals("ramp")) {
        String str = rampTF.getStringValue();
        float v = float(str);
        if (!Float.isNaN(v)) { 
            Slide s = (Slide)slides.get(c);
            s.ramp = v;
        }
    }
}

// ------------------------------------------------------------------------
void saveSlide() {
    String filename = loadedFileName=="" ? (animationPath+Long.toString(new Date().getTime())+".txt"):animationPath+loadedFileName;
    String[] str = new String[slides.size()];
    for (int i=0; i<slides.size(); i++) {
      str[i] = ((Slide)slides.get(i)).frameString();
    }
    saveStrings(filename, str);
    loadAnimationFiles();
    loadAnimation((String)animationsFiles.get(animationsFiles.size()-1));
    modal.setText("Saved", 2);
}

// ------------------------------------------------------------------------
void keyPressed() {
    
    if(tf.isFocus() || rampTF.isFocus()) return;

    if (key == ' ') {
        addSlide();
    } 

    // ------------------------------
    else if (key == 'd') {
        int n = c;
        if(c >= slides.size()-1) {
            n = slides.size()-2;
        }
        slides.remove(c);
        c = n;
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
      saveSlide();
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
    slides.add(new Slide(slide));
  } else {
    slides.add(new Slide());
  }
  c = slides.size()-1;
}

// ----------------------------------------------
boolean insideGrid() {
  return mouseX < 547;
}

// ----------------------------------------------
void mousePressed() {

    float w = thumbnailSize;
    float top = height-(w+20);
    int maxInWidth = int(width / w);
    int indexOffset = c >= maxInWidth ? (c - maxInWidth + 1) : 0;
    float offset = (indexOffset) * w;
    for(int i = 0; i<slides.size(); i++) {
        Slide slide = (Slide)slides.get(i);
        float x = (i * w) - offset;
        float y = height-w;
        boolean inside = insideRect(mouseX, mouseY, x, y, w, w);
        if(mousePressed && inside) {
            c = i;
            sendSingleColor(slide);
        }
    }

}

void mouseDragged() {
 
}