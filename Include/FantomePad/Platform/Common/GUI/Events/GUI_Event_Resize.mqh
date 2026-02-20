//+------------------------------------------------------------------+
//|                                             GUI_Event_Resize.mqh |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| EVENT: RESIZE                                                    |
//+------------------------------------------------------------------+
void OnEvent_Resize()
{
   static bool isRunning = false;
   if(isRunning) return;
   
   // --- MT5 SCROLLING FIX ---
   // MT5 triggers CHARTEVENT_CHART_CHANGE heavily on simple chart scrolling.
   // We only want to process resize logic if the actual window dimensions changed.
   static int prevWidth = 0;
   static int prevHeight = 0;
   int curWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int curHeight = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   if(curWidth == prevWidth && curHeight == prevHeight)
   {
       return; // Chart just scrolled or properties changed without resizing
   }
   
   prevWidth = curWidth;
   prevHeight = curHeight;
   
   isRunning = true;

   // --- AUTH PANEL RESIZE ---
   if(!g_IsLicensed && g_LicenseState != LICENSE_REVOKED)
   {
      CreateAuthUI();
      ShowAuthPanel(true);
      isRunning = false;
      return;
   }
   // --- SAFETY CHECK: Recenter panels if hidden by resize ---
   if(g_PanelMain.IsVisible) {
       long h = ObjectGetInteger(0, PREFIX + "Bg", OBJPROP_YSIZE);
       if(h < 50) h = 200; 
       ApplyPanelSafety(g_PanelMain.X, g_PanelMain.Y, g_PanelMain.Width, (int)h);
   }
   
   if(g_PanelAccount.IsVisible) {
       long h = ObjectGetInteger(0, PREFIX + "Account_Bg", OBJPROP_YSIZE);
       if(h < 50) h = 150;
       ApplyPanelSafety(g_PanelAccount.X, g_PanelAccount.Y, 200, (int)h);
   }
   
   if(g_PanelPositions.IsVisible) {
       long h = ObjectGetInteger(0, PREFIX + "Pos_Bg", OBJPROP_YSIZE);
       if(h < 50) h = 150;
       ApplyPanelSafety(g_PanelPositions.X, g_PanelPositions.Y, 280, (int)h);
   }
   
   if(g_PanelHistory.IsVisible) {
       long h = ObjectGetInteger(0, PREFIX + "Hist_Bg", OBJPROP_YSIZE);
       if(h < 50) h = 200;
       ApplyPanelSafety(g_PanelHistory.X, g_PanelHistory.Y, 800, (int)h);
   }
   
   if(g_PanelSettings.IsVisible) {
        int h = 50 + g_ScrollSettings.ViewportHeight;
        ApplyPanelSafety(g_PanelSettings.X, g_PanelSettings.Y, 340, h);
   }

   // 2. Full UI Refresh
   RefreshAllPanels();

   isRunning = false;
}
