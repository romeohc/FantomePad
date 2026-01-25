//+------------------------------------------------------------------+
//|                                              Panel_Settings.mqh  |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict


// Helper to manage visibility based on scroll
bool IsItemVisible(int relY, int h)
{
   // Visible window relative to content start (0)
   int viewTop = g_ScrollSettings.ScrollY;
   int viewBottom = g_ScrollSettings.ScrollY + g_ScrollSettings.ViewportHeight;
   
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
      CreateLabel(lblName, label, x, y + 4, 8, g_ColorText, "Trebuchet MS");
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
   int trackH = g_ScrollSettings.ViewportHeight;
   
   // 1. Track
   CreateRect("Set_ScrollTrack", trackX, trackY, scrollBarWidth, trackH, g_ColorBg, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "Set_ScrollTrack", OBJPROP_ZORDER, 115);
   ObjectSetInteger(0, PREFIX + "Set_ScrollTrack", OBJPROP_BORDER_COLOR, g_ColorBg);
   
   // 2. Thumb
   // Calculate Height Ratio
   // If ContentHeight <= Viewport, Thumb = Track
   int contentH = MathMax(g_ScrollSettings.ContentHeight, 1);
   double ratio = (double)g_ScrollSettings.ViewportHeight / (double)contentH;
   if(ratio > 1.0) ratio = 1.0;
   
   int thumbH = (int)(trackH * ratio);
   if(thumbH < 30) thumbH = 30; // Min size
   
   // Position
   // ScrollY goes from 0 to (ContentH - ViewportH)
   // ThumbY goes from 0 to (TrackH - ThumbH)
   int maxScroll = contentH - g_ScrollSettings.ViewportHeight;
   if(maxScroll <= 0) maxScroll = 1;
   
   int maxThumb = trackH - thumbH;
   
   double p = (double)g_ScrollSettings.ScrollY / (double)maxScroll;
   if(p < 0) p = 0; 
   if(p > 1) p = 1;
   
   int thumbY = trackY + (int)(p * maxThumb);
   
   CreateButton("Set_ScrollThumb", "", trackX + 1, thumbY, scrollBarWidth - 2, thumbH, g_ColorText, clrNONE);
   ObjectSetInteger(0, PREFIX + "Set_ScrollThumb", OBJPROP_ZORDER, 116);
   ObjectSetInteger(0, PREFIX + "Set_ScrollThumb", OBJPROP_BORDER_COLOR, g_ColorText); 
}

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
   int h = 50 + g_ScrollSettings.ViewportHeight; // Header + Viewport
   
   if(g_PanelSettings.X == -1)
   {
      g_PanelSettings.X = (chartW/2) - (w/2);
      g_PanelSettings.Y = (chartH/2) - (h/2);
   }
   
   int x = g_PanelSettings.X;
   int y = g_PanelSettings.Y;
   
   // --- BACKGROUND ---
   CreateRect("Set_Bg", x, y, w, h, g_ColorBg, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "Set_Bg", OBJPROP_ZORDER, 100);
   ObjectSetInteger(0, PREFIX + "Set_Bg", OBJPROP_BORDER_COLOR, C'60,60,60');
   ObjectSetInteger(0, PREFIX + "Set_Bg", OBJPROP_WIDTH, 1);
   
   // --- HEADER ---
   CreateRect("Set_Header", x, y, w, 50, g_ColorBg, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "Set_Header", OBJPROP_ZORDER, 110); // Elevated to cover scroll content
   
   CreateLabel("Set_Title", "Settings", x + 15, y + 15, 10, g_ColorText, "Trebuchet MS Bold");
   ObjectSetInteger(0, PREFIX + "Set_Title", OBJPROP_ZORDER, 111);
   
   // --- CONTENT GENERATION ---
   // We define absolute Y relative to the Content Start (0)
   // Content Start on screen is y + 50
   
   int relY = 20; 
   int padX = 20;
   int contentStartScreenY = y + 50;
   
   // Helper lambda substitution
   #define CHECK_VIS(h) IsItemVisible(relY, h)
   #define SCREEN_Y (contentStartScreenY + relY - g_ScrollSettings.ScrollY)
   
   // 0. GENERAL
   bool v = CHECK_VIS(25);
   string n = "Set_Lbl_Cat_Gen";
   if(v) { CreateLabel(n, "GENERAL", x + padX, SCREEN_Y, 9, g_ColorText, "Trebuchet MS Bold"); ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true); }
   else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 25;

   // --- MANAGER POSITION ---
   v = CHECK_VIS(25);
   n = "Set_Lbl_MgrPos"; string nb = "Set_Btn_MgrPos";
   if(v) {
       CreateLabel(n, "Panel Position", x + padX, SCREEN_Y + 3, 9, g_ColorText, "Trebuchet MS");
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
       
       CreateButton(nb, ManagerPositions[g_ManagerPosition], x + w - 140, SCREEN_Y, 120, 25, g_ColorInput, g_ColorText);
       ObjectSetInteger(0, PREFIX + nb, OBJPROP_ZORDER, 102);
       ObjectSetInteger(0, PREFIX + nb, OBJPROP_BORDER_COLOR, C'60,64,72');
       SetObjVisible(nb, true);
   } else {
       if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
       if(ObjectFind(0, PREFIX + nb) >= 0) SetObjVisible(nb, false);
   }
   relY += 30;

   // Separator
   v = CHECK_VIS(1);
   n = "Set_Sep_Gen";
   if(v) {
       CreateRect(n, x + padX, SCREEN_Y, w - (padX*2) - 15, 1, C'50,50,50', BORDER_FLAT);
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
   } else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 20;

   // 1. RISK
   v = CHECK_VIS(25);
   n = "Set_Lbl_Cat1";
   if(v) { CreateLabel(n, "RISK MANAGEMENT", x + padX, SCREEN_Y, 9, g_ColorText, "Trebuchet MS Bold"); ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true); }
   else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 25;
   
   v = CHECK_VIS(25);
   n = "Set_Lbl_Risk"; string ne = "Set_Edit_Risk";
   if(v) {
      CreateLabel(n, "Default Risk (%)", x + padX, SCREEN_Y + 3, 9, g_ColorText, "Trebuchet MS");
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
      CreateLabel(n, "Default Risk (" + currency + ")", x + padX, SCREEN_Y + 3, 9, g_ColorText, "Trebuchet MS");
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
      CreateLabel(n, "Default Risk (R)", x + padX, SCREEN_Y + 3, 9, g_ColorText, "Trebuchet MS");
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
       CreateLabel(n, "1R Value (%)", x + padX, SCREEN_Y + 3, 9, g_ColorText, "Trebuchet MS");
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
   


   // Separator
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
       CreateLabel(n, "INTERFACE COLORS", x + padX, SCREEN_Y, 9, g_ColorText, "Trebuchet MS Bold");
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
   } else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 25;
   
   // Columns
   int col1X = x + padX;
   int col2X = x + (w/2) + 10;
   int rowH = 32;
   
   // --- SUB: UI THEME ---
   v = CHECK_VIS(20);
   n = "Set_Sub_UI";
   if(v) {
       CreateLabel(n, "General Theme", x + padX, SCREEN_Y + 5, 8, g_ColorText, "Trebuchet MS Bold");
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
   } else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 25;

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
   relY += 25;

   // Chart Row 1
   v = CHECK_VIS(rowH);
   CreateColorRow("ChrtBg", "Chart Background", col1X, SCREEN_Y, g_ColorChartBg, v);
   CreateColorRow("CUp", "Candle Bull (Up)", col2X, SCREEN_Y, g_ColorCandleUp, v);
   relY += rowH;

   // Chart Row 2
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
   relY += 25;

   // Trade Row 1
   v = CHECK_VIS(rowH);
   CreateColorRow("Green", "Buy / Primary", col1X, SCREEN_Y, g_ColorGreen, v);
   CreateColorRow("Red", "Sell / Secondary", col2X, SCREEN_Y, g_ColorRed, v);
   relY += rowH + 10;
   
   // --- SUB: LINES ---
   v = CHECK_VIS(20);
   n = "Set_Sub_Lines";
   if(v) {
       CreateLabel(n, "Order Lines", x + padX, SCREEN_Y + 5, 8, g_ColorText, "Trebuchet MS Bold");
       ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 102); SetObjVisible(n, true);
   } else if(ObjectFind(0, PREFIX + n) >= 0) SetObjVisible(n, false);
   relY += 25;

   // Lines Row 1
   v = CHECK_VIS(rowH);
   CreateColorRow("EntLine", "Entry Line", col1X, SCREEN_Y, g_ColorEntryLine, v);
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

