//+------------------------------------------------------------------+
//|                                                   Components.mqh |
//|                                                FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

// Helpers Graphiques
void SetObjPosition(string name, int x, int y)
{
   ObjectSetInteger(0, PREFIX + name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, PREFIX + name, OBJPROP_YDISTANCE, y);
}

void SetObjVisible(string name, bool visible)
{
   if(visible) ObjectSetInteger(0, PREFIX + name, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   else        ObjectSetInteger(0, PREFIX + name, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
}

void CreateRect(string name, int x, int y, int w, int h, color bg, int border)
{
   string objName = PREFIX + name;
   if(ObjectFind(0, objName) < 0) ObjectCreate(0, objName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, objName, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, objName, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, objName, OBJPROP_BORDER_TYPE, border);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, bg); 
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
}

void CreateButton(string name, string text, int x, int y, int w, int h, color bg, color txtColor)
{
   string objName = PREFIX + name;
   if(ObjectFind(0, objName) < 0) ObjectCreate(0, objName, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, objName, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, objName, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, txtColor);
   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetString(0, objName, OBJPROP_FONT, "Trebuchet MS");
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10); // Slightly larger
   ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, objName, OBJPROP_STATE, false);
   ObjectSetInteger(0, objName, OBJPROP_BORDER_COLOR, bg);
}

void CreateLabel(string name, string text, int x, int y, int fontsize, color col, string font="Trebuchet MS")
{
   string objName = PREFIX + name;
   if(ObjectFind(0, objName) < 0) ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, col);
   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetString(0, objName, OBJPROP_FONT, font);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, fontsize);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
}

void CreateEdit(string name, string text, int x, int y, int w, int h, bool readOnly = false)
{
   string objName = PREFIX + name;
   bool exists = (ObjectFind(0, objName) >= 0);
   if(!exists) ObjectCreate(0, objName, OBJ_EDIT, 0, 0, 0);
   
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, objName, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, objName, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, g_ColorInput);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, g_ColorText);
   
   // On ne définit le texte que si l'objet vient d'être créé
   // afin de ne pas écraser la saisie de l'utilisateur lors d'un rafraîchissement
   if(!exists) ObjectSetString(0, objName, OBJPROP_TEXT, text);
   
   ObjectSetString(0, objName, OBJPROP_FONT, "Trebuchet MS");
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, objName, OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, objName, OBJPROP_BORDER_COLOR, g_ColorInput); // Flat look
   ObjectSetInteger(0, objName, OBJPROP_READONLY, readOnly);
}

void EffectButton(string name)
{
   ObjectSetInteger(0, name, OBJPROP_STATE, true);
   Sleep(100);
   ObjectSetInteger(0, name, OBJPROP_STATE, false);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| GENERIC DRAG HANDLER                                             |
//+------------------------------------------------------------------+
bool HandlePanelDrag(bool &isDragging, int &panelX, int &panelY, int &dragOffsetX, int &dragOffsetY, 
                     int mouseX, int mouseY, int panelW, int panelH, string bgName = "")
{
   if(!isDragging)
   {
      // Check Hit Test
      // If bgName is provided, we can use it to get dynamic height
      int h = panelH;
      if(bgName != "")
      {
          long dynH = ObjectGetInteger(0, PREFIX + bgName, OBJPROP_YSIZE);
          if(dynH > 50) h = (int)dynH;
      }
      
      if(mouseX >= panelX && mouseX <= panelX + panelW && mouseY >= panelY && mouseY <= panelY + h)
      {
         isDragging = true;
         dragOffsetX = mouseX - panelX;
         dragOffsetY = mouseY - panelY;
         ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
         return true;
      }
   }
   else
   {
      // Update Position
      panelX = mouseX - dragOffsetX;
      panelY = mouseY - dragOffsetY;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| GENERIC SCROLL HANDLER                                           |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| GENERIC SCROLL HANDLER (Unit Agnostic)                           |
//+------------------------------------------------------------------+
bool HandleScrollDrag(bool &isDragging, int &scrollDragY, int &currentScrollY, 
                      int mouseX, int mouseY, string thumbName, int trackHeight, int maxScroll)
{
    if(!isDragging)
    {
         long tx = ObjectGetInteger(0, PREFIX + thumbName, OBJPROP_XDISTANCE);
         long ty = ObjectGetInteger(0, PREFIX + thumbName, OBJPROP_YDISTANCE);
         long tw = ObjectGetInteger(0, PREFIX + thumbName, OBJPROP_XSIZE);
         long th = ObjectGetInteger(0, PREFIX + thumbName, OBJPROP_YSIZE);
         
         if(mouseX >= tx - 5 && mouseX <= tx + tw + 5 && mouseY >= ty && mouseY <= ty + th)
         {
             isDragging = true;
             scrollDragY = mouseY;
             ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
             return true; 
         }
    }
    else
    {
         int deltaY = mouseY - scrollDragY;
         if(deltaY != 0)
         {
             long thumbH = ObjectGetInteger(0, PREFIX + thumbName, OBJPROP_YSIZE);
             int availableTrack = (int)(trackHeight - thumbH);
             
             if(availableTrack > 0)
             {
                 double moveRatio = (double)deltaY / (double)availableTrack;
                 int offsetChange = (int)(moveRatio * maxScroll);
                 
                 if(MathAbs(offsetChange) >= 1)
                 {
                     currentScrollY += offsetChange;
                     if(currentScrollY < 0) currentScrollY = 0;
                     if(currentScrollY > maxScroll) currentScrollY = maxScroll;
                     
                     scrollDragY = mouseY; 
                     return true; 
                 }
             }
         }
    }
    return false;
}
