class InsetPiano implements Tangible
{
  int wwidth, hheight, octaves, x, y, id, lastClick = -1;
  int minorHeight = 2;
  OutputModule OM;
  
  InsetPiano(OutputModule iom, int iid, int iX, int iY, int iWidth, int iHeight, int iOct)
  {
    x = iX;
    y = iY;
    
    OM = iom;
    
    this.wwidth = iWidth;
    this.hheight = iHeight;
    this.octaves = iOct;
  }
  boolean click(int uid, int iX, int iY, char tclick)
  {
    if(isTapped(uid, iX, iY))
      return true;
    return false;
  }
  //Use these to press keys
  boolean isTapped(int uid, int iX, int iY)
  { 
    if(uid == lastClick || lastClick == -1)
    {
      if(iX > this.x && iX < (this.x + this.wwidth))    //finds if the xy is inside the piano
      {
        if(iY > this.y && iY < (this.y + this.hheight))
        {
          println(PressKey(iX, iY));
          return true;
        }
        else
          return false;
      }
      else
      {
        //Maybe not here?
        lastClick = uid;
        return false;
      }
    }
    else
      return false;
  }
  //Return the key that was hit. For MIDI out I think?
  //Assume the input is already validated
  int PressKey(int iX, int iY)
  {
    //println("["+iX+", "+iY+"]");
    //return 1;
    int t = iX - this.x;  //distance across the keyboard, from left
    int kWidth = (int)this.wwidth/(octaves * 7);  //key width
    int o = 0;
    
    for(; t - kWidth > 0; o++)
      t -= kWidth;
    
    return o + 1;  //+1 to start at 0
  }
  void paint()
  {
    paint(x, y, wwidth, hheight);
  }
  void paint(int iiX, int iiY, int iiW, int iiH)
  {
    int iX = x;
    int iY = y;
    if(iX >= 0 || iY >= 0)
    {
      this.x = iX;
      this.y = iY;
      
      //8 keys in an octave
      int kWidth = (int)this.wwidth/(octaves * 7);  //Finds the width per key
      
      //Draw the normal keys
      fill(254);
      strokeWeight(5);
      //Draw the keys
      for(int i = 0; i < octaves * 7; i++)
      {
        rect(iX + (i * kWidth), iY, kWidth, this.hheight);   //x, y, width, height
      }
      
      //Draw those little keys, hardcoded
      int offset = (int)(.5 * kWidth);
      fill(100);
      rect(this.x + offset, this.y, kWidth, (int)this.hheight/minorHeight);
      offset += kWidth;
      rect(this.x + offset, this.y, kWidth, (int)this.hheight/minorHeight);
      
      offset += (kWidth * 2);
      rect(this.x + offset, this.y, kWidth, (int)this.hheight/minorHeight);
      offset += kWidth;
      rect(this.x + offset, this.y, kWidth, (int)this.hheight/minorHeight);
      offset += kWidth;
      rect(this.x + offset, this.y, kWidth, (int)this.hheight/minorHeight);
    }
    //else, dont draw it
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
  int getTotalContained(){return octaves * 7;}  //total keys
}
