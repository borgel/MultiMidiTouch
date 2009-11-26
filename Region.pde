/*
A region that holds other controls
 */

class Region
{
  ArrayList contained;
  int id, x, y, wwidth, hheight, fx, fy;
  
  //Region(int iid, int iX, int iY, int fX, int fY, Tangible[] inObs)
  Region(int iid, Tangible[] inObs)  //defines its x and y based on the things inside it
  {
    if(inObs != null)
      contained = new ArrayList(Arrays.asList(inObs));
    else
      contained = new ArrayList();
      
    id = iid;
    reSize();
    //println(">>Region "+id+" has "+contained.size());
  }
  void add(Tangible t)
  {
    contained.add(t);
    reSize();
  }
  void reSize()
  {
    int iX = width, iY = height, fX = 0, fY = 0;
    for(int i = 0; i < contained.size(); i ++)
    {
      Tangible t = (Tangible)contained.get(i);
      if(t != null)
      {
        //These should set the bounds of the region to the bounds of
        //the things inside it
        int tix = t.getX();
        int tiy = t.getY();
        int tfx = tix+t.getW();
        int tfy = tiy+t.getH();
        
        if(tix < iX) iX = tix;
        if(tiy < iY) iY = tiy;
        if(tfx > fX) fX = tfx;
        if(tfy > fY) fY = tfy;
      }
    }
    x = iX;
    y = iY;
    fx = fX;
    fy = fY;
    
    wwidth = fX-iX;
    hheight = fY-iY;
  }
  //Determines if this region was clicked
  //Important to make this entire thing faster
  boolean inRegion(int iX, int iY)
  {
    if(iX > x && iX < (x + wwidth))
    {
      if(iY > y && iY < (y + hheight))
        return true;
      else
        return false;
    }
    else
      return false;
  }
  //Internal click. Not boolean cause that would be meaningless...
  void click(int uid, int iX, int iY, char ctype)
  {
    if(contained != null)
    {
      //go over all contained regions and paint
      for(int i = 0; i < contained.size(); i ++)
      {
        Tangible t = (Tangible)contained.get(i);
        if(t != null)
        {
          t.click(uid, iX, iY, ctype);
        }
      }
    }
  }
  void paint()
  {
    //go over all contained regions and paint
    if(contained != null)
    {
      for(int i = 0; i < contained.size(); i ++)
      {
        Tangible t = (Tangible)contained.get(i);
        if(t != null)
        {
          t.paint(t.getX(), t.getY(), t.getW(), t.getH());
        }
      }
    }
    /*
    //Displays each region as shaded rectangles
    fill(50+id*30);
    rect(x, y, fx-x, fy-y);
    */
  }
  int getTotalContained()
  {
    int total = 0;
    
    for(int i = 0; i < contained.size(); i++)
    {
      Tangible t = (Tangible)(contained.get(i));
      total += t.getTotalContained();
    }
    
    return total;
  }
}
//Contains entire clumps of regions that can be swapped between and drawn
class Layout
{
  ArrayList RegionLists;
  boolean displayed;
  String name;
  Layout(String in)
  {
    name = in;
    displayed = false;
  }
  //Takes in ArrayLists of regions
  void add(ArrayList ir)
  {
    RegionLists.add(ir);
  }
  void paint()
  {
    if(displayed)
    {
      for(int i = 0; i < RegionLists.size(); i++)
      {
        ArrayList a = (ArrayList)RegionLists.get(i);
        for(int j = 0; j < a.size(); j++)
        {
          Region r = (Region)(a.get(j));
          r.paint();
        }
      }
    }
    //else do nothing, its off
  }
}
