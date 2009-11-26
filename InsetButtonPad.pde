/*
Composes a pseudomonome (PMonome)

Try to make this compatible with real monome software...?
*/
class InsetButtonPad implements Tangible
{
  InsetButton[][] buttons;
  int numBX, numBY, wwidth, hheight, bWidth, bHeight, x, y;
  boolean pad;
  
  //iNum is the number of buttons
  InsetButtonPad(OutputModule iom, int iid, int iX, int iY, int iWidth, int iHeight, int iNumX, int iNumY, boolean ipad)  //pad or switch
  {
    buttons = new InsetButton[iNumX+1][iNumY+1];
    numBX = iNumX;
    numBY = iNumY;
    
    x = iX;
    y = iY;
    wwidth = iWidth;
    hheight = iHeight;
    pad = ipad;
    
    bWidth = (wwidth/numBX);
    bHeight = (hheight/numBY);
    
    //Fills the array with buttons
    for(int i = 0; i <= numBX; i++)
    {
      for(int j = 0; j <= numBY; j++)
      {
        buttons[i][j] = new InsetButton(iom, iid, x + i*this.bWidth, y + j*this.bHeight,
         this.bWidth, this.bHeight, pad);
        iid++;
      }
    }
  }
  boolean click(int uid, int iX, int iY, char tclick)
  {
    //for through all buttons, calling click on each
    boolean res = false;
    for(int i = 0; i < this.numBX; i++)
    {
      for(int j = 0; j < this.numBY; j++)
      {
        if(buttons[i][j].click(uid, iX, iY, tclick))
          res = true;
      }
    }
    return res;
  }
  void paint()
  {
    paint(x, y, wwidth, hheight);
  }
  void paint(int iX, int iY, int iW, int iH)
  {
    for(int i = 0; i < numBX; i++)
    {
      for(int j = 0; j < numBY; j++)
      {
        buttons[i][j].paint();
      }
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
  int getTotalContained(){return numBY * numBX;}
}
