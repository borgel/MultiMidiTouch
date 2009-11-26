/*
Its a button!
*/
class InsetButton implements Tangible
{
  static final int glowCycles=6;
  int wwidth, hheight, x, y, id, lastClick = -1, cyclesOn;
  color unlit, lit, current;
  boolean updated = false, pad = false;
  OutputModule OM;
  
  InsetButton(OutputModule iom, int iid, int ix, int iy, int iwid, int ihi, boolean ipad)
  {
    this.x = ix;
    this.y = iy;
    this.wwidth = iwid;
    this.hheight = ihi;
    
    pad = ipad;
    id = iid;
    OM = iom;
    
    //this.lit = color(254, 255, 255); //reddish    // 10, 10
    color(RGB);
    this.lit = color((int)random(100, 255), (int)random(100, 255), (int)random(100, 255));
    this.unlit = color(100, 10, 100);  //greyish  //60, 60, 60
    this.current = unlit;
  }
  //Turns it on if its being called
  boolean click(int uid, int iX, int iY, char tclick)
  {
    if(tclick == 'c')
    {
      if(checkClick(uid, iX, iY))
      {
        updated = true;
        this.toggle();
        lastClick = uid;
        cyclesOn = 0;
        
        if(pad)
        {
          toggle();
          cyclesOn = glowCycles;
        }
        return true;
      }
      else
      {
        return false;
      }
    }
    else if(tclick == 'd')  //d for dragged
    {
      return updateClick(uid, iX, iY);
    }
    else  //causing a problem?
    {
      unClick();
      lastClick = -1;
      return true;
    }
  }
  //Turns it off if its being called
  void unClick()
  {
    OM.noteOff(id);
    updated = false;
    lastClick = -1;
  }
  boolean updateClick(int uid, int iX, int iY)
  {
    boolean cc = checkClick(uid, iX, iY);

    if(cc && !updated)
    {
      toggle();
      updated = true;
      cyclesOn = 0;
      lastClick = uid;
      
      if(pad)
      {
          toggle();
          cyclesOn = glowCycles;
      }
      return true;
    }
    else if(!cc && updated)
    {
      updated = false;
      return true;
    }
    return false;
  }
  boolean checkClick(int uid, int iX, int iY)
  {
    if(uid == lastClick || lastClick == -1)
    {
      if(iX > this.x && iX < (this.x + this.wwidth))    //finds if the xy is inside the object
      {
        if(iY > this.y && iY < (this.y + this.hheight))
          return true;
        else
          return false;
      }
      else
        return false;
    }
    return false;
    //else, some other finger is clicking
  }
  void paint()
  {
    paint(x, y, wwidth, hheight);
  }
  void paint(int iX, int iY, int iW, int iH)
  {
    colorMode(RGB);
    fill(this.current);
      
    strokeWeight(2);
    rect(iX, iY, iW, iH);
    
    if(cyclesOn-- > 0)  //make this fade
    {
      fill(this.lit, ((float)cyclesOn/glowCycles)*255);
      rect(iX, iY, iW, iH);
    }
    
    if(pad)
    {
      fill(1);
      text("Pad", x, y, wwidth, hheight);
    }
  }
  
  void on()
  {
    current = lit;
  }
  void off()
  {
    current = unlit;
  }
  void toggle()
  {
    if(current == this.lit)
    {
      current = this.unlit;
      OM.noteOff(id);
    }
    else
    {
      OM.noteOn(id, 127);
      current = this.lit;
    }
  }
  Point getCenterPT()
  {
    return (new Point(x + (wwidth/2), y + (hheight/2)));
  }
  int getX(){ return x;}
  int getY(){ return y;}
  int getW(){ return wwidth;}
  int getH(){ return hheight;}
  OutputModule getOutputMod(){ return OM;}
  int getTotalContained(){return 1;}
}
/*
class InsetPad extends InsetButton
{
  InsetPad(OutputModule iom, int iid, int ix, int iy, int iwid, int ihi)
  {
    //super.InsetButton(iom, iid, ix, iy, iwid, ihi);
  }
  
}
*/
