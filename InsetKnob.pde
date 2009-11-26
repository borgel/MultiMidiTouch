//Draws a sweet knob, with a line indicating position. iPerc is percent (rolls over)
class InsetKnob implements Tangible
{
  int wwidth = 25, hheight = 25, x, y, id, lastClick = -1;
  float percent = 0;  //from 0 to 2PI
  float offset = PI/2;
  color unlit, lit;
  boolean updated = false, endless, relative;
  OutputModule OM;
  
  InsetKnob(OutputModule iom, int iid, int iX, int iY, int iWid, int iHigh, boolean iend, boolean irel)
  {
    x = iX;
    y = iY;
    
    OM = iom;
    id = iid;
    
    endless = iend;
    relative = irel;
    
    wwidth = iWid;
    hheight = iHigh;
    
    lit = color(250, 250, 250);
    unlit = color(100, 100, 100);
  }
  void paint()
  {
    paint(x, y, wwidth, hheight);
  }
  
  void paint(int iX, int iY, int iW, int iH)
  {
    //int iX, int iY, int iWidth, int iHeight, int iPerc
    //Draw 2 ellipses, and a line (or pie slice?) indicating position
    
    //reduces to within
    //while(tperc > 100) tperc /=10;
    
    strokeWeight(2);
    fill(unlit);
    ellipse(iX, iY, iW, iH);
    
    offset = 0;
    strokeWeight(5);
    fill(lit);
    arc(iX, iY, iW, iH, 0.0 + offset, percent*(2*PI) + offset);
    
    strokeWeight(0);
    noStroke();
    fill(unlit);
    ellipse(iX+(iW/2.5), iY+(iH/2.5), iW/4, iH/4);
    stroke(2);
  }
  
  boolean click(int uid, int iX, int iY, char tclick)
  {
    if(tclick == 'c')
    {
      if(checkClick(uid, iX, iY))
      {
        updated = true;
        lastClick = uid;
        useClick(iX, iY);
        return true;
      }
      else
        return false;
    }
    else if(tclick == 'd')  //d for dragged
    {
      return updateClick(uid, iX, iY);
    }
    else
    {
      unClick();
      lastClick = -1;
      return true;
    }
  }
  //Turns it off if its being called
  void unClick()
  {
    updated = false;
  }
  boolean updateClick(int uid, int iX, int iY)
  {
    boolean cc = checkClick(uid, iX, iY);

    if(cc && !updated)
    {
      //initial click too
      //useClick();
      updated = true;
      lastClick = uid;
      return true;
    }
    else if(!cc && updated)
    {
      updated = false;
      return true;
    }
    else if(cc && updated)  //When dragged, and only on this knob
    {
      //useClick's body was here
      useClick(iX, iY);
    }
    return false;
  }
  void useClick(int iX, int iY)
  {
    //--------------------------------
      //we actually want delta too
      //--------------------------------
      
      float ty = (y + hheight/2) - iY;//dist(0, iY+hheight/2, 0, y+hheight/2);
      float tx = (x + wwidth/2) - iX;//dist(iX+wwidth/2, 0, x+wwidth/2, 0);
      
      float val = atan2(ty, tx) + PI;//y, then x, gives += pi

      //println((val)+", ");
      
      float oPerc = percent;
      float nPerc = (val / (2*PI));
      float tPerc = nPerc;
      
      /*
      //prevent rollover?
      if(abs(oPerc - nPerc) > 350)
        percent = oPerc;
      else
        percent = nPerc;
      //percent = ;  //offset by 90 degrees
      */
      println("rel: "+relative+" endl: "+endless);
      if(relative)
      {
        tPerc = nPerc - oPerc;
        println("/_: "+tPerc);
        //tPerc = tPerc * PI;
        
        percent += tPerc;
        if(!endless)  //not endless, keep below 100% (2PI)...
        {
          if(percent < 0 || percent > 2*PI)
            percent -= tPerc;
        }
        println(percent+"% +- "+tPerc);
      }
      else  //not reletive, its abs, so nothing to do...
      {
        println("Not Rel");
        percent = nPerc;
      }
      
      OM.sendCC(id, (int)(127 * percent));  //note on instead? probably not...
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
    else
      return false;
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
