//+------------------------------------------------------------------+
//|                                              Panel_Settings.mqh  |
//|                                                MagicKey Project  |
//+------------------------------------------------------------------+
#property strict

// Helper to manage visibility based on scroll
bool IsItemVisible(int relY, int h)
{
   // Visible window relative to content start (0)
   int viewTop = g_SettingsScrollY;
   int viewBottom = g_SettingsScrollY + SettingsViewportHeight;
   
   // Item range
   int itemTop = relY;
   int itemBottom = relY + h;
   
   // STRICT CHECK to avoid overflow bugs (Header/Footer bleeding)
   // We hide the item if it's not FULLY within the viewport
   if(itemTop < viewTop) return false; 
   if(itemBottom > viewBottom) return false;
   
   return true;
}

// Forward declarations helpers
void CreateColorRow(string suffix, string label, int x, int y, color col, bool visible)
{
   string lblName = "Set_Lbl_" + suffix;
   string btnName = "Set_Btn_Color_" + suffix;
   
   if(visible)
   {
      CreateLabel(lblName, label, x, y + 4, 8, g_ColorLabel, "Trebuchet MS");
      ObjectSetInteger(0, PREFIX + lblName, OBJPROP_ZORDER, 102);
      SetObjVisible(lblName, true);
      
      // Box at relative right of column (approx 130px width per col)
      int boxX = x + 110; 
      CreateButton(btnName, "", boxX, y, 25, 25, col, clrNONE);
      ObjectSetInteger(0, PREFIX + btnName, OBJPROP_ZORDER, 102);
      ObjectSetInteger(0, PREFIX + btnName, OBJPROP_BORDER_COLOR, C'100,100,100');
      SetObjVisible(btnName, true);
   }
   else
   {
      // Hide if exists, or don't create
      if(ObjectFind(0, PREFIX + lblName) >= 0) SetObjVisible(lblName, false);
      if(ObjectFind(0, PREFIX + btnName) >= 0) SetObjVisible(btnName, false);
   }
}

void DrawSettingsScrollbar(int x, int y)
{
   int scrollBarWidth = 10;
   int trackX = x + 340 - scrollBarWidth - 2; // Right aligned with slight padding
   int trackY = y + 50;
   int trackH = SettingsViewportHeight;
   
   // 1. Track
   CreateRect("Set_ScrollTrack", trackX, trackY, scrollBarWidth, trackH, g_ColorHeader, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "Set_ScrollTrack", OBJPROP_ZORDER, 115);
   ObjectSetInteger(0, PREFIX + "Set_ScrollTrack", OBJPROP_BORDER_COLOR, g_ColorHeader);
   
   // 2. Thumb
   // Calculate Height Ratio
   // If ContentHeight <= Viewport, Thumb = Track
   int contentH = MathMax(SettingsContentHeight, 1);
   double ratio = (double)SettingsViewportHeight / (double)contentH;
   if(ratio > 1.0) ratio = 1.0;
   
   int thumbH = (int)(trackH * ratio);
   if(thumbH < 30) thumbH = 30; // Min size
   
   // Position
   // ScrollY goes from 0 to (ContentH - ViewportH)
   // ThumbY goes from 0 to (TrackH - ThumbH)
   int maxScroll = contentH - SettingsViewportHeight;
   if(maxScroll <= 0) maxScroll = 1;
   
   int maxThumb = trackH - thumbH;
   
   double p = (double)g_SettingsScrollY / (double)maxScroll;
   if(p < 0) p = 0; 
   if(p > 1) p = 1;
   
   int thumbY = trackY + (int)(p * maxThumb);
   
   // Use CreateButton to ensure it is interactive/detectable if needed, or Rect to match exact look.
   // Panel_Main uses CreateRect. Since our interaction logic in GUI_Master is coordinate based, Rect is fine.
   // But Panel_Settings used Button before. Let's use Button simply for consistency in this file,
   // BUT style it to look like the Rect (Flat, specific color).
   
   CreateButton("Set_ScrollThumb", "", trackX + 1, thumbY, scrollBarWidth - 2, thumbH, g_ColorLabel, clrNONE);
   ObjectSetInteger(0, PREFIX + "Set_ScrollThumb", OBJPROP_ZORDER, 116);
   ObjectSetInteger(0, PREFIX + "Set_ScrollThumb", OBJPROP_BORDER_COLOR, g_ColorLabel); 
}

void CloseSettings()
{
   IsSettingsOpen = false;
   // Delete all Settings objects
   ObjectsDeleteAll(0, PREFIX + "Set_");
   ChartRedraw();
}

