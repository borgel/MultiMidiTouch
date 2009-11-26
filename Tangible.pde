interface Tangible
{
  void paint();  //the dumb one
  void paint(int iX, int iY, int iW, int iH);  //the smart one, for some objects
  
  boolean click(int uid, int iX, int iY, char ctype);  //allows for passage of unclicking and dragging
  //d for dragged, c for clicked, r for released
  
  int getX();
  int getY();
  int getW();
  int getH();
  
  OutputModule getOutputMod();
  
  Point getCenterPT();
  void setOverlayIn(float oIn);  //for the overlay to give input
  
  int getTotalContained();
  
  //been clicked
  //clicked (to perform action)
  
  //paint
  
  //color? accessors for size and position?
}
