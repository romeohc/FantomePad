//+------------------------------------------------------------------+
//|                                             GUI_Event_Resize.mqh |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| EVENT: RESIZE                                                    |
//+------------------------------------------------------------------+
void OnEvent_Resize()
{
   // --- SAFETY CHECK: Recenter panels if hidden by resize ---
   if(g_PanelMain.IsVisible) {
       long h = ObjectGetInteger(0, PREFIX + "Bg", OBJPROP_YSIZE);
       if(h < 50) h = 200; 
       ApplyPanelSafety(g_PanelMain.X, g_PanelMain.Y, g_PanelMain.Width, (int)h);
   }
   
   if(g_PanelInfo.IsVisible) {
       long h = ObjectGetInteger(0, PREFIX + "Info_Bg", OBJPROP_YSIZE);
       if(h < 50) h = 150;
       ApplyPanelSafety(g_PanelInfo.X, g_PanelInfo.Y, 200, (int)h);
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

   CreatePanel();
   CreateInfoPanel();
   CreateManagerPanel();
   CreatePositionsPanel();
   CreateHistoryPanel();
   if(g_PanelMain.IsVisible) UpdateUIMode();
   else ToggleMainPanel(false);
   
   if(g_PanelSettings.IsVisible) OpenSettings(); // Redraw settings if open
}
