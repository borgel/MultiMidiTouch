/*
So heres the idea. This takes in cool input, and spits out MIDI that, say, Lewis can take
in and use to mix kewl beatz. It can speak SpaceNavigator, as well as multi touch ideally.
Perhaps, I can test that by making a multi touch piano or something.
-Can it speak TUIO?
  -Yes, I think so? It can certainly speak OSC if that works...
  
-Multitouch idea:
  Have an arraylist of all objects which are on screen at once, iterate across it whenever a
    finger is added. Ask each one if it is being touched, if so, tell it to act. Otherwise,
    move on
-http://www.tuio.org/?specification

-Hand down the midi send object to each object
*/
import netP5.*;
import TUIO.*;
import java.awt.geom.*;
import proxml.*;
import rwmidi.*;

XMLInOut xmlIO;

TuioProcessing tuioClient;

NetAddress oscRemote;
int OSC_SPEAK_PORT = 12000;  //8000

//Maintains the list of all regions
ArrayList regions;
ArrayList fingers;
ArrayList overlays;

//The outpout module for the entire program
OutputModule OM;
int MaxCC = 119;  //I think this works....?

boolean lastDrag = false;
float curRotate = 0.0, layScaleH, layScaleW;
String layoutFile = "";
int curID = 0;

void setup()
{
  frameRate(16);
  size(800, 600);  //4:3 works best...
  //size((int)(screen.height*1.33), screen.height);
  colorMode(HSB);  //useful?
  
  //Some random setup
  cursor(CROSS);
  rectMode(CORNER);
  ellipseMode(CORNER);
  
  PFont myFont = createFont("verdana", 12);
  textFont(myFont);
  
  overlays = new ArrayList();
  
  //Setup OSC and MIDI Things
  oscRemote = new NetAddress("127.0.0.1", OSC_SPEAK_PORT);  //speaks out, "127.0.0.1"
  
  //And start the output module
  OM = new OutputModule(true, false);  //midi and osc enable
  
  //Start the TUIOClient and things related
  tuioClient = new TuioProcessing(this);
  fingers = new ArrayList();
  fingers.add(new FingerIcon(0, new Point(-10, -10)));  //just a dummy to pad the array
  
  //Now create all the object regions and the array to store them in
  regions = new ArrayList();
  makeRegions();
  
  //MUST BE LAST
  //Much less CPU heavy with noLoop on.....
  //noLoop();
}

void makeRegions()
{
  //Read in from the XML file, do do the following if fail
  if(!takeInLayout())
  {
    println("Opening layout failed! Does it exist?");
    println("Adding Demo Regions and Objects...");
    ///////////////////////////////////////////////
    //This/these is for testing when no file is loaded
    InsetPiano piano;
    InsetButtonPad buttonPad;

    Tangible t = new InsetPiano(OM, curID, 50, 300, 250, 250/2, 1);
    Tangible[] in = {t};
    regions.add(new Region(regions.size(), in));
    curID++;
    
    t = new InsetButtonPad(OM, curID, 10, 10, 300, 150, 8, 8, true);  //true for pad
    //t = new InsetButtonPad(0, 0, width, height, 18);
    Tangible[] iin = {t};
    regions.add(new Region(regions.size(), iin));
    curID++;
    
    //Tangible[] in2 = createButtonCol(400, 10, 20, 100, 5);
    Region r = new Region(regions.size(), null);
    //endless, absolute knob
    r.add(new InsetKnob(OM, curID, 200, 200, 100, 100, true, false));  //endless, relative
    //not endless, relative knob
    r.add(new InsetKnob(OM, ++curID, 300, 200, 100, 100, false, true));  //endless, relative
    //endless, relative knob
    r.add(new InsetKnob(OM, ++curID, 400, 200, 100, 100, true, true));  //endless, relative
    
    r.add(new InsetSlider(OM, ++curID, 330, 10, 30, 180, false, true));  //the bools are fader, vert
    r.add(new InsetSlider(OM, ++curID, 360, 10, 30, 180, true, true));
    r.add(new InsetSlider(OM, ++curID, 450, 150, 200, 30, true, false));
    
    regions.add(r);
    curID++;
    ///////////////////////////////////////////////
  }
  //else it worked, move on
}