//+------------------------------------------------------------------+
//| COLOR PICKER IMPLEMENTATION                                      |
//+------------------------------------------------------------------+
void CloseColorPicker()
{
   g_IsColorPickerOpen = false;
   ObjectsDeleteAll(0, PREFIX + "CP_");
   ChartRedraw();
}

void CreateColorPicker()
{
   g_IsColorPickerOpen = true;

   // Center on screen
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   int cols = 5;
   int btnSize = 35;
   int gap = 8;
   
   // Use Global Palette
   int totalRows = (ArraySize(g_ColorPalette) + cols - 1) / cols;
   
   int w = 260;
   // Calc height: PaddingTop + Grid + Gap + Input/Btn + PaddingBottom
   int gridHeight = totalRows * (btnSize + gap); 
   int inputSectionH = 30;
   int h = 25 + gridHeight + 15 + inputSectionH + 25;
   
   // Position over Settings Window
   int settingsW = 340;
   int settingsH = 50 + g_ScrollSettings.ViewportHeight;
   
   int x = g_PanelSettings.X + (settingsW / 2) - (w / 2);
   int y = g_PanelSettings.Y + (settingsH / 2) - (h / 2);
   
   // Update Globals
   g_ColorPickerX = x;
   g_ColorPickerY = y;
   g_ColorPickerW = w;
   g_ColorPickerH = h;
   
   // Bg - Flat Modern Style (No more BORDER_RAISED)
   CreateRect("CP_Bg", x, y, w, h, g_ColorBg, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "CP_Bg", OBJPROP_ZORDER, 200);
   ObjectSetInteger(0, PREFIX + "CP_Bg", OBJPROP_BORDER_COLOR, C'60,60,60'); // Subtle border
   ObjectSetInteger(0, PREFIX + "CP_Bg", OBJPROP_WIDTH, 1);
   
   // Grid Positioning
   // Center Grid: 5 cols * 35 + 4 gaps * 8 = 175 + 32 = 207 px
   int gridW = (cols * btnSize) + ((cols - 1) * gap);
   int startX = x + (w - gridW) / 2;
   int startY = y + 25;
   
   for(int i=0; i<ArraySize(g_ColorPalette); i++)
   {
      int r = i / cols;
      int c = i % cols;
      
      int posX = startX + (c * (btnSize + gap));
      int posY = startY + (r * (btnSize + gap));
      
      string name = "CP_Item_" + IntegerToString(i);
      CreateButton(name, "", posX, posY, btnSize, btnSize, g_ColorPalette[i], clrNONE);
      ObjectSetInteger(0, PREFIX + name, OBJPROP_ZORDER, 201);
      ObjectSetInteger(0, PREFIX + name, OBJPROP_BORDER_COLOR, clrNONE);
    }
    
    // --- Custom Color Section ---
    int customY = startY + gridHeight + 15;
    
    // Modern Input
    CreateEdit("CP_Edit_Custom", "#FFFFFF", startX, customY, 130, 30);
    ObjectSetInteger(0, PREFIX + "CP_Edit_Custom", OBJPROP_ZORDER, 201);
    ObjectSetInteger(0, PREFIX + "CP_Edit_Custom", OBJPROP_BGCOLOR, g_ColorInput);
    ObjectSetInteger(0, PREFIX + "CP_Edit_Custom", OBJPROP_COLOR, g_ColorText);
    ObjectSetInteger(0, PREFIX + "CP_Edit_Custom", OBJPROP_BORDER_COLOR, C'60,64,72');
    ObjectSetInteger(0, PREFIX + "CP_Edit_Custom", OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, PREFIX + "CP_Btn_Custom", OBJPROP_FONTSIZE, 8);
    ObjectSetString(0, PREFIX + "CP_Btn_Custom", OBJPROP_FONT, "Trebuchet MS Bold");
    ObjectSetInteger(0, PREFIX + "CP_Btn_Custom", OBJPROP_BORDER_COLOR, C'0,122,255');
}

