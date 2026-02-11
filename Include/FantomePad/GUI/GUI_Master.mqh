//+------------------------------------------------------------------+
//|                                              GUI_Master.mqh      |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

// Includes
#include "Components/Components.mqh"
#include "../Trade/Trade.mqh"       // Needs access to AutoSwitchOrderType
#include "Main/Panel_Main.mqh"
#include "Settings/Panel_Settings.mqh"
#include "Account/Panel_Account.mqh"
#include "Navigation/Panel_Navigation.mqh"
#include "Positions/Panel_Positions.mqh"
#include "History/Panel_History.mqh"
#include "Auth/Panel_Auth.mqh"
#include "SymbolManager/Panel_SymbolManager.mqh"
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

   // 1. Initial License Check
   if(g_ActivationCode != "")
   {
      if(CheckLicense(g_ActivationCode)) 
      {
         g_IsLicensed = true;
         g_LicenseState = LICENSE_OK;
      }
      else
      {
         // If license fails or is revoked, check if we have open positions 
         // before forcing the login screen.
         if(OrdersTotal() > 0)
         {
             Print("FantomePad: License invalid but positions open. Entering Soft Lock.");
             g_IsLicensed = false; 
             g_LicenseState = LICENSE_REVOKED;
         }
         else
         {
             g_IsLicensed = false;
             g_LicenseState = LICENSE_NONE;
         }
      }
   }
   else if(OrdersTotal() > 0)
   {
       // Even without a code, if positions are open, we allow management
       g_IsLicensed = false;
       g_LicenseState = LICENSE_REVOKED;
   }

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
   if(!g_IsLicensed && g_LicenseState != LICENSE_REVOKED) return; // Guard: Allow REVOKED for position updates
   // Throttle UI updates to save CPU (500ms)
   static uint lastUpdate = 0;
   if(GetTickCount() - lastUpdate < 500) return; 
   lastUpdate = GetTickCount();

   // Only update panels that are SUPPOSED to be visible
   if(g_PanelAccount.IsVisible && g_LicenseState == LICENSE_OK) UpdateAccountPanel();
   UpdatePositionsValues(); // Always update if positions visible
}

//+------------------------------------------------------------------+
//| EVENT TIMER (HIGH FREQUENCY UPDATE)                              |
//+------------------------------------------------------------------+
void GUI_OnTimer()
{
   // 1. Permanent License Check (Heartbeat) - Premium Logic
   // Rule: Check every 30 min, BUT only if user has been idle for >1 min to ensure zero lag.
   
   static uint lastHeartbeat = 0;
   // Synchronize with Auth success if available
   if(lastHeartbeat == 0 && GlobalVariableCheck("FantomePad_LastHeartbeat"))
   {
      lastHeartbeat = (uint)GlobalVariableGet("FantomePad_LastHeartbeat");
      GlobalVariableDel("FantomePad_LastHeartbeat");
   }
   
   uint now = GetTickCount();
   
   // Check if 30 minutes have passed since last check
   // We allow checking if licensed OR if revoked (to allow recovery)
   if((g_IsLicensed || g_LicenseState == LICENSE_REVOKED) && (now - lastHeartbeat > 1800000 || lastHeartbeat == 0)) 
   {
      // Check if user has been idle for at least 1 minute
      if(now - g_LastInteractionTime > 60000) 
      {
         lastHeartbeat = now;
         
         // Perform check with short timeout (1500ms)
         bool isValid = CheckLicense(g_ActivationCode, 1500);
         
         if(!isValid)
         {
             // Only react if it's a definitive failure (not just internet down)
             if(g_AuthErrorMsg != "" && StringFind(g_AuthErrorMsg, "Serveur injoignable") < 0)
             {
                 Print("FantomePad: License Revoked/Invalidated. Enhancing Security.");
                 g_IsLicensed = false; 
                 g_LicenseState = LICENSE_REVOKED;
                 
                 // Apply Soft Lock Mode immediately
                 ApplySoftLockMode();
             }
         }
         else
         {
             // Recovery: if we were revoked but now valid
             if(g_LicenseState == LICENSE_REVOKED || g_LicenseState == LICENSE_NONE)
             {
                 g_LicenseState = LICENSE_OK;
                 g_IsLicensed = true;
                 ClearSoftLockUI(); // Immediate cleanup
                 RefreshAllPanels(); // Restore UI
             }
         }
      }
   }

   // 2. Soft Lock Persistence & Exit Logic
   if(g_LicenseState == LICENSE_REVOKED)
   {
       // If no open positions remain, force redirect to Auth
       // We use a small safety buffer: check if it's REALLY zero across all symbols
       if(OrdersTotal() == 0)
       {
           Print("FantomePad: No more positions. Redirecting to Auth.");
           g_LicenseState = LICENSE_NONE;
           g_IsLicensed = false;
           GUI_OnInit(); // Redirect to Auth
           return;
       }
       
       // Ensure Soft Lock UI banner is present
       ApplySoftLockMode();
       
       // Force UI state for Soft Lock (Keep Positions visible, hide others) only if changed
       if(!g_PanelPositions.IsVisible) TogglePositionsPanel(true);
       if(g_PanelMain.IsVisible) ToggleMainPanel(false);
       if(g_PanelAccount.IsVisible) ToggleAccountPanel(false);
       if(g_PanelHistory.IsVisible) ToggleHistoryPanel(false);
       if(g_PanelSettings.IsVisible) ToggleSettings(); 
   }

   if(!g_IsLicensed && g_LicenseState != LICENSE_REVOKED) return; // Guard
   
   UpdateAutoTradingWarning();
}