void OpenSettings()
{
   IsSettingsOpen = true;
   
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   int w = 340; 
   int h = 50 + SettingsViewportHeight; // Header + Viewport
   
   if(SettingsX == -1)
   {
      SettingsX = (chartW/2) - (w/2);
      SettingsY = (chartH/2) - (h/2);
   }
   
   int x = SettingsX;
   int y = SettingsY;
   
   // --- BACKGROUND ---
   CreateRect("Set_Bg", x, y, w, h, g_ColorBg, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "Set_Bg", OBJPROP_ZORDER, 100);
   ObjectSetInteger(0, PREFIX + "Set_Bg", OBJPROP_BORDER_COLOR, C'60,60,60');
   ObjectSetInteger(0, PREFIX + "Set_Bg", OBJPROP_WIDTH, 1);
   
   // --- HEADER ---
   CreateRect("Set_Header", x, y, w, 50, g_ColorHeader, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "Set_Header", OBJPROP_ZORDER, 110); // Elevated to cover scroll content
   
   CreateLabel("Set_Title", "Settings", x + 20, y + 15, 12, clrWhite, "Trebuchet MS Bold");
   ObjectSetInteger(0, PREFIX + "Set_Title", OBJPROP_ZORDER, 111);
   
   // --- CONTENT GENERATION ---
   // We define absolute Y relative to the Content Start (0)
   // Content Start on screen is y + 50
   
   int relY = 20; 
   int padX = 20;
   int contentStartScreenY = y + 50;
   
   // Helper lambda substitution
   #define CHECK_VIS(h) IsItemVisible(relY, h)
   #define SCREEN_Y (contentStartScreenY + relY - g_SettingsScrollY)
   
   // 1. RISK
   bool v = CHECK_VIS(25);
   string n = "Set_Lbl_Cat1";
   if(v) { CreateLabel(n, "RISK MANAGEMENT", x + padX, SCREEN_Y, 9, C'100,100,100', "Trebuchet MS Bold"); ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true); }
   else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 25;
   
   v = CHECK_VIS(25);
   n = "Set_Lbl_Risk"; string ne = "Set_Edit_Risk";
   if(v) {
      CreateLabel(n, "Default Risk (%)", x + padX, SCREEN_Y + 3, 9, g_ColorLabel, "Trebuchet MS");
      ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
      CreateEdit(ne, DoubleToString(g_DefaultRisk, 1), x + w - 80, SCREEN_Y, 60, 25);
      ObjectSetInteger(0, PREFIX + ne, OBJPROP_ZORDER, 102);
      ObjectSetInteger(0, PREFIX + ne, OBJPROP_BGCOLOR, g_ColorInput);
      ObjectSetInteger(0, PREFIX + ne, OBJPROP_COLOR, g_ColorText);
      ObjectSetInteger(0, PREFIX + ne, OBJPROP_BORDER_COLOR, C'60,64,72');
      ObjectSetInteger(0, PREFIX + ne, OBJPROP_ALIGN, ALIGN_CENTER);
      SetObjVisible(ne, true);
   } else {
      if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
      if(ObjectFind(0, PREFIX + ne) >= 0) SetObjVisible(ne, false);
   }
   relY += 30;
   
   v = CHECK_VIS(25);
   n = "Set_Lbl_RiskMoney"; ne = "Set_Edit_RiskMoney";
   string currency = AccountCurrency();
   if(v) {
      CreateLabel(n, "Default Risk (" + currency + ")", x + padX, SCREEN_Y + 3, 9, g_ColorLabel, "Trebuchet MS");
      ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
      CreateEdit(ne, DoubleToString(g_DefaultRiskMoney, 2), x + w - 80, SCREEN_Y, 60, 25);
      ObjectSetInteger(0, PREFIX + ne, OBJPROP_ZORDER, 102);
      ObjectSetInteger(0, PREFIX + ne, OBJPROP_BGCOLOR, g_ColorInput);
      ObjectSetInteger(0, PREFIX + ne, OBJPROP_COLOR, g_ColorText);
      ObjectSetInteger(0, PREFIX + ne, OBJPROP_BORDER_COLOR, C'60,64,72');
      ObjectSetInteger(0, PREFIX + ne, OBJPROP_ALIGN, ALIGN_CENTER);
      SetObjVisible(ne, true);
   } else {
      if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
      if(ObjectFind(0, PREFIX + ne) >= 0) SetObjVisible(ne, false);
   }
   relY += 30;
   
   v = CHECK_VIS(25);
   n = "Set_Lbl_RiskR"; ne = "Set_Edit_RiskR";
   if(v) {
      CreateLabel(n, "Default Risk (R)", x + padX, SCREEN_Y + 3, 9, g_ColorLabel, "Trebuchet MS");
      ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
      CreateEdit(ne, DoubleToString(g_DefaultRiskR, 2), x + w - 80, SCREEN_Y, 60, 25);
      ObjectSetInteger(0, PREFIX + ne, OBJPROP_ZORDER, 102);
      ObjectSetInteger(0, PREFIX + ne, OBJPROP_BGCOLOR, g_ColorInput);
      ObjectSetInteger(0, PREFIX + ne, OBJPROP_COLOR, g_ColorText);
      ObjectSetInteger(0, PREFIX + ne, OBJPROP_BORDER_COLOR, C'60,64,72');
      ObjectSetInteger(0, PREFIX + ne, OBJPROP_ALIGN, ALIGN_CENTER);
      SetObjVisible(ne, true);
   } else {
       if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
       if(ObjectFind(0, PREFIX + ne) >= 0) SetObjVisible(ne, false);
   }
   relY += 30;
   
   v = CHECK_VIS(25);
   n = "Set_Lbl_OneRPercent"; ne = "Set_Edit_OneRPercent";
   if(v) {
       CreateLabel(n, "1R Value (%)", x + padX, SCREEN_Y + 3, 9, g_ColorLabel, "Trebuchet MS");
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
       CreateEdit(ne, DoubleToString(g_OneRPercent, 2), x + w - 80, SCREEN_Y, 60, 25);
       ObjectSetInteger(0, PREFIX + ne, OBJPROP_ZORDER, 102);
       ObjectSetInteger(0, PREFIX + ne, OBJPROP_BGCOLOR, g_ColorInput);
       ObjectSetInteger(0, PREFIX + ne, OBJPROP_COLOR, g_ColorText);
       ObjectSetInteger(0, PREFIX + ne, OBJPROP_BORDER_COLOR, C'60,64,72');
       ObjectSetInteger(0, PREFIX + ne, OBJPROP_ALIGN, ALIGN_CENTER);
       SetObjVisible(ne, true);
   } else {
       if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
       if(ObjectFind(0, PREFIX + ne) >= 0) SetObjVisible(ne, false);
   }
   relY += 40;
   
   v = CHECK_VIS(1);
   n = "Set_Sep1";
   if(v) {
       CreateRect(n, x + padX, SCREEN_Y, w - (padX*2) - 15, 1, C'50,50,50', BORDER_FLAT);
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
   } else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 20;

   // 2. COLORS
   v = CHECK_VIS(20);
   n = "Set_Lbl_Cat2";
   if(v) {
       CreateLabel(n, "INTERFACE COLORS", x + padX, SCREEN_Y, 9, C'100,100,100', "Trebuchet MS Bold");
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
   } else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 30;
   
   // Columns
   int col1X = x + padX;
   int col2X = x + (w/2) + 10;
   int rowH = 32;
   
   // Helper to create Color Row
   // Row 1
   v = CHECK_VIS(25);
   CreateColorRow("Bg", "Panel Background", col1X, SCREEN_Y, g_ColorBg, v);
   CreateColorRow("Head", "Header Bar", col2X, SCREEN_Y, g_ColorHeader, v);
   relY += rowH;
   
   // Row 2
   v = CHECK_VIS(25);
   CreateColorRow("Input", "Field Background", col1X, SCREEN_Y, g_ColorInput, v);
   CreateColorRow("ChrtBg", "Chart Background", col2X, SCREEN_Y, g_ColorChartBg, v);
   relY += rowH;
   
   // Row 3
   v = CHECK_VIS(25);
   CreateColorRow("ChrtFg", "Chart Text", col1X, SCREEN_Y, g_ColorChartFg, v);
   CreateColorRow("Txt", "Primary Text", col2X, SCREEN_Y, g_ColorText, v); // Moved Txt here
   relY += rowH;
   
    // Row 4
   v = CHECK_VIS(25);
   CreateColorRow("Lbl", "Secondary Labels", col1X, SCREEN_Y, g_ColorLabel, v);
   CreateColorRow("Green", "Buy (Long)", col2X, SCREEN_Y, g_ColorGreen, v);
   relY += rowH;
   
   // Row 5
   v = CHECK_VIS(25);
   CreateColorRow("Red", "Sell (Short)", col1X, SCREEN_Y, g_ColorRed, v);
   CreateColorRow("EntLine", "Entry Line", col2X, SCREEN_Y, g_ColorEntryLine, v);
   relY += rowH;
   
   // Row 6
   v = CHECK_VIS(25);
   CreateColorRow("SLLine", "Stop Loss Line", col1X, SCREEN_Y, g_ColorSLLine, v);
   CreateColorRow("TPLine", "Take Profit Line", col2X, SCREEN_Y, g_ColorTPLine, v);
   relY += rowH;

   // Row 7
   v = CHECK_VIS(25);
   CreateColorRow("CUp", "Candle Up", col1X, SCREEN_Y, g_ColorCandleUp, v);
   CreateColorRow("CDown", "Candle Down", col2X, SCREEN_Y, g_ColorCandleDown, v);
   relY += rowH;
   
   // Row 8
   v = CHECK_VIS(25);
   CreateColorRow("BtnVal", "Button Valid", col1X, SCREEN_Y, g_ColorBtnValid, v);
   CreateColorRow("BtnInv", "Button Invalid", col2X, SCREEN_Y, g_ColorBtnInvalid, v);
   relY += rowH;
   
   // --- SCROLLBAR ---
   DrawSettingsScrollbar(x, y);
   
   // --- OVERLAY FOR CLIPPING (Visual Fix for Header) ---
   // Top Header is already Z=105, Items are Z=102. So Header covers items scrolling up.
   // But we need to cover items scrolling DOWN past the bottom?
   // Create a "Footer" mask if needed, but better to just use visibility check which we did.
   // Note: Items partiality is handled by "CHECK_VIS". If bottom of item > viewBottom, it returns false (hidden).
   // So items will pop out when fully visible. That's safer for now.
}