boolean takeInLayout()
{
  //layoutFile
  layoutFile = selectInput("Select the '.jzml' layout file...");  //JazzLemurTest.jzml
  
  if(layoutFile == null)
  {
    //File string was empty
    return false;
  }
  else
  {
    //Tack on the XML opener to the jzml file?
    //Add '<?xml>' to first line, thats it!
    BufferedReader reader = createReader(layoutFile);
    PrintWriter write = createWriter("tmp.xml");
    String lne = "";
    write.println("<?xml>");
    try {
      lne = reader.readLine();
    }
    catch (IOException e)
    {
      println("FAILED ADDING XML TAG SOMEHOW");
    }
    while(lne != null)
    {
      write.println(lne);
      
      try {
        lne = reader.readLine();
        }
      catch (IOException e)
      {
        println("FAILED ADDING XML TAG SOMEHOW");
      }
    }
    write.flush();
    write.close();
    
    //Perform the XML scraping
    xmlIO = new XMLInOut(this);
    try{
    xmlIO.loadElement("tmp.xml");  //layoutFile//without From, calls another method
    }catch(Exception e){
      //Failed in some way, give up now
      //Add code here to try calling the XML tag adder?
      //NO! This works by creating a temp file, so its IRRELEVANT
      return false;
    }
    return true;
  }
}
//Fires when the layout file is taken in, then reads it in
void xmlEvent(proxml.XMLElement element)
{
  //element.printElementTree(" ");
  /*
  All inside <JZML>, at level of Project, inside first <WINDOW> (as interface) w/ width and height of lemur
  <WINDOW>s contain all I need, they have meaningless children
    'class' defines what each thing is
    x, y, height, width all exist, contain what is expected
  See printout file in project folder
  */
  int lemurW, lemurH;
  int tix = 0, tiy = 0, tfx = 0, tfy = 0, tw = 0, th = 0;
  String clas;
  
  proxml.XMLElement jzml = element.getChild(1);  //child 0 is meaningless
  lemurW = jzml.getIntAttribute("width");
  lemurH = jzml.getIntAttribute("height");
  
  layScaleH = lemurH / height;
  layScaleW = lemurW / width;
  
  //prints, starting by displaying itself
  //jzml.printElementTree(" ");
  
  for(int i = 0; i < jzml.countChildren(); i++)  //walks to all kids
  {
    proxml.XMLElement cur = jzml.getChild(i);  //gets each group or object
    clas = cur.getAttribute("class");
    
    //The temp region to put everything in
    Region r = new Region(regions.size(), null);  //first term is its ID
    
    //referance x and y
    int rx = (int)(width*(float)cur.getIntAttribute("x")/lemurW);
    int ry = (int)(height*(float)cur.getIntAttribute("y")/lemurH);
    
    //Scale it
    rx = (int)(width*(float)rx/lemurW);
    ry = (int)(height*(float)ry/lemurH);
        
    //------------------------
    //These perform specific actions based on what it is
    if(clas.equals("Container"))  //a region of things
    {
      String iclas = "";
      
      //println(clas+" has "+cur.countChildren()+" children");
      //Now iterate along all contained things
      for(int j = 0; j < cur.countChildren(); j++)  //walks to all kids
      {
        proxml.XMLElement icur = cur.getChild(j);  //gets each group or object
        iclas = icur.getAttribute("class");
        
        //Take it
        tix = rx+icur.getIntAttribute("x");
        tiy = ry+icur.getIntAttribute("y");
        th = icur.getIntAttribute("height");
        tw = icur.getIntAttribute("width");
        
        //Scale it
        tix = (int)(width*(float)tix/lemurW);
        tiy = (int)(height*(float)tiy/lemurH);
        th = (int)(height*(float)th/lemurH);
        tw = (int)(width*(float)tw/lemurW);
        
        //make each object type and then add it to the region
        //Possible: knob, slider, button
        if (iclas.equals("CustomButton"))
        {
          r.add(new InsetButton(OM, curID, tix, tiy, tw, th, false));
          curID++;
        }
        else if (iclas.equals("Knob"))
        {
          r.add(new InsetKnob(OM, curID, tix, tiy, tw, th, true, false)); //should be false, false //endless, relative
          curID++;
        }
        else if (iclas.equals("Fader"))  //note, single sliders not supported, but single faders are
        {
          //Need more info for this one...
          boolean vert = true;
          if(tw > th)
            vert = false;
          //r.add(new InsetSlider(OM, curID, tix, tiy, tw, th, true, vert));
          r.add(new InsetMultiSlider(OM, curID, tix, tiy, tw, th, true, vert, 1));  //fader, vert, # total
          curID++;
        }
      }
    }
    else
    {
      //Take more info
      int rh = cur.getIntAttribute("height");
      int rw = cur.getIntAttribute("width");
      
      rh = (int)(height*(float)rh/lemurH);
      rw = (int)(width*(float)rw/lemurW);
    
      if (clas.equals("Pads"))
      {
        //make one and from the info and put it in r
        int ny = cur.getIntAttribute("row");
        int nx = cur.getIntAttribute("column");
        
        r.add(new InsetButtonPad(OM, curID, rx, ry, rw, rh, nx, ny, true));  //x, y, wid, hei, numx, numy
        curID += r.getTotalContained();
      }
      else if (clas.equals("Switches"))
      {
        //make one and from the info and put it in r
        int ny = cur.getIntAttribute("row");
        int nx = cur.getIntAttribute("column");
        
        r.add(new InsetButtonPad(OM, curID, rx, ry, rw, rh, nx, ny, false));  //x, y, wid, hei, numx, numy
        curID += r.getTotalContained();
      }
      else if (clas.equals("MultiSlider"))
      {
        int rOri = cur.getIntAttribute("horizontal");
        boolean ori = (rOri == 0);  //gives 0 if vert, 1 if horiz
        int q = cur.getIntAttribute("nbr");
        
        //ori is orientation, false is 'is fader'
        r.add(new InsetMultiSlider(OM, curID, rx, ry, rw, rh, false, ori, q));
        curID += r.getTotalContained();
      }
    }
    //cur = cur.getParent();
    //println(">"+clas);
    regions.add(r);
  }
}

