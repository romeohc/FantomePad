//+------------------------------------------------------------------+
//|                                              GUI_Master.mqh      |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

// Includes
#include "Components/Components.mqh"
#include "../Core/TradeLogic/TradeCalc.mqh"
#include "../Core/TradeLogic/TradeVisuals.mqh"
#include "../Core/TradeLogic/TradeUIInteraction.mqh"
#include "Main/Panel_Main.mqh"
#include "Settings/Panel_Settings.mqh"
#include "Account/Panel_Account.mqh"
#include "Navigation/Panel_Navigation.mqh"
#include "Positions/Panel_Positions.mqh"
#include "History/Panel_History.mqh"
#include "Auth/Panel_Auth.mqh"
#include "SymbolManager/Panel_SymbolManager.mqh"
// --- FORWARD DECLARATIONS ---

#include "SoftLock.mqh"
#include "ColorManager.mqh"
#include "GUI_Refresh.mqh"

//+------------------------------------------------------------------+
//| INITIALISATION GUI GLOBALE                                       |
//+------------------------------------------------------------------+
void GUI_OnInit()
{
   if(GlobalVariableCheck("FantomePad_LastSelectedTicket"))
   {
      SelectedPositionTicket = (long)GlobalVariableGet("FantomePad_LastSelectedTicket");
      GlobalVariableDel("FantomePad_LastSelectedTicket");
      g_PanelPositions.IsVisible = true;
      
      // --- INSTANT LINES UPDATE (FIXES LATENCY ON SYMBOL CHANGE) ---
      UpdateOpenOrderLines();
   }

   // 1. Initial License Check
   HandleInitialLicenseCheck();

   if(!g_IsLicensed && g_LicenseState != LICENSE_REVOKED)
   {
      CreateAuthUI();
      ShowAuthPanel(true);
      
      // Force hide all standard panels
      ToggleMainPanel(false);
      ToggleAccountPanel(false);
      TogglePositionsPanel(false);
      ToggleHistoryPanel(false);
      
      // Hide navigation
      ObjectsDeleteAll(0, PREFIX + "Nav_");
      
      SyncChartUI(); // Hide UI
      return; 
   }
   else 
   {
      // Ensure auth objects are removed if not in pure Auth mode
      ObjectsDeleteAll(0, PREFIX + "Auth_");
      if(g_LicenseState == LICENSE_OK) ClearSoftLockUI();
      
      ShowAuthPanel(false); // Clean up any auth UI state
      SyncChartUI(); // Restore UI if needed
   }

   // 2. Full UI Refresh
   g_SymbolManagerLoaded = false; // Force re-scan on account change
   g_SymMgr_CurrentCategory = "";
   g_SymMgr_ScrollOffset = 0;
   
   RefreshAllPanels();
   
   // 2. Specific startup logic
   if(g_PanelMain.IsVisible) ApplyDefaultTradeValues();
}

//+------------------------------------------------------------------+
//| EVENT TICK (MISE A JOUR CONTINUE)                                |
//+------------------------------------------------------------------+
void GUI_OnTick()
{   
   if(!g_IsLicensed && g_LicenseState != LICENSE_REVOKED) return; // Guard: Allow REVOKED for position updates
   // Throttle UI updates to save CPU (500ms)
   static uint lastUpdate = 0;
   if(GetTickCount() - lastUpdate < 500) return; 
   lastUpdate = GetTickCount();

   // MT5 FIX: Reset history cache flag so HistorySelect is called fresh each cycle.
   // Without this, newly closed trades won't appear in history/account panels.
   #ifdef __MQL5__
      g_fp_history_loaded = false;
   #endif

   // Only update panels that are SUPPOSED to be visible
   if(g_PanelAccount.IsVisible && g_LicenseState == LICENSE_OK) UpdateAccountPanel();
   UpdatePositionsValues(); // Always update if positions visible
}

//+------------------------------------------------------------------+
//| EVENT TIMER (HIGH FREQUENCY UPDATE)                              |
//+------------------------------------------------------------------+
void GUI_OnTimer()
{
   uint now = GetTickCount();
    HandleLicenseHeartbeat();

    // Deferred re-initialization (avoids recursive GUI_OnInit during timer)
    if(g_NeedsReinit)
    {
        g_NeedsReinit = false;
        GUI_OnInit();
        return;
    }

    if(!g_IsLicensed && g_LicenseState != LICENSE_REVOKED) return; // Guard
   
   // 3. Debounced Save (Every 5 seconds if interaction occurred)
   static uint lastSave = 0;
   if(now - lastSave > 5000)
   {
       lastSave = now;
       // We can check a 'dirty' flag here, or just save every 5s if active
       if(now - g_LastInteractionTime < 6000) SaveConfigToFile(); 
   }

   UpdateAutoTradingWarning();
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
   // --- USER INTERACTION TRACKING ---
   // Any manual event (Mouse, Key, Click) signifies the user is active.
   // We exclude CHART_CHANGE (resize) which is automatic.
   if(id != CHARTEVENT_CHART_CHANGE)
   {
      g_LastInteractionTime = GetTickCount();
   }

   // --- AUTHENTICATION GUARD ---
   if(!g_IsLicensed && g_LicenseState != LICENSE_REVOKED)
   {
      if(id == CHARTEVENT_OBJECT_CLICK && sparam == PREFIX + "Auth_BtnActive")
      {
         OnEvent_ObjectClick(sparam);
      }
      if(id == CHARTEVENT_CHART_CHANGE)
      {
         OnEvent_Resize();
      }
      if(id == CHARTEVENT_OBJECT_ENDEDIT && sparam == PREFIX + "Auth_Input")
      {
         // Update activation code as user types/finishes edit
         g_ActivationCode = ObjectGetString(0, sparam, OBJPROP_TEXT);
      }
      return; // Block all other events if not licensed AND not revoked
   }
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
