//+------------------------------------------------------------------+
//|                                         Panel_Main_Events.mqh    |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _PANEL_MAIN_EVENTS_MQH_
#define _PANEL_MAIN_EVENTS_MQH_
#property strict

#include "Panel_Main_Shared.mqh"
#include "../Events/Handlers/Handler_Trading.mqh"

// Implementation of Main Panel Event handling

//+------------------------------------------------------------------+
//| EVENT NAVIGATION                                                    |
//+------------------------------------------------------------------+
bool PanelMain_OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   // 1. DRAG LOGIC
   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int mouseX = (int)lparam;
      int mouseY = (int)dparam;
      int buttons = (int)sparam;
      
      if((buttons & 1) == 1)
      {
         if(g_PanelMain.X == -1)
         {
            int cw = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
            int ch = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
            g_PanelMain.X = (cw / 2) - (g_PanelMain.Width / 2);
            g_PanelMain.Y = (ch / 2) - (200);
         }
            
         if(HandlePanelDrag(g_PanelMain.IsDragging, g_PanelMain.X, g_PanelMain.Y, g_PanelMain.DragOffsetX, g_PanelMain.DragOffsetY, mouseX, mouseY, g_PanelMain.Width, 200, "Bg"))
         {
            UpdateUIMode();
            return true; 
         }
      }
      else
      {
         if(g_PanelMain.IsDragging)
         {
            long h = ObjectGetInteger(0, PREFIX + "Bg", OBJPROP_YSIZE);
            if(h < 50) h = 200;
            
            ApplyPanelSafety(g_PanelMain.X, g_PanelMain.Y, g_PanelMain.Width, (int)h);
            g_PanelMain.IsDragging = false;
            UpdateUIMode();
            SaveConfigToFile();
            return true;
         }
      }
   }
   
   // 2. CLICK EVENTS
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
       if(sparam == PREFIX + "Label_RiskPerc")
       {
          RiskMode++;
          if(RiskMode > 2) RiskMode = 0;
          
          ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, "0");
          
          UpdateUIMode();
          UpdateCalculatedLot();
          EffectButton(sparam);
          return true;
       }
       
       // 2.2 TRADING EVENTS (Route to Handler_Trading)
       if(Handle_Trading_Events(sparam))
          return true;
   }
   
   // 3. EDIT EVENTS (Validation)
   if(id == CHARTEVENT_OBJECT_ENDEDIT)
   {
       if(StringFind(sparam, PREFIX + "Edit_") >= 0)
       {
            string currentText = ObjectGetString(0, sparam, OBJPROP_TEXT);
            StringTrimLeft(currentText); StringTrimRight(currentText);
            
            if(currentText == "")
            {
               if(sparam == PREFIX + "Edit_SL" || sparam == PREFIX + "Edit_TP" || sparam == PREFIX + "Edit_Risk")
                  ObjectSetString(0, sparam, OBJPROP_TEXT, "0");
            }
            
            UpdateChartLines(); 
            AutoSwitchOrderType();
            UpdateCalculatedLot();
            return true; 
       }
   }
   
   // 4. DRAG LINES
   if(id == CHARTEVENT_OBJECT_DRAG)
   {
        if(sparam == PREFIX + "Line_SL" || sparam == PREFIX + "Line_TP" || sparam == PREFIX + "Line_Price")
        {
           string editName = "Edit_SL";
           if(sparam == PREFIX + "Line_TP") editName = "Edit_TP";
           if(sparam == PREFIX + "Line_Price") editName = "Edit_Price";
           
           double price = ObjectGetDouble(0, sparam, OBJPROP_PRICE1);
           ObjectSetString(0, PREFIX + editName, OBJPROP_TEXT, DoubleToString(price, _Digits));
           
           AutoSwitchOrderType();
           UpdateCalculatedLot();
           return true;
        }
   }
   
   // 5. KEYDOWN
   if(id == CHARTEVENT_KEYDOWN)
   {
        bool changed = false;
        if(lparam == 55) { CurrentTypeIndex = 0; CurrentDirection = 0; changed = true; } // 7
        if(lparam == 56) { CurrentTypeIndex = 0; CurrentDirection = 1; changed = true; } // 8
        
        if(lparam == 57) // 9
        {
           changed = true;
           if(CurrentDirection == 0) {
              if(CurrentTypeIndex == 0) CurrentTypeIndex = 1;
              else if(CurrentTypeIndex == 1) CurrentTypeIndex = 3;
              else CurrentTypeIndex = 0;
           } else {
              if(CurrentTypeIndex == 0) CurrentTypeIndex = 2;
              else if(CurrentTypeIndex == 2) CurrentTypeIndex = 4;
              else CurrentTypeIndex = 0;
           }
        }
        
        if(changed)
        {
           UpdateUIMode();
           ApplyDefaultTradeValues();
           UpdateCalculatedLot();
           ChartRedraw();
           return true;
        }
   }

   return false;
}
#endif