//redraw() causes it to draw
void draw()
{
  background(0);
  
  //loop over list of all regions, calling draw
  for(int i = 0; i < regions.size(); i++)
  {
    Region r = (Region)(regions.get(i));
    r.paint();
  }
  //And all overlays
  for(int i = 0; i < overlays.size(); i++)
  {
    Overlay o = (Overlay)(overlays.get(i));
    o.paint();
  }
  
  //Draws fingers too
  for(int i = 0; i < fingers.size(); i++)
  {
    FingerIcon f = (FingerIcon)(fingers.get(i));
    f.paint(curRotate);
  }
  curRotate += .1;
  //println(fingers.size()+" fingers");
}

void clickAll(char un)
{
  boolean olay = false;
  for(int i = 0; i < fingers.size(); i++)
  {
    FingerIcon f = (FingerIcon)fingers.get(i);
    
    /*
    for(int j = 0; j < overlays.size(); j++)
    {
      Overlay o = (Overlay)(overlays.get(j));
      olay = o.click(f.p.x, f.p.y, un);
    }
    //Check to see if an overlay was clicked. If so, dont process that finger further
    if(olay)
      break;
    */
    for(int j = 0; j < regions.size(); j++)
    {
      Region r = (Region)(regions.get(j));
      if(r.inRegion(f.p.x, f.p.y))
      {
        r.click(f.uid, f.p.x, f.p.y, un);
      }
      //else, the region was not clicked in
    }
  }
  /*
  for(int i = 0; i < regions.size(); i++)
  {
    Region r = (Region)(regions.get(i));
    //Use the contents of fingers for click points
    for(int j = 0; j < fingers.size(); j++)
    {
      FingerIcon f = (FingerIcon)fingers.get(j);
      if(r.inRegion(f.p.x, f.p.y))
      {
        r.click(f.uid, f.p.x, f.p.y, un);
      }
      //else, the region was not clicked in
    }
  }
  */
}

///////////////////////////////////////////////////////////
//From here down are methods fired by physical interfaces//
///////////////////////////////////////////////////////////

//TUIO Methods
// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur)
{
  //println("add cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
  
  //give id as position in array, and then the point
  fingers.add(new FingerIcon(tcur.getCursorID(), new Point((int)(width - (width * tcur.getY())), (int)(height - (height * tcur.getX())))));
  
  clickAll('c');
  redraw();
}
// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur)
{
  //println("update cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY() +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
  removeTuioCursor(tcur);
  fingers.add(new FingerIcon(tcur.getCursorID(), new Point((int)(width - (width * tcur.getY())), (int)(height - (height * tcur.getX())))));
  
  clickAll('d');
  redraw();
}
// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur)
{
  //println("remove cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
  //fingers.remove(tcur.getCursorID());  //give id as position, and then it
  FingerIcon f = null;//(FingerIcon)(fingers.get(0));
  for(int i = 0; i < fingers.size(); i++)
  {
    f = (FingerIcon)(fingers.get(i));
    if(f.uid == tcur.getCursorID())
      break;
  }
  fingers.remove(f);
  
  clickAll('r');
  redraw();
}
// called after each message bundle
// representing the end of an image frame
void refresh(TuioTime bundleTime){redraw();}

//These will never occur without fidicules
// called when an object is added to the scene
void addTuioObject(TuioObject tobj){}
// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj){}
// called when an object is moved
void updateTuioObject (TuioObject tobj){}

////////////////////////////////////////////////////////
//Mouse stuff
void mouseClicked()
{
  //Mouse is always things 0
  fingers.add(new FingerIcon(0, new Point(mouseX, mouseY)));
  clickAll('c');
  
  redraw();
}
void mouseReleased()
{
  //remove the mouse
  //Sometimes removes it when its empty? What?
  
  //after a drag, when its released, this removes one too many
  if(!lastDrag) fingers.remove(0);
  else lastDrag = false;
  clickAll('r');
  
  redraw();
}
void mouseDragged()
{
  //Easiest to remove it and put it back
  fingers.remove(0);
  fingers.add(new FingerIcon(0, new Point(mouseX, mouseY)));
  clickAll('d');
  lastDrag = true;
  redraw();
}

