//+------------------------------------------------------------------+
//|                                                   GUI_Refresh.mqh |
//|                                              FantomePad Project  |
//|                                         UI Refresh & Layout Logic |
//+------------------------------------------------------------------+
#ifndef _GUI_REFRESH_MQH_
#define _GUI_REFRESH_MQH_

#include "../Core/Defines.mqh"

//+------------------------------------------------------------------+
//| HELPER: REFRESH ALL PANELS                                       |
//+------------------------------------------------------------------+
void RefreshAllPanels()
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

#endif
