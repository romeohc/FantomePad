//+------------------------------------------------------------------+
//|                                       Panel_Positions_Error.mqh  |
//|                                           FantomePad Project     |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| SHOW POSITION VALIDATION ERROR MESSAGE                           |
//+------------------------------------------------------------------+
// Displays an error message in a red cell below the Position Manager panel
// with white text and a close button (X) in the top right corner.
//+------------------------------------------------------------------+
//| SHOW POSITION VALIDATION ERROR MESSAGE                           |
//+------------------------------------------------------------------+
// Displays an error message in a red cell below the Position Manager panel
// with white text and a close button (X) in the top right corner.
void ShowPosValidationError(string message)
{
   g_PosValidationErrorVisible = true;
   UpdatePosValidationErrorPosition(message);
}

//+------------------------------------------------------------------+
//| UPDATE POSITION VALIDATION ERROR POSITION                        |
//+------------------------------------------------------------------+
// Keeps the error message synchronized with the position panel position
void UpdatePosValidationErrorPosition(string message = "")
{
   if(!g_PosValidationErrorVisible) return;

   // Calculate position (below the positions panel)
   int panelX = (int)g_PanelPositions.X;
   int panelY = (int)g_PanelPositions.Y;
   
   // Get actual panel height
   long panelH = ObjectGetInteger(0, PREFIX + "Pos_Bg", OBJPROP_YSIZE);
   if(panelH < 50) panelH = 400; // Fallback
   
   int errorX = panelX;
   int errorY = (int)(panelY + panelH + 10); // 10px gap below panel
   int errorW = 280; // Same width as Position Panel
   int errorH = 45; // Height of error message box
   
   // 1. Background (Red)
   string bgName = PREFIX + "PosValErr_Bg";
   if(ObjectFind(0, bgName) < 0) ObjectCreate(0, bgName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bgName, OBJPROP_XDISTANCE, errorX);
   ObjectSetInteger(0, bgName, OBJPROP_YDISTANCE, errorY);
   ObjectSetInteger(0, bgName, OBJPROP_XSIZE, errorW);
   ObjectSetInteger(0, bgName, OBJPROP_YSIZE, errorH);
   ObjectSetInteger(0, bgName, OBJPROP_BGCOLOR, C'180,45,50'); // Dark Red
   ObjectSetInteger(0, bgName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bgName, OBJPROP_BORDER_COLOR, C'220,60,60'); // Lighter red border
   ObjectSetInteger(0, bgName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bgName, OBJPROP_BACK, false);
   ObjectSetInteger(0, bgName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bgName, OBJPROP_ZORDER, 100);
   
   // 2. Error Text (White)
   string txtName = PREFIX + "PosValErr_Txt";
   if(ObjectFind(0, txtName) < 0) ObjectCreate(0, txtName, OBJ_LABEL, 0, 0, 0);
   
   // Only update text if a new message is provided
   if(message != "") ObjectSetString(0, txtName, OBJPROP_TEXT, message);
   
   ObjectSetInteger(0, txtName, OBJPROP_XDISTANCE, errorX + 15);
   ObjectSetInteger(0, txtName, OBJPROP_YDISTANCE, errorY + 14);
   ObjectSetString(0, txtName, OBJPROP_FONT, "Trebuchet MS Bold");
   ObjectSetInteger(0, txtName, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, txtName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, txtName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, txtName, OBJPROP_BACK, false);
   ObjectSetInteger(0, txtName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, txtName, OBJPROP_ZORDER, 101);
   
   // 3. Close Button (X) in top right corner
   string closeName = PREFIX + "PosValErr_Close";
   if(ObjectFind(0, closeName) < 0) ObjectCreate(0, closeName, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, closeName, OBJPROP_XDISTANCE, errorX + errorW - 30);
   ObjectSetInteger(0, closeName, OBJPROP_YDISTANCE, errorY + 8);
   ObjectSetInteger(0, closeName, OBJPROP_XSIZE, 22);
   ObjectSetInteger(0, closeName, OBJPROP_YSIZE, 22);
   ObjectSetString(0, closeName, OBJPROP_TEXT, "X");
   ObjectSetString(0, closeName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, closeName, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, closeName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, closeName, OBJPROP_BGCOLOR, C'150,35,40'); // Darker red for button
   ObjectSetInteger(0, closeName, OBJPROP_BORDER_COLOR, C'150,35,40');
   ObjectSetInteger(0, closeName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, closeName, OBJPROP_BACK, false);
   ObjectSetInteger(0, closeName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, closeName, OBJPROP_ZORDER, 102);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| HIDE POSITION VALIDATION ERROR MESSAGE                           |
//+------------------------------------------------------------------+
// Closes and removes the position validation error message display
void HidePosValidationError()
{
   g_PosValidationErrorVisible = false;

   // Delete all error message objects
   string bgName = PREFIX + "PosValErr_Bg";
   string txtName = PREFIX + "PosValErr_Txt";
   string closeName = PREFIX + "PosValErr_Close";
   
   if(ObjectFind(0, bgName) >= 0) ObjectDelete(0, bgName);
   if(ObjectFind(0, txtName) >= 0) ObjectDelete(0, txtName);
   if(ObjectFind(0, closeName) >= 0) ObjectDelete(0, closeName);
   
   ChartRedraw();
}