//+------------------------------------------------------------------+
//| HELPER: SOFT LOCK MODE (Security UI)                             |
//+------------------------------------------------------------------+
void ApplySoftLockMode()
{
    // 1. Force hide all non-essential panels and update their State flags
    if(g_PanelMain.IsVisible) { g_PanelMain.IsVisible = false; ToggleMainPanel(false); }
    if(g_PanelAccount.IsVisible) { g_PanelAccount.IsVisible = false; ToggleAccountPanel(false); }
    if(g_PanelHistory.IsVisible) { g_PanelHistory.IsVisible = false; ToggleHistoryPanel(false); }
    
    // Explicit Settings Cleanup (Correcting Prefix from Settings_ to Set_)
    if(g_PanelSettings.IsVisible) 
    {
        ObjectsDeleteAll(0, PREFIX + "Set_"); 
        g_PanelSettings.IsVisible = false;
    }
    
    // 2. Ensure Positions Panel is visible and state is correct
    if(!g_PanelPositions.IsVisible) 
    {
        g_PanelPositions.IsVisible = true;
        TogglePositionsPanel(true);
    }
    
    // 3. Show Alert Banner (Red)
    string alertName = PREFIX + "LicenseAlert";
    if(ObjectFind(0, alertName) < 0)
    {
        ObjectCreate(0, alertName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
        ObjectSetInteger(0, alertName, OBJPROP_XDISTANCE, 0);
        ObjectSetInteger(0, alertName, OBJPROP_YDISTANCE, 0);
        ObjectSetInteger(0, alertName, OBJPROP_XSIZE, (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS));
        ObjectSetInteger(0, alertName, OBJPROP_YSIZE, 30);
        ObjectSetInteger(0, alertName, OBJPROP_BGCOLOR, g_ColorRed);
        ObjectSetInteger(0, alertName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, alertName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    }
    
    string alertTxt = PREFIX + "LicenseAlertTxt";
    
    // Simplified logic for reasons
    string reason = "VERIFICATION FAILED";
    string errLower = g_AuthErrorMsg;
    StringToLower(errLower);

    if(StringFind(errLower, "code") >= 0 || StringFind(errLower, "incorrect") >= 0 || StringFind(errLower, "chang") >= 0)
        reason = "INVALID ACTIVATION CODE";
    else if(StringFind(errLower, "hardware") >= 0 || StringFind(errLower, "id") >= 0 || StringFind(errLower, "appareil") >= 0 || StringFind(errLower, "activé") >= 0)
        reason = "DEVICE MISMATCH";
    else if(StringFind(errLower, "bloqué") >= 0 || StringFind(errLower, "blocked") >= 0 || StringFind(errLower, "status") >= 0)
        reason = "ACCOUNT BLOCKED";
    else if(StringFind(errLower, "certificat") >= 0 || StringFind(errLower, "token") >= 0)
        reason = "CERTIFICATE ERROR";

    // ULTRA-SIMPLIFIED BOLD MESSAGE
    string fullMsg = reason + " - contact@fantomepad.com";
    int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);

    if(ObjectFind(0, alertTxt) < 0)
    {
        ObjectCreate(0, alertTxt, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, alertTxt, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, alertTxt, OBJPROP_YDISTANCE, 7); 
        ObjectSetString(0, alertTxt, OBJPROP_FONT, "Trebuchet MS Bold"); // Use a naturally bolder font
        ObjectSetInteger(0, alertTxt, OBJPROP_FONTSIZE, 10); // Slightly larger
        ObjectSetInteger(0, alertTxt, OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, alertTxt, OBJPROP_ANCHOR, ANCHOR_UPPER); 
    }
    
    // Exact center position
    ObjectSetInteger(0, alertTxt, OBJPROP_XDISTANCE, chartW / 2);
    ObjectSetString(0, alertTxt, OBJPROP_TEXT, fullMsg);
    
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| HELPER: CLEAR SOFT LOCK UI                                       |
//+------------------------------------------------------------------+
void ClearSoftLockUI()
{
    ObjectDelete(0, PREFIX + "LicenseAlert");
    ObjectDelete(0, PREFIX + "LicenseAlertTxt");
    ChartRedraw();
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
void CGUI_Master::RefreshAllPanels()
{
    if(!g_IsLicensed && g_LicenseState != LICENSE_REVOKED)
    {
        CreateAuthUI();
        ShowAuthPanel(true);
        return;
    }

    // Ensure Soft Lock UI is cleared when fully licensed
    if(g_LicenseState == LICENSE_OK) ClearSoftLockUI();
    
    // --- SOFT LOCK ENFORCEMENT ---
    if(g_LicenseState == LICENSE_REVOKED)
    {
        g_PanelMain.IsVisible = false;
        g_PanelAccount.IsVisible = false;
        g_PanelHistory.IsVisible = false;
        g_PanelSettings.IsVisible = false;
        g_PanelPositions.IsVisible = true;
    }

    // 1. Navigation (Master Controller)
    CreateNavigationPanel();
    // Navigation is always visible if EA is running
    SetObjVisible("Nav_Bg", true);
    SetObjVisible("Nav_Btn_Main", true);
    SetObjVisible("Nav_Btn_Pos", true);
    SetObjVisible("Nav_Btn_Account", true);
    SetObjVisible("Nav_Btn_History", true);
    SetObjVisible("Nav_Btn_Settings", true);
    SetObjVisible("Nav_Btn_SymbolSelect", true);
    
    // 1.b Symbol Manager Overlay (High Z-Order)
    CreateSymbolManagerPanel();

    // 2. Trade Panel
    CreatePanel(); 
    ToggleMainPanel(g_PanelMain.IsVisible);
    
    // 3. Account Panel
    CreateAccountPanel(); 
    ToggleAccountPanel(g_PanelAccount.IsVisible);
    
    // 4. Positions Panel
    CreatePositionsPanel();
    TogglePositionsPanel(g_PanelPositions.IsVisible);
    
    // 5. History Panel
    CreateHistoryPanel();
    ToggleHistoryPanel(g_PanelHistory.IsVisible);
    
    // 6. Settings Panel
    if(g_PanelSettings.IsVisible) OpenSettings();
    else ObjectsDeleteAll(0, PREFIX + "Set_"); // Correct prefix

    SyncChartUI();
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| HELPER: SYNC CHART UI (Axes, Interaction)                        |
//+------------------------------------------------------------------+
void SyncChartUI()
{
   bool isAuthMode = (!g_IsLicensed && g_LicenseState != LICENSE_REVOKED);
   
   // Apply Chart UI state based on mode
   if(ChartGetInteger(0, CHART_SHOW_PRICE_SCALE) != (long)!isAuthMode)
      ChartSetInteger(0, CHART_SHOW_PRICE_SCALE, !isAuthMode);
      
   if(ChartGetInteger(0, CHART_SHOW_DATE_SCALE) != (long)!isAuthMode)
      ChartSetInteger(0, CHART_SHOW_DATE_SCALE, !isAuthMode);
      
   if(ChartGetInteger(0, CHART_MOUSE_SCROLL) != (long)!isAuthMode)
      ChartSetInteger(0, CHART_MOUSE_SCROLL, !isAuthMode);
      
   if(ChartGetInteger(0, CHART_KEYBOARD_CONTROL) != (long)!isAuthMode)
      ChartSetInteger(0, CHART_KEYBOARD_CONTROL, !isAuthMode);
   
   // Special: Grid is handled by aesthetic preference in licensed mode, 
   // but always OFF in Auth mode.
   if(isAuthMode && ChartGetInteger(0, CHART_SHOW_GRID) != 0) 
      ChartSetInteger(0, CHART_SHOW_GRID, false);
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