//+------------------------------------------------------------------+
//| EVENT MANAGER                                                    |
//+------------------------------------------------------------------+
bool PanelSettings_OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(!g_PanelSettings.IsVisible && !g_IsColorPickerOpen) return false;
   
   // 1. SCROLL & DRAG
   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int mouseX = (int)lparam;
      int mouseY = (int)dparam;
      int buttons = (int)sparam;
      
      if((buttons & 1) == 1) // Dragging
      {
          // --- SCROLLBAR ---
          // Priorité: Si on drag déjà ou si on démarre
          bool canScroll = g_PanelSettings.IsVisible && !IsScrollDragging && !g_PanelMain.IsDragging;
          
          if(canScroll) 
          { 
             // Start or Continue
             if(g_ScrollSettings.IsDragging || (mouseX > g_PanelSettings.X + 300)) // Simplistic check, HandleScrollDrag does precise
             {
                 int maxScroll = g_ScrollSettings.ContentHeight - g_ScrollSettings.ViewportHeight;
                 if(maxScroll < 0) maxScroll = 0;
                 if(HandleScrollDrag(g_ScrollSettings.IsDragging, g_ScrollSettings.DragAnchorY, g_ScrollSettings.ScrollY, mouseX, mouseY, "Set_ScrollThumb", g_ScrollSettings.ViewportHeight, maxScroll))
                 {
                     OpenSettings(); return true;
                 }
             }
          }
          
          // --- PANEL DRAG ---
          if(g_PanelSettings.IsVisible && !g_ScrollSettings.IsDragging && !g_PanelMain.IsDragging)
          {
              if(HandlePanelDrag(g_PanelSettings.IsDragging, g_PanelSettings.X, g_PanelSettings.Y, g_PanelSettings.DragOffsetX, g_PanelSettings.DragOffsetY, mouseX, mouseY, 340, 50 + g_ScrollSettings.ViewportHeight))
              {
                 OpenSettings(); return true;
              }
          }
      }
      else // Mouse Up
      {
           if(g_PanelSettings.IsDragging) {
                int h = 50 + g_ScrollSettings.ViewportHeight;
                ApplyPanelSafety(g_PanelSettings.X, g_PanelSettings.Y, 340, h); 
                g_PanelSettings.IsDragging = false;
                OpenSettings();
                SaveConfigToFile();
                return true;
           }
           if(g_ScrollSettings.IsDragging) {
               g_ScrollSettings.IsDragging = false;
               g_BlockClick = true; 
               return true;
           }
      }
   }
   
   // 2. CLICKS
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
       // Basic Settings Buttons
       if(sparam == PREFIX + "Set_Btn_MgrPos")
       {
           g_ManagerPosition++;
           if(g_ManagerPosition > 5) g_ManagerPosition = 0;
           ObjectSetString(0, PREFIX + "Set_Btn_MgrPos", OBJPROP_TEXT, ManagerPositions[g_ManagerPosition]);
           UpdateManagerPanel(); 
           EffectButton(sparam);
           return true; 
       }
       
       // Color Picker Open
       if(StringFind(sparam, PREFIX + "Set_Btn_Color_") >= 0)
       {
          g_ColorPickerTarget = sparam;
          CreateColorPicker();
          return true;
       }
       
       // Color Picker Internals
       if(g_IsColorPickerOpen)
       {
           if(sparam == PREFIX + "CP_Btn_Custom")
           {
               string hexStr = ObjectGetString(0, PREFIX + "CP_Edit_Custom", OBJPROP_TEXT);
               color pickedCol = HexStringToColor(hexStr); 
               
               // Add to palette
               bool exists = false;
               for(int i=0; i<ArraySize(g_ColorPalette); i++) { if(g_ColorPalette[i] == pickedCol) { exists = true; break; } }
               if(!exists) {
                   int size = ArraySize(g_ColorPalette);
                   ArrayResize(g_ColorPalette, size + 1);
                   g_ColorPalette[size] = pickedCol;
                   CreateColorPicker(); ChartRedraw();
               }
               
               ApplyColorChange(pickedCol); 
               CloseColorPicker();
               return true;
           }
           
           if(StringFind(sparam, PREFIX + "CP_Item_") >= 0)
           {
               long pickedCol = ObjectGetInteger(0, sparam, OBJPROP_BGCOLOR);
               ApplyColorChange((color)pickedCol);
               CloseColorPicker();
               return true;
           }
           
           // Click Outside
           if(StringFind(sparam, PREFIX + "CP_") < 0)
           {
               CloseColorPicker();
               // Do NOT return true
           }
       }
   }
   
   // 3. EDIT EVENTS
   if(id == CHARTEVENT_OBJECT_ENDEDIT)
   {
       if(sparam == PREFIX + "Set_Edit_Risk") {
           double r = StringToDouble(ObjectGetString(0, PREFIX + "Set_Edit_Risk", OBJPROP_TEXT));
           if(r > 0) { g_DefaultRisk = r; SaveConfigToFile(); RefreshAllPanels(); }
           return true;
       }
       if(sparam == PREFIX + "Set_Edit_RiskMoney") {
           double r = StringToDouble(ObjectGetString(0, PREFIX + "Set_Edit_RiskMoney", OBJPROP_TEXT));
           if(r > 0) { g_DefaultRiskMoney = r; SaveConfigToFile(); RefreshAllPanels(); }
           return true;
       }
       if(sparam == PREFIX + "Set_Edit_RiskR") {
           double r = StringToDouble(ObjectGetString(0, PREFIX + "Set_Edit_RiskR", OBJPROP_TEXT));
           if(r > 0) { g_DefaultRiskR = r; SaveConfigToFile(); RefreshAllPanels(); }
           return true;
       }
       if(sparam == PREFIX + "Set_Edit_OneRPercent") {
           double r = StringToDouble(ObjectGetString(0, PREFIX + "Set_Edit_OneRPercent", OBJPROP_TEXT));
           if(r > 0) { g_OneRPercent = r; SaveConfigToFile(); RefreshAllPanels(); }
           return true;
       }
   }
   
   return false;
}
