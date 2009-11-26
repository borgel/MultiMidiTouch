/*
Draw a vertical slider that can be fingered to increased or decreased
 */
class InsetSlider implements Tangible
{
  int wwidth, hheight, x, y, id, lastClick = -1, hTall = 20;
  float perc;
  boolean vert, fader;
  //int tx, ty, tw, th;
  color back, bar;
  OutputModule OM;

  InsetSlider(OutputModule iom, int iid, int iX, int iY, int iWid, int iHigh, boolean iisFader, boolean iVert)
  {
    x = iX;
    y = iY;
    
    OM = iom;
    id = iid;

    wwidth = iWid;
    hheight = iHigh;

    vert = iVert;
    fader = iisFader;

    back = color(0, 0, 128);
    color(RGB);
    bar = color((int)random(100, 255), (int)random(100, 255), (int)random(100, 255));
    //bar = color(80, 254, 100);  //a random green
    
    //println("["+x+", "+y+"] & w: "+wwidth+" h: "+hheight);
  }
  boolean click(int uid, int iX, int iY, char tclick)
  {
    if(checkClick(uid, iX, iY))
    {
      iX += 0.0;
      iY += 0.0;

      if(vert)
      {
        perc = 1-((float)iY / hheight);
      }
      else
      {
        perc = 1-((float)iX / wwidth);
      }
      //Note stuff here
      OM.sendCC(id, (int)(127 * perc));
      
      if(tclick == 'r')
        lastClick = -1;
      return true;
    }
    return false;
  }
  boolean checkClick(int uid, int iX, int iY)
  {
    if(uid == lastClick || lastClick == -1)
    {
      if(iX > x && iX < (x + wwidth))    //finds if the xy is inside the object
      {
        if(iY > y && iY < (y + hheight))
          return true;
        else
          return false;
      }
      else
      {
        lastClick = uid;
        return false;
      }
    }
    else
      return false;
  }
  void paint()
  {
    paint(x, y, wwidth, hheight);
  }
  void paint(int iX, int iY, int iW, int iH)
  {
    int tW, tH, hOff, wOff, hW = 0, hH = 0;
    if(vert)
    {
      tW = wwidth;
      tH = (int)(hheight * perc);
      hOff = hheight - tH;
      wOff = 0;
      
      hW = wwidth;
      hH = hTall;
    }
    else
    {
      tW =(int)(wwidth * ((1 - perc) + perc/2));
      tH = hheight;
      hOff = 0;
      wOff = tW - wwidth;
      
      hW = hTall;
      hH = hheight;
    }

    //paint the background
    strokeWeight(1);
    fill(back);
    rect(iX, iY, iW, iH);

    //paint the current bar
    strokeWeight(5);
    fill(bar);
    rect(iX + wOff, iY + hOff, tW, tH);
    
    //if 'fader', then draw a handle
    /*
    if(fader)
    {
      fill(100);
      strokeWeight(1);
      rect(iX - hW, iY - hH, hW, hH);
    }
    */
  }
  Point getCenterPT()
  {
    return (new Point(x + (wwidth/2), y + (hheight/2)));
  }
  int getX(){ 
    return x;
  }
  int getY(){ 
    return y;
  }
  int getW(){ 
    return wwidth;
  }
  int getH(){ 
    return hheight;
  }
  OutputModule getOutputMod(){ return OM;}
  int getTotalContained(){return 1;}
}
