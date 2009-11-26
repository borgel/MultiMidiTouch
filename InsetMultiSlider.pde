/*
Multiple sliders composed into one package. Composed of multiple InsetSliders
*/
class InsetMultiSlider implements Tangible
{
  boolean vert;
  int x, y, wwidth, hheight, num;
  int sXLen, sYLen;
  color back;
  
  ArrayList sliders;
  
  InsetMultiSlider(OutputModule iom, int iid, int iX, int iY, int iW, int iH, boolean ifader, boolean iVert, int iNum)
  {
    int tx, ty, tw, th;
    
    vert = iVert;
    num = iNum;
    x = iX;
    y = iY;
    wwidth = iW;
    hheight = iH;
    
    back = color(60, 254, 254);  //hsv?
    
    //Now add in all the sliders
    sliders = new ArrayList();
    //Calculate their stats
    if(vert)
    {
      sXLen = wwidth / num;
      sYLen = hheight;
      
      tx = sXLen;
      ty = 0;
    }
    else
    {
      sXLen = wwidth;
      sYLen = hheight / num;
      
      tx = 0;
      ty = sYLen;
    }
    //make them
    for(int i = 0; i < iNum; i++)
    {
      sliders.add(new InsetSlider(iom, iid, x + i*tx, y + i*ty, sXLen, sYLen, ifader, vert));  //the false is 'is fader'
      iid++;
    }
  }
  boolean click(int uid, int iX, int iY, char ctype)
  {
    for(int i = 0; i < num; i++)
    {
      InsetSlider s = (InsetSlider)sliders.get(i);
      s.click(uid, iX, iY, ctype);
    }
    return true;
  }
  void paint()
  {
    paint(x, y, wwidth, hheight);
  }
  void paint(int iX, int iY, int iW, int iH)
  {
    /*
    strokeWeight(5);
    fill(back);
    rect(x, y, wwidth, hheight);
    */
    for(int i = 0; i < num; i++)
    {
      InsetSlider s = (InsetSlider)sliders.get(i);
      s.paint();
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
  int getTotalContained(){return sliders.size();}
}
