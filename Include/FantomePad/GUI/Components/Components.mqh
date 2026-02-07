//+------------------------------------------------------------------+
//|                                                   Components.mqh |
//|                                                FantomePad Project |
//+------------------------------------------------------------------+
#ifndef _COMPONENTS_MQH_
#define _COMPONENTS_MQH_
#property strict

// Relative path to avoid dependency on global include paths
#include "../../Core/Defines.mqh"

// Forward declaration wrapper to prevent "no #import declaration" warnings in MQL4
class CGUI_Master { public: static void RefreshAllPanels(); };
#define RefreshAllPanels CGUI_Master::RefreshAllPanels

//+------------------------------------------------------------------+
//| Helpers Graphiques                                               |
//+------------------------------------------------------------------+
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
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10); 
   ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, objName, OBJPROP_STATE, false);
   ObjectSetInteger(0, objName, OBJPROP_BORDER_COLOR, bg);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
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
   
   if(!exists) ObjectSetString(0, objName, OBJPROP_TEXT, text);
   
   ObjectSetString(0, objName, OBJPROP_FONT, "Trebuchet MS");
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, objName, OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, objName, OBJPROP_BORDER_COLOR, g_ColorInput); 
   ObjectSetInteger(0, objName, OBJPROP_READONLY, readOnly);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
}

void EffectButton(string name)
{
   ObjectSetInteger(0, name, OBJPROP_STATE, true);
   Sleep(100);
   ObjectSetInteger(0, name, OBJPROP_STATE, false);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| GENERIC DRAG HANDLER                                              |
//+------------------------------------------------------------------+
bool HandlePanelDrag(bool &dragging_state, int &pos_x, int &pos_y, int &offset_x, int &offset_y, 
                     int mouse_x, int mouse_y, int panel_w, int panel_h, string background_name = "")
{
   if(!dragging_state)
   {
      int current_height = panel_h;
      if(background_name != "")
      {
          long dynamic_h = ObjectGetInteger(0, PREFIX + background_name, OBJPROP_YSIZE);
          if(dynamic_h > 50) current_height = (int)dynamic_h;
      }
      
      if(mouse_x >= pos_x && mouse_x <= pos_x + panel_w && mouse_y >= pos_y && mouse_y <= pos_y + current_height)
      {
         dragging_state = true;
         offset_x = mouse_x - pos_x;
         offset_y = mouse_y - pos_y;
         ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
         return true;
      }
   }
   else
   {
      pos_x = mouse_x - offset_x;
      pos_y = mouse_y - offset_y;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| GENERIC SCROLL HANDLER (Unit Agnostic)                           |
//+------------------------------------------------------------------+
bool HandleScrollDrag(bool &scroll_dragging, int &scroll_anchor_y, int &scroll_current_y, 
                      int mouse_x, int mouse_y, string thumb_name, int track_h, int max_scroll_val)
{
    if(!scroll_dragging)
    {
         long tx = ObjectGetInteger(0, PREFIX + thumb_name, OBJPROP_XDISTANCE);
         long ty = ObjectGetInteger(0, PREFIX + thumb_name, OBJPROP_YDISTANCE);
         long tw = ObjectGetInteger(0, PREFIX + thumb_name, OBJPROP_XSIZE);
         long th = ObjectGetInteger(0, PREFIX + thumb_name, OBJPROP_YSIZE);
         
         if(mouse_x >= tx - 5 && mouse_x <= tx + tw + 5 && mouse_y >= ty && mouse_y <= ty + th)
         {
             scroll_dragging = true;
             scroll_anchor_y = mouse_y;
             ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
             return true; 
         }
    }
    else
    {
         int delta_y = mouse_y - scroll_anchor_y;
         if(delta_y != 0)
         {
             long thumb_h = ObjectGetInteger(0, PREFIX + thumb_name, OBJPROP_YSIZE);
             int track_avail = (int)(track_h - thumb_h);
             
             if(track_avail > 0)
             {
                 double move_per = (double)delta_y / (double)track_avail;
                 int offset_delta = (int)(move_per * max_scroll_val);
                 
                 if(MathAbs(offset_delta) >= 1)
                 {
                     scroll_current_y += offset_delta;
                     if(scroll_current_y < 0) scroll_current_y = 0;
                     if(scroll_current_y > max_scroll_val) scroll_current_y = max_scroll_val;
                     
                     scroll_anchor_y = mouse_y; 
                     return true; 
                 }
             }
         }
    }
    return false;
}

//+------------------------------------------------------------------+
//| SECURITY: PREVENT WINDOWS FROM GETTING LOST                      |
//+------------------------------------------------------------------+
void ApplyPanelSafety(int &safe_x, int &safe_y, int safe_w, int safe_h)
{
   int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   int margin_px = 40;
   bool is_out = (safe_x + safe_w <= margin_px) || (safe_x >= chart_width - margin_px) || (safe_y + safe_h <= margin_px) || (safe_y >= chart_height - margin_px);
   
   if(is_out)
   {
      safe_x = (chart_width / 2) - (safe_w / 2);
      safe_y = (chart_height / 2) - (safe_h / 2);
      
      if(safe_x < 0) safe_x = 0;
      if(safe_y < 0) safe_y = 0;
   }
}

#endif
