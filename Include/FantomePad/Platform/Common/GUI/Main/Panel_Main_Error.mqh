//+------------------------------------------------------------------+
//|                                           Panel_Main_Error.mqh   |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _PANEL_MAIN_ERROR_MQH_
#define _PANEL_MAIN_ERROR_MQH_
#property strict

#include "Panel_Main_Shared.mqh"

// Implementation of UI Validation Errors

//+------------------------------------------------------------------+
//| SHOW VALIDATION ERROR MESSAGE                                    |
//+------------------------------------------------------------------+
void ShowValidationError(string message)
{
   g_ValidationErrorMsg = message;
   g_ValidationErrorVisible = true;
   
   int panelX = g_PanelMain.X;
   int panelY = g_PanelMain.Y;
   
   long panelH = ObjectGetInteger(0, PREFIX + "Bg", OBJPROP_YSIZE);
   if(panelH < 50) panelH = 300;
   
   int errorX = panelX;
   int errorY = (int)(panelY + panelH + 10);
   int errorW = g_PanelMain.Width;
   int errorH = 45;
   
   string bgName = PREFIX + "ValErr_Bg";
   if(ObjectFind(0, bgName) < 0) ObjectCreate(0, bgName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bgName, OBJPROP_XDISTANCE, errorX);
   ObjectSetInteger(0, bgName, OBJPROP_YDISTANCE, errorY);
   ObjectSetInteger(0, bgName, OBJPROP_XSIZE, errorW);
   ObjectSetInteger(0, bgName, OBJPROP_YSIZE, errorH);
   ObjectSetInteger(0, bgName, OBJPROP_BGCOLOR, C'180,45,50');
   ObjectSetInteger(0, bgName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bgName, OBJPROP_BORDER_COLOR, C'220,60,60');
   ObjectSetInteger(0, bgName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bgName, OBJPROP_BACK, false);
   ObjectSetInteger(0, bgName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bgName, OBJPROP_ZORDER, 100);
   
   string txtName = PREFIX + "ValErr_Txt";
   if(ObjectFind(0, txtName) < 0) ObjectCreate(0, txtName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, txtName, OBJPROP_XDISTANCE, errorX + 15);
   ObjectSetInteger(0, txtName, OBJPROP_YDISTANCE, errorY + 14);
   ObjectSetString(0, txtName, OBJPROP_TEXT, message);
   ObjectSetString(0, txtName, OBJPROP_FONT, "Trebuchet MS Bold");
   ObjectSetInteger(0, txtName, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, txtName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, txtName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, txtName, OBJPROP_BACK, false);
   ObjectSetInteger(0, txtName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, txtName, OBJPROP_ZORDER, 101);
   
   string closeName = PREFIX + "ValErr_Close";
   if(ObjectFind(0, closeName) < 0) ObjectCreate(0, closeName, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, closeName, OBJPROP_XDISTANCE, errorX + errorW - 30);
   ObjectSetInteger(0, closeName, OBJPROP_YDISTANCE, errorY + 8);
   ObjectSetInteger(0, closeName, OBJPROP_XSIZE, 22);
   ObjectSetInteger(0, closeName, OBJPROP_YSIZE, 22);
   ObjectSetString(0, closeName, OBJPROP_TEXT, "X");
   ObjectSetString(0, closeName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, closeName, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, closeName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, closeName, OBJPROP_BGCOLOR, C'150,35,40');
   ObjectSetInteger(0, closeName, OBJPROP_BORDER_COLOR, C'150,35,40');
   ObjectSetInteger(0, closeName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, closeName, OBJPROP_BACK, false);
   ObjectSetInteger(0, closeName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, closeName, OBJPROP_ZORDER, 102);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| HIDE VALIDATION ERROR MESSAGE                                    |
//+------------------------------------------------------------------+
void HideValidationError()
{
   g_ValidationErrorMsg = "";
   g_ValidationErrorVisible = false;
   
   string bgName = PREFIX + "ValErr_Bg";
   string txtName = PREFIX + "ValErr_Txt";
   string closeName = PREFIX + "ValErr_Close";
   
   if(ObjectFind(0, bgName) >= 0) ObjectDelete(0, bgName);
   if(ObjectFind(0, txtName) >= 0) ObjectDelete(0, txtName);
   if(ObjectFind(0, closeName) >= 0) ObjectDelete(0, closeName);
   
   ChartRedraw();
}
#endif
