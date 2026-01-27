//+------------------------------------------------------------------+
//|                                              GUI_Master.mqh      |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

// Includes
#include "Components/Components.mqh"
#include "../Trade/Trade.mqh"       // Needs access to AutoSwitchOrderType
#include "Panel_Main.mqh"
#include "Settings/Panel_Settings.mqh"
#include "Account/Panel_Account.mqh"
#include "Panel_Manager.mqh"
#include "Panel_Positions.mqh"
#include "History/Panel_History.mqh"

// --- FORWARD DECLARATIONS REMOVED (Defined in Includes or Locals) ---

//+------------------------------------------------------------------+
//| INITIALISATION GUI GLOBALE                                       |
//+------------------------------------------------------------------+
void GUI_OnInit()
{
   if(GlobalVariableCheck("FantomePad_LastSelectedTicket"))
   {
      SelectedPositionTicket = (int)GlobalVariableGet("FantomePad_LastSelectedTicket");
      GlobalVariableDel("FantomePad_LastSelectedTicket");
      g_PanelPositions.IsVisible = true;
      
      // --- INSTANT LINES UPDATE (FIXES LATENCY ON SYMBOL CHANGE) ---
      UpdateOpenOrderLines();
   }

   CreatePanel();
   CreateAccountPanel();
   CreateManagerPanel(); 
   CreatePositionsPanel();
   CreateHistoryPanel();
   
   // Apply Loaded State
   CreatePositionsPanel();
   CreateHistoryPanel();
   
   // Apply Loaded State
   if(g_PanelMain.IsVisible) 
   {
      UpdateUIMode();
      ApplyDefaultTradeValues(); // Force update defaults on Init (Symbol change)
   }
   else ToggleMainPanel(false);
   
   if(g_PanelPositions.IsVisible) TogglePositionsPanel(true);
   else TogglePositionsPanel(false);
   
   if(g_PanelAccount.IsVisible) ToggleAccountPanel(true);
   else ToggleAccountPanel(false);
   
   if(g_PanelHistory.IsVisible) ToggleHistoryPanel(true);
   else ToggleHistoryPanel(false);
   
   if(g_PanelSettings.IsVisible) OpenSettings();
}

//+------------------------------------------------------------------+
//| TOAST NOTIFICATION SYSTEM (REMOVED)                              |
//+------------------------------------------------------------------+
void UpdateToastNotification() 
{
   // Logic removed as requested
   string bgName = PREFIX + "Toast_Bg";
   string txtName = PREFIX + "Toast_Txt";
   string closeName = PREFIX + "Toast_BtnClose";
   
   if(ObjectFind(0, bgName) >= 0) ObjectDelete(0, bgName);
   if(ObjectFind(0, txtName) >= 0) ObjectDelete(0, txtName);
   if(ObjectFind(0, closeName) >= 0) ObjectDelete(0, closeName);
}

//+------------------------------------------------------------------+
//| EVENT TICK (MISE A JOUR CONTINUE)                                |
//+------------------------------------------------------------------+
void GUI_OnTick()
{
   // Throttle UI updates to save CPU (500ms)
   static uint lastUpdate = 0;
   if(GetTickCount() - lastUpdate < 500) return; 
   lastUpdate = GetTickCount();

   UpdateAccountPanel();
   UpdatePositionsValues();
   // UpdateToastNotification(); // Removed 
   // Warning update moved to Timer for responsiveness
}

//+------------------------------------------------------------------+
//| EVENT TIMER (HIGH FREQUENCY UPDATE)                              |
//+------------------------------------------------------------------+
void GUI_OnTimer()
{
   UpdateAutoTradingWarning();
}



//+------------------------------------------------------------------+
//| HELPER: RETRIEVE ORIGINAL LOT SIZE (TRACE HISTORY)               |
//+------------------------------------------------------------------+
double GetOriginalLotSize(int ticket)
{
   if(!OrderSelect(ticket, SELECT_BY_TICKET)) return 0.0;
   
   double totalLots = OrderLots();
   string comment = OrderComment();
   
   // Loop back through history to find parents
   int safety = 0;
   while(StringFind(comment, "from #") >= 0 && safety < 50)
   {
      int pos = StringFind(comment, "from #");
      string sub = StringSubstr(comment, pos + 6);
      int prevTicket = (int)StringToInteger(sub);
      
      if(OrderSelect(prevTicket, SELECT_BY_TICKET, MODE_HISTORY))
      {
         totalLots += OrderLots(); // Add the closed amount
         comment = OrderComment();
      }
      else break;
      
      safety++;
   }
   
   return totalLots;
}

//+------------------------------------------------------------------+
//| HELPER: REFRESH ALL PANELS                                       |
//+------------------------------------------------------------------+
void RefreshAllPanels()
{
    CreatePanel(); 
    if(g_PanelMain.IsVisible) UpdateUIMode();
    else ToggleMainPanel(false);
    
    CreateAccountPanel(); 
    if(!g_PanelAccount.IsVisible) ToggleAccountPanel(false);
    
    CreateManagerPanel();
    CreatePositionsPanel();
    CreateHistoryPanel();
    
    if(g_PanelSettings.IsVisible) OpenSettings();
}

