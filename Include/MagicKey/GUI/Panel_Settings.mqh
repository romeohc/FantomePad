//+------------------------------------------------------------------+
//|                                              Panel_Settings.mqh  |
//|                                                MagicKey Project  |
//+------------------------------------------------------------------+
#property strict

// Forward declarations helpers
void CreateColorRow(string suffix, string label, int x, int y, color col)
{
   CreateLabel("Set_Lbl_" + suffix, label, x, y + 4, 8, g_ColorLabel, "Trebuchet MS");
   ObjectSetInteger(0, PREFIX + "Set_Lbl_" + suffix, OBJPROP_ZORDER, 102);
   
   // Box at relative right of column (approx 130px width per col)
   int boxX = x + 110; 
   CreateButton("Set_Btn_Color_" + suffix, "", boxX, y, 25, 25, col, clrNONE);
   ObjectSetInteger(0, PREFIX + "Set_Btn_Color_" + suffix, OBJPROP_ZORDER, 102);
   ObjectSetInteger(0, PREFIX + "Set_Btn_Color_" + suffix, OBJPROP_BORDER_COLOR, C'100,100,100');
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
   
   int w = 340; // Wider for 2 columns
   int h = 580; // Taller to accommodate newly added Line options (SL/TP)
   
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
   ObjectSetInteger(0, PREFIX + "Set_Header", OBJPROP_ZORDER, 101);
   
   CreateLabel("Set_Title", "SETTINGS", x + 20, y + 15, 12, clrWhite, "Trebuchet MS Bold");
   ObjectSetInteger(0, PREFIX + "Set_Title", OBJPROP_ZORDER, 102);
   
   CreateButton("Set_Btn_Close", "X", x + w - 35, y + 12, 25, 25, g_ColorHeader, clrGray);
   ObjectSetInteger(0, PREFIX + "Set_Btn_Close", OBJPROP_ZORDER, 102);
   ObjectSetInteger(0, PREFIX + "Set_Btn_Close", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, PREFIX + "Set_Btn_Close", OBJPROP_BORDER_COLOR, g_ColorHeader);
   
   // --- CONTENT ---
   int curY = y + 70;
   int padX = 20;
   
   // 1. RISK
   CreateLabel("Set_Lbl_Cat1", "RISK MANAGEMENT", x + padX, curY, 9, C'100,100,100', "Trebuchet MS Bold");
   ObjectSetInteger(0, PREFIX + "Set_Lbl_Cat1", OBJPROP_ZORDER, 102);
   curY += 25;
   
   CreateLabel("Set_Lbl_Risk", "Default Risk (%)", x + padX, curY + 3, 9, g_ColorLabel, "Trebuchet MS");
   ObjectSetInteger(0, PREFIX + "Set_Lbl_Risk", OBJPROP_ZORDER, 102);
   
   CreateEdit("Set_Edit_Risk", DoubleToString(g_DefaultRisk, 1), x + w - 80, curY, 60, 25);
   ObjectSetInteger(0, PREFIX + "Set_Edit_Risk", OBJPROP_ZORDER, 102);
   ObjectSetInteger(0, PREFIX + "Set_Edit_Risk", OBJPROP_BGCOLOR, g_ColorInput);
   ObjectSetInteger(0, PREFIX + "Set_Edit_Risk", OBJPROP_COLOR, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Set_Edit_Risk", OBJPROP_BORDER_COLOR, C'60,64,72');
   ObjectSetInteger(0, PREFIX + "Set_Edit_Risk", OBJPROP_ALIGN, ALIGN_CENTER);
   
   curY += 40;
   CreateRect("Set_Sep1", x + padX, curY, w - (padX*2), 1, C'50,50,50', BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "Set_Sep1", OBJPROP_ZORDER, 102);
   curY += 20;

   // 2. COLORS
   CreateLabel("Set_Lbl_Cat2", "INTERFACE COLORS", x + padX, curY, 9, C'100,100,100', "Trebuchet MS Bold");
   ObjectSetInteger(0, PREFIX + "Set_Lbl_Cat2", OBJPROP_ZORDER, 102);
   curY += 30;
   
   // Columns
   int col1X = x + padX;
   int col2X = x + (w/2) + 10;
   int boxSize = 25;
   int rowH = 32;
   
   // Helper to create Color Row
   // Row 1: Backgrounds
   CreateColorRow("Bg",      "Panel Background",  col1X, curY, g_ColorBg);
   CreateColorRow("Head",    "Header Bar",        col2X, curY, g_ColorHeader);
   curY += rowH;
   
   // Row 2: Fields & Chart
   CreateColorRow("Input",   "Field Background",  col1X, curY, g_ColorInput);
   CreateColorRow("ChrtBg",  "Chart Background",  col2X, curY, g_ColorChartBg);
   curY += rowH;
   
   // Row 2.5: Chart Text
   CreateColorRow("ChrtFg",  "Chart Text",        col1X, curY, g_ColorChartFg);
   curY += rowH;

   // Row 3: Typography
   CreateColorRow("Txt",     "Primary Text",      col1X, curY, g_ColorText);
   CreateColorRow("Lbl",     "Secondary Labels",  col2X, curY, g_ColorLabel);
   curY += rowH;
   
   // Row 4: Trading
   CreateColorRow("Green",   "Buy (Long)",        col1X, curY, g_ColorGreen);
   CreateColorRow("Red",     "Sell (Short)",      col2X, curY, g_ColorRed);
   curY += rowH;
   
   // Row 4.5: Entry Line & SL Line
   CreateColorRow("EntLine", "Entry Line",        col1X, curY, g_ColorEntryLine);
   CreateColorRow("SLLine",  "Stop Loss Line",    col2X, curY, g_ColorSLLine);
   curY += rowH;

   // Row 4.8: TP Line
   CreateColorRow("TPLine",  "Take Profit Line",  col1X, curY, g_ColorTPLine);
   curY += rowH;

   // Row 5: Chart Candles
   CreateColorRow("CUp",     "Candle Up",         col1X, curY, g_ColorCandleUp);
   CreateColorRow("CDown",   "Candle Down",       col2X, curY, g_ColorCandleDown);
   curY += rowH;

   // Row 6: Actions
   CreateColorRow("BtnVal",  "Button Valid",      col1X, curY, g_ColorBtnValid);
   CreateColorRow("BtnInv",  "Button Invalid",    col2X, curY, g_ColorBtnInvalid);
}

void ToggleSettings()
{
   if(IsSettingsOpen) CloseSettings();
   else OpenSettings();
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
   int x = (chartW/2) - (w/2) + 20; // Slight offset from settings
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