void ToggleSettings()
{
   if(IsSettingsOpen) CloseSettings();
   else 
   {
      g_SettingsScrollY = 0;
      OpenSettings();
   }
}

//+------------------------------------------------------------------+
//| COLOR PICKER IMPLEMENTATION                                      |
//+------------------------------------------------------------------+
void CloseColorPicker()
{
   ObjectsDeleteAll(0, PREFIX + "CP_");
   ChartRedraw();
}

void CreateColorPicker()
{
   // Center on screen
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   int w = 250;
   int h = 300;
   int x = (chartW/2) - (w/2) + 20; 
   int y = (chartH/2) - (h/2) + 20;
   
   // Bg
   CreateRect("CP_Bg", x, y, w, h, C'30,30,30', BORDER_RAISED);
   ObjectSetInteger(0, PREFIX + "CP_Bg", OBJPROP_ZORDER, 200);
   ObjectSetInteger(0, PREFIX + "CP_Bg", OBJPROP_BORDER_COLOR, C'60,60,60');
   
   CreateLabel("CP_Title", "Select Color", x + 10, y + 10, 8, clrWhite, "Trebuchet MS");
   ObjectSetInteger(0, PREFIX + "CP_Title", OBJPROP_ZORDER, 201);
   
   color Palette[] = {
      // Darks
      C'21,23,28', C'34,38,46', C'45,52,60', clrDimGray, clrBlack,
      // Lights
      clrWhite, clrWhiteSmoke, clrSilver, clrLightGray, clrAliceBlue,
      // Greens
      C'0,184,148', clrSeaGreen, clrMediumSeaGreen, clrLimeGreen, clrSpringGreen,
      // Reds
      C'214,48,49', clrCrimson, clrFireBrick, clrRed, clrTomato,
      // Blues
      C'0,90,180', clrRoyalBlue, clrDodgerBlue, clrCornflowerBlue, clrDeepSkyBlue
   };
   
   int cols = 5;
   int rows = 5;
   int btnSize = 35;
   int gap = 8;
   int startX = x + 18;
   int startY = y + 40;
   
   for(int i=0; i<ArraySize(Palette); i++)
   {
      int r = i / cols;
      int c = i % cols;
      
      int posX = startX + (c * (btnSize + gap));
      int posY = startY + (r * (btnSize + gap));
      
      string name = "CP_Item_" + IntegerToString(i);
      CreateButton(name, "", posX, posY, btnSize, btnSize, Palette[i], clrNONE);
      ObjectSetInteger(0, PREFIX + name, OBJPROP_ZORDER, 201);
       ObjectSetInteger(0, PREFIX + name, OBJPROP_BORDER_COLOR, clrNONE);
    }
    
    // --- Custom Color Section ---
    int customY = startY + (5 * (btnSize + gap)) + 10;
    
    CreateEdit("CP_Edit_Custom", "#FFFFFF", x + 18, customY, 140, 25);
    ObjectSetInteger(0, PREFIX + "CP_Edit_Custom", OBJPROP_ZORDER, 201);
    ObjectSetInteger(0, PREFIX + "CP_Edit_Custom", OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, PREFIX + "CP_Edit_Custom", OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, PREFIX + "CP_Edit_Custom", OBJPROP_ALIGN, ALIGN_LEFT);
    
    CreateButton("CP_Btn_Custom", "APPLY", x + 165, customY, 60, 25, C'0,122,255', clrWhite);
    ObjectSetInteger(0, PREFIX + "CP_Btn_Custom", OBJPROP_ZORDER, 201);
    ObjectSetInteger(0, PREFIX + "CP_Btn_Custom", OBJPROP_FONTSIZE, 9);
    ObjectSetString(0, PREFIX + "CP_Btn_Custom", OBJPROP_FONT, "Trebuchet MS Bold");
}