//-------------------------------------------
//----------------------Additional Classes---
//-------------------------------------------
public class Overlay
{
  Tangible parent;
  Point iP, fP;  //initial and final points for connecting line (It is @ final)
  static final int diameter = 30;
  color back;
  int hheight, wwidth;
  
  Overlay(Tangible iPar)
  {
    parent = iPar;
    back = color(255, 255, 255);  //add transparency here?
    
    hheight = 0;
    wwidth = 0;
  }
  boolean click(int iX, int iY, char tclick)
  {
    if(tclick == 'c' || tclick == 'u')
    {
      return checkClick(iX, iY);
    }
    return false;
  }
  private boolean checkClick(int iX, int iY)
  {
    if(iX > this.fP.x && iX < (this.fP.x + this.wwidth))    //finds if the xy is inside the object
    {
      if(iY > this.fP.y && iY < (this.fP.y + this.hheight))
        return true;
      else
        return false;
    }
    else
      return false;
  }
  void paint()
  {
    fill(back, 255);  //255 for totally opaque
    
    //Draw a line between this and the parent's center
    strokeWeight(10);
    line(iP.x, iP.y, fP.x, fP.y);
    
    //And draw whatever interface at that finger
    //Ellipse
    tint(150, 150, 150, 100);  //r, g, b, trans
    ellipse(fP.x, fP.y, diameter, diameter);
  }
}

class FingerIcon
{
  Point p;
  int sz = 10, uid = -1;
  float sWidth = .25;
  boolean on = true;
  
  FingerIcon(int uuid, Point ip)
  {
    p = ip;
    uid = uuid;
  }
  void paint(float rot)
  {
    if(on)
    {
      //Paint a cool shape at each finger press point
      fill(0, 100, 255);  //hsb
      strokeWeight(0);
      
      ellipse(p.x-sz/2, p.y-sz/2, sz, sz);
      for(float i = 0; i <= 2*PI; i+=PI/2)
      { 
        arc(p.x-2*(sz/2), p.y-2*(sz/2), sz*2, sz*2, i+rot+(sWidth * PI), i+(PI/4)+rot+(sWidth * PI));  //x, y, wid, height, start, end (in rads)
      }
    }
  }
}
class OutputModule
{
  /*
  This is what allows any tangible to send control messages. It takes in send
  message commands, and then does so depending on OSC and MIDI
  Also handels and initializes MIDI and OSC /OUTPUT/ objects, so everything speaks
  in a coordinated fashion
  
  Make it automatically incriment channel when CC (and note?) > 127
  */
  boolean oscOn, midiOn;
  MidiOutput mIO;
  int mChannel = 0;  //initial channel
  
  OutputModule(boolean im, boolean io)
  {
    oscOn = io;
    midiOn = im;
    
    //Turn on the necessairy subsystems
    if(oscOn)
      enableOSC();
    if(midiOn)
      enableMIDI();
  }
  //Sclaes down so that its within the max allowible
  void sendCC(int id, int force)
  {
    force = scaleVal(force);
    int cc = id;
    int tchan = mChannel;
    
    if(cc > MaxCC)
    {
      cc -= MaxCC;
      tchan++;
    }
    //Fire MIDI for the given CC
    mIO.sendController(tchan, cc, force);
    
    //println("CC "+cc+" sent on ch "+tchan);
  }
  void noteOn(int kkey, int force)
  {
    force = scaleVal(force);
    //println(kkey+" hit @ "+force);
    //Fire MIDI
    mIO.sendNoteOn(mChannel, kkey, force);
    //Fire OSC
    
  }
  void noteOff(int kkey)
  {
    //println(kkey+" released");
    //Fire MIDI
    mIO.sendNoteOff(mChannel, kkey, 127);  //off with full force? w/e
    //Fire OSC
    
  }
  void hitPad(int kkey, int force)
  {
    force = scaleVal(force);
    //println("Pad "+kkey+" hit @ "+force);
    //MIDI On and Off immediately for fast MIDI pad action!
    noteOn(kkey, force);
    noteOff(kkey);
    //OSC of some sort
  }
  void enableOSC()
  {
    println("Enabling OSC output...");
  }
  void enableMIDI()
  {
    println("Enableing MIDI output from '"+RWMidi.getOutputDevices()[9]+"'");
    //Add dialog box to choose midi output?
    //For now, output hardcoded to #9 (yoke 8)
    mIO = RWMidi.getOutputDevices()[9].createOutput();  //2-9 is midi yoke
  }
  int scaleVal(int iv)
  {
    if(iv < 0)
      return 0;
    else if (iv > 127)
      return 127;
    else
      return iv;
  }
}
