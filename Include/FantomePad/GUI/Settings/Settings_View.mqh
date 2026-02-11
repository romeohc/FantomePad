//+------------------------------------------------------------------+
//|                                                Settings_View.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

void CloseSettings()
{
   g_PanelSettings.IsVisible = false;
   // Delete all Settings objects
   ObjectsDeleteAll(0, PREFIX + "Set_");
   ChartRedraw();
}

void OpenSettings()
{
   g_PanelSettings.IsVisible = true;
   
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   int w = 340; 
   int h = 20 + g_ScrollSettings.ViewportHeight; // 20px Top Margin + Viewport
   
   if(g_PanelSettings.X == -1)
   {
      g_PanelSettings.X = (chartW/2) - (w/2);
      g_PanelSettings.Y = (chartH/2) - (h/2);
   }
   
   int x = g_PanelSettings.X;
   int y = g_PanelSettings.Y;
   
   // --- MAIN CONTAINER ---
   CreateRect("Set_Bg", x, y, w, h, g_ColorBg, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "Set_Bg", OBJPROP_ZORDER, 100);
   ObjectSetInteger(0, PREFIX + "Set_Bg", OBJPROP_BORDER_COLOR, C'80,80,80');
   ObjectSetInteger(0, PREFIX + "Set_Bg", OBJPROP_WIDTH, 1);
   
   // --- CONTENT GENERATION ---
   int relY = 10; // Start slightly below top margin
   int padX = 20;
   int contentStartScreenY = y + 20; // content starts after 20px top margin
   
   // Helper lambda substitution
   #define CHECK_VIS(h) IsItemVisible(relY, h)
   #define SCREEN_Y (contentStartScreenY + relY - g_ScrollSettings.ScrollY)
   
   // 0. GENERAL
   bool v = CHECK_VIS(25);
   string n = "Set_Lbl_Cat_Gen";
   if(v) { CreateLabel(n, "GENERAL", x + padX, SCREEN_Y, 9, g_ColorText, "Trebuchet MS Bold"); ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true); }
   else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 30;

   // --- PANEL POSITION ---
   v = CHECK_VIS(25);
   n = "Set_Lbl_NavPos"; string nb = "Set_Btn_NavPos";
   if(v) {
       CreateLabel(n, "Panel Position", x + padX, SCREEN_Y + 3, 9, g_ColorText, "Trebuchet MS");
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
       
       CreateButton(nb, NavigationPositions[g_NavigationPosition], x + w - 140, SCREEN_Y, 120, 25, g_ColorInput, g_ColorText);
       ObjectSetInteger(0, PREFIX + nb, OBJPROP_ZORDER, 102); 
       SetObjVisible(nb, true);
   } else {
       if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
       if(ObjectFind(0, PREFIX + nb) >= 0) SetObjVisible(nb, false);
   }
   relY += 30;

   // --- SHOW ORDER LINES ---
   v = CHECK_VIS(25);
   n = "Set_Lbl_ShowLines"; string nb2 = "Set_Btn_ShowLines";
   if(v) {
       CreateLabel(n, "Show Order Lines", x + padX, SCREEN_Y + 3, 9, g_ColorText, "Trebuchet MS");
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
       
       string txtLines = g_ShowOrderLines ? "ON" : "OFF";
       color bgLines = g_ShowOrderLines ? g_ColorBtnActive : g_ColorInput;
       
       CreateButton(nb2, txtLines, x + w - 80, SCREEN_Y, 60, 25, bgLines, g_ColorText);
       ObjectSetInteger(0, PREFIX + nb2, OBJPROP_ZORDER, 102); 
       SetObjVisible(nb2, true);
   } else {
       if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
       if(ObjectFind(0, PREFIX + nb2) >= 0) SetObjVisible(nb2, false);
   }
   relY += 30;

   // --- SHOW POSITION LINES (Open Trades Entry/SL/TP) ---
   v = CHECK_VIS(25);
   n = "Set_Lbl_ShowPosLines"; string nb3 = "Set_Btn_ShowPosLines";
   if(v) {
       CreateLabel(n, "Show Position Lines", x + padX, SCREEN_Y + 3, 9, g_ColorText, "Trebuchet MS");
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);

       string txtPosLines = g_ShowPositionLines ? "ON" : "OFF";
       color bgPosLines = g_ShowPositionLines ? g_ColorBtnActive : g_ColorInput;

       CreateButton(nb3, txtPosLines, x + w - 80, SCREEN_Y, 60, 25, bgPosLines, g_ColorText);
       ObjectSetInteger(0, PREFIX + nb3, OBJPROP_ZORDER, 102); 
       SetObjVisible(nb3, true);
   } else {
       if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
       if(ObjectFind(0, PREFIX + nb3) >= 0) SetObjVisible(nb3, false);
   }
   relY += 40;

   // --- Separator ---
   v = CHECK_VIS(1);
   n = "Set_Sep_Gen";
   if(v) { CreateRect(n, x + padX, SCREEN_Y, w - (padX*2) - 15, 1, C'50,50,50', BORDER_FLAT); ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true); }
   else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 30;

   // 1. RISK
   v = CHECK_VIS(25);
   n = "Set_Lbl_Cat1";
   if(v) { CreateLabel(n, "RISK MANAGEMENT", x + padX, SCREEN_Y, 9, g_ColorText, "Trebuchet MS Bold"); ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true); }
   else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 30;

   // --- 1R VALUE ---
   v = CHECK_VIS(25);
   n = "Set_Lbl_OneRPercent"; string ne = "Set_Edit_OneRPercent";
   if(v) {
       CreateLabel(n, "1R Value (%)", x + padX, SCREEN_Y + 3, 9, g_ColorText, "Trebuchet MS");
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
       CreateEdit(ne, DoubleToString(g_OneRPercent, 2), x + w - 80, SCREEN_Y, 60, 25);
       ObjectSetInteger(0, PREFIX + ne, OBJPROP_ZORDER, 102);
       ObjectSetInteger(0, PREFIX + ne, OBJPROP_BGCOLOR, g_ColorInput);
       ObjectSetInteger(0, PREFIX + ne, OBJPROP_COLOR, g_ColorText);
       ObjectSetInteger(0, PREFIX + ne, OBJPROP_BORDER_COLOR, C'60,64,72');
       ObjectSetInteger(0, PREFIX + ne, OBJPROP_ALIGN, ALIGN_CENTER);
       SetObjVisible(ne, true);

       // --- MAX RISK (%) ---
       string nRisk = "Set_Lbl_MaxRiskPercent"; string neRisk = "Set_Edit_MaxRiskPercent";
       CreateLabel(nRisk, "Max Risk (%)", x + padX, SCREEN_Y + 33, 9, g_ColorText, "Trebuchet MS");
       ObjectSetInteger(0, PREFIX + nRisk, OBJPROP_ZORDER, 102); SetObjVisible(nRisk, true);
       CreateEdit(neRisk, DoubleToString(g_MaxRiskPercent, 2), x + w - 80, SCREEN_Y + 30, 60, 25);
       ObjectSetInteger(0, PREFIX + neRisk, OBJPROP_ZORDER, 102);
       ObjectSetInteger(0, PREFIX + neRisk, OBJPROP_BGCOLOR, g_ColorInput);
       ObjectSetInteger(0, PREFIX + neRisk, OBJPROP_COLOR, g_ColorText);
       ObjectSetInteger(0, PREFIX + neRisk, OBJPROP_BORDER_COLOR, C'60,64,72');
       ObjectSetInteger(0, PREFIX + neRisk, OBJPROP_ALIGN, ALIGN_CENTER);
       SetObjVisible(neRisk, true);
   } else {
       if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
       if(ObjectFind(0, PREFIX + ne) >= 0) SetObjVisible(ne, false);
       
       if(ObjectFind(0, PREFIX + "Set_Lbl_MaxRiskPercent") >= 0) SetObjVisible("Set_Lbl_MaxRiskPercent", false);
       if(ObjectFind(0, PREFIX + "Set_Edit_MaxRiskPercent") >= 0) SetObjVisible("Set_Edit_MaxRiskPercent", false);
   }
   relY += 70; // Increased spacing for 2 inputs
   
   // Separator
   v = CHECK_VIS(1);
   n = "Set_Sep1";
   if(v) {
       CreateRect(n, x + padX, SCREEN_Y, w - (padX*2) - 15, 1, C'50,50,50', BORDER_FLAT);
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
   } else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 20;

   // 2. THEME / COLORS
   v = CHECK_VIS(25);
   n = "Set_Lbl_Cat2";
   if(v) {
       CreateLabel(n, "INTERFACE COLORS", x + padX, SCREEN_Y, 9, g_ColorText, "Trebuchet MS Bold");
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
   } else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 30;

   int col1X = x + padX;
   int col2X = x + 175;
   int rowH = 35;

   // Theme Sub-Category
   v = CHECK_VIS(25);
   n = "Set_Sub_Theme";
   if(v) {
       CreateLabel(n, "General Theme", x + padX, SCREEN_Y + 5, 8, g_ColorText, "Trebuchet MS Bold");
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
   } else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 30;

   // Theme Row 1
   v = CHECK_VIS(rowH);
   CreateColorRow("Bg", "Panel Background", col1X, SCREEN_Y, g_ColorBg, v);
   CreateColorRow("Txt", "Text Color", col2X, SCREEN_Y, g_ColorText, v);
   relY += rowH;
   
   // Theme Row 2
   v = CHECK_VIS(rowH);
   CreateColorRow("Input", "Input Fields", col1X, SCREEN_Y, g_ColorInput, v);
   CreateColorRow("BtnInv", "Inactive Buttons", col2X, SCREEN_Y, g_ColorBtnInvalid, v);
   relY += rowH;

   // Theme Row 3
   v = CHECK_VIS(rowH);
   CreateColorRow("BtnAct", "Active Buttons", col1X, SCREEN_Y, g_ColorBtnActive, v);
   relY += rowH + 10;

   // --- SUB: CHART ---
   v = CHECK_VIS(20);
   n = "Set_Sub_Chart";
   if(v) {
       CreateLabel(n, "Chart & Candles", x + padX, SCREEN_Y + 5, 8, g_ColorText, "Trebuchet MS Bold");
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
   } else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 30;

   // Lines Row 1
   v = CHECK_VIS(rowH);
   CreateColorRow("ChrtBg", "Chart Background", col1X, SCREEN_Y, g_ColorChartBg, v);
   CreateColorRow("CUp", "Candle Bull (Up)", col2X, SCREEN_Y, g_ColorCandleUp, v);
   relY += rowH;

   // Lines Row 2
   v = CHECK_VIS(rowH);
   CreateColorRow("CDown", "Candle Bear (Down)", col1X, SCREEN_Y, g_ColorCandleDown, v);
   CreateColorRow("ChrtFg", "Axes Text Color", col2X, SCREEN_Y, g_ColorChartFg, v);
   relY += rowH + 10;

   // --- SUB: TRADING ---
   v = CHECK_VIS(20);
   n = "Set_Sub_Trade";
   if(v) {
       CreateLabel(n, "Trading Action", x + padX, SCREEN_Y + 5, 8, g_ColorText, "Trebuchet MS Bold");
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
   } else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 30;

   // Lines Row 1
   v = CHECK_VIS(rowH);
   CreateColorRow("EntryLine", "Entry Line", col1X, SCREEN_Y, g_ColorEntryLine, v);
   CreateColorRow("TPLine", "Take Profit Line", col2X, SCREEN_Y, g_ColorTPLine, v);
   relY += rowH;
   
   // Lines Row 2
   v = CHECK_VIS(rowH);
   CreateColorRow("SLLine", "Stop Loss Line", col1X, SCREEN_Y, g_ColorSLLine, v);
   relY += rowH;
   
   // --- SCROLLBAR ---
   DrawSettingsScrollbar(x, y);
   
   // Update Content Height global
   g_ScrollSettings.ContentHeight = relY;

   #undef CHECK_VIS
   #undef SCREEN_Y
}

void ToggleSettings()
{
   if(g_PanelSettings.IsVisible) CloseSettings();
   else 
   {
      g_ScrollSettings.ScrollY = 0;
      OpenSettings();
   }
}
