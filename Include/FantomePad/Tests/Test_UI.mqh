//+------------------------------------------------------------------+
//|                                                Test_UI.mqh       |
//+------------------------------------------------------------------+
#property strict

void Cleanup_UI()
{
   // Close all panels
   g_PanelMain.IsVisible = false;
   g_PanelPositions.IsVisible = false;
   g_PanelInfo.IsVisible = false;
   g_PanelHistory.IsVisible = false;
   g_PanelSettings.IsVisible = false;
   
   // Force update visually to ensure clean state
   // We might need to call specific Toggles to force clear objects too
   // But simply setting flags might be enough for logically testing state transitions
}

void Test_UiToggle_Main()
{
   Print("Running Test_UiToggle_Main...");
   
   // Ensure Closed initially
   g_PanelMain.IsVisible = false;
   
   // Simulate Click on Manager Button "Main"
   // We invoke the Event Dispatcher directly but need variables for references
   long lparam = 0;
   double dparam = 0.0;
   string sparam = PREFIX + "Mgr_Btn_Main";
   GUI_OnChartEvent(CHARTEVENT_OBJECT_CLICK, lparam, dparam, sparam);
   
   // Assert State Change
   AssertTrue(g_PanelMain.IsVisible, "Main Panel should be Visible after click");
   
   // Click again to close
   GUI_OnChartEvent(CHARTEVENT_OBJECT_CLICK, lparam, dparam, sparam);
   AssertTrue(!g_PanelMain.IsVisible, "Main Panel should be Hidden after 2nd click");
}

void Test_UiToggle_Positions()
{
   Print("Running Test_UiToggle_Positions...");
   
   g_PanelPositions.IsVisible = false;
   
   long lparam = 0;
   double dparam = 0.0;
   string sparam = PREFIX + "Mgr_Btn_Pos";
   GUI_OnChartEvent(CHARTEVENT_OBJECT_CLICK, lparam, dparam, sparam);
   
   AssertTrue(g_PanelPositions.IsVisible, "Positions Panel Open");
   
   GUI_OnChartEvent(CHARTEVENT_OBJECT_CLICK, lparam, dparam, sparam);
   
   AssertTrue(!g_PanelPositions.IsVisible, "Positions Panel Closed");
}

void Test_UiToggle_Settings()
{
   Print("Running Test_UiToggle_Settings...");
   
   g_PanelSettings.IsVisible = false;
   
   // Simulate click on Settings button
   long lparam = 0;
   double dparam = 0.0;
   string sparam = PREFIX + "Mgr_Btn_Settings";
   GUI_OnChartEvent(CHARTEVENT_OBJECT_CLICK, lparam, dparam, sparam);
   
   AssertTrue(g_PanelSettings.IsVisible, "Settings Panel Open");
}