//+------------------------------------------------------------------+
//| HELPER: APPLY COLOR CHANGE                                       |
//+------------------------------------------------------------------+
void ApplyColorChange(color pickedCol)
{
    if(g_ColorPickerTarget != "")
    {
       ObjectSetInteger(0, g_ColorPickerTarget, OBJPROP_BGCOLOR, pickedCol);
       ObjectSetInteger(0, g_ColorPickerTarget, OBJPROP_BORDER_COLOR, pickedCol);
       
       if(StringFind(g_ColorPickerTarget, "_Bg") > 0)          g_ColorBg = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_Head") > 0)        g_ColorHeader = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_Input") > 0)       g_ColorInput = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_Txt") > 0)         g_ColorText = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_Green") > 0)       g_ColorGreen = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_Red") > 0)         g_ColorRed = (color)pickedCol;
       
       if(StringFind(g_ColorPickerTarget, "_ChrtBg") > 0) {
          g_ColorChartBg = (color)pickedCol;
          ChartSetInteger(0, CHART_COLOR_BACKGROUND, g_ColorChartBg);
       }
       if(StringFind(g_ColorPickerTarget, "_ChrtFg") > 0) {
           g_ColorChartFg = (color)pickedCol;
           ChartSetInteger(0, CHART_COLOR_FOREGROUND, g_ColorChartFg);
       }
       
       if(StringFind(g_ColorPickerTarget, "_EntLine") > 0)     g_ColorEntryLine = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_SLLine") > 0)      g_ColorSLLine = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_TPLine") > 0)      g_ColorTPLine = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_BtnVal") > 0)      g_ColorBtnValid = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_BtnInv") > 0)      g_ColorBtnInvalid = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_BtnAct") > 0)      g_ColorBtnActive  = (color)pickedCol;
       
       if(StringFind(g_ColorPickerTarget, "_CUp") > 0) {
          g_ColorCandleUp = (color)pickedCol;
          ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, g_ColorCandleUp);
          ChartSetInteger(0, CHART_COLOR_CHART_UP, g_ColorCandleUp);
       }
       if(StringFind(g_ColorPickerTarget, "_CDown") > 0) {
          g_ColorCandleDown = (color)pickedCol;
          ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, g_ColorCandleDown);
          ChartSetInteger(0, CHART_COLOR_CHART_DOWN, g_ColorCandleDown);
       }
       if(StringFind(g_ColorPickerTarget, "_LNorm") > 0)       g_ColorListNormal = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_LHov") > 0)        g_ColorListHover = (color)pickedCol;
       
       SaveConfigToFile();
       RefreshAllPanels();
    }
}

//+------------------------------------------------------------------+
//| EVENT HANDLERS INCLUDES                                          |
//+------------------------------------------------------------------+
#include "Events/GUI_Event_Resize.mqh"
#include "Events/GUI_Event_Click.mqh"
#include "Events/GUI_Event_Drag.mqh"
#include "Events/GUI_Event_MouseMove.mqh"
#include "Events/GUI_Event_Wheel.mqh"
#include "Events/GUI_Event_ObjectClick.mqh"
#include "Events/GUI_Event_Edit.mqh"
#include "Events/GUI_Event_Key.mqh"

//+------------------------------------------------------------------+
//| EVENT DISPATCHER                                                 |
//+------------------------------------------------------------------+
void GUI_OnChartEvent(const int id,
                      const long &lparam,
                      const double &dparam,
                      const string &sparam)
{
   // 1. CHART RESIZE
   if(id == CHARTEVENT_CHART_CHANGE)
   {
      OnEvent_Resize();
   }
   
   // 2. CHART CLICK (Background)
   if(id == CHARTEVENT_CLICK)
   {
      OnEvent_Click();
   }
   
   // 3. MOUSE MOVE
   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      OnEvent_MouseMove((int)lparam, (int)dparam, (int)sparam);
   }
   
   // 4. MOUSE WHEEL
   if(id == CHARTEVENT_MOUSE_WHEEL)
   {
      OnEvent_Wheel((int)dparam);
   }

   // 5. OBJECT CLICK
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
       OnEvent_ObjectClick(sparam);
   }
   
   // 6. OBJECT END EDIT
   if(id == CHARTEVENT_OBJECT_ENDEDIT)
   {
       OnEvent_EndEdit(sparam);
   }
   
   // 7. OBJECT DRAG
   if(id == CHARTEVENT_OBJECT_DRAG)
   {
       OnEvent_ObjectDrag(sparam);
   }
   
   // 8. KEY DOWN
   if(id == CHARTEVENT_KEYDOWN)
   {
       OnEvent_Key(lparam);
   }
}
