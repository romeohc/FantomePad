//+------------------------------------------------------------------+
//|                                                   Components.mqh |
//|                                                MagicKey Project  |
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
