//+------------------------------------------------------------------+
//|                                         Settings_ColorPicker.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

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
    
    int inputW = 100;
    int btnW = 60;
    int spacing = 10;
    
    // Centering the group (input + button)
    // total group width = inputW + spacing + btnW
    int groupW = inputW + spacing + btnW;
    int groupX = x + (w - groupW) / 2;
    
    // Input
    CreateEdit("CP_Edit_Custom", "#FFFFFF", groupX, customY, inputW, 30);
    ObjectSetInteger(0, PREFIX + "CP_Edit_Custom", OBJPROP_ZORDER, 201);
    ObjectSetInteger(0, PREFIX + "CP_Edit_Custom", OBJPROP_BGCOLOR, g_ColorInput);
    ObjectSetInteger(0, PREFIX + "CP_Edit_Custom", OBJPROP_COLOR, g_ColorText);
    ObjectSetInteger(0, PREFIX + "CP_Edit_Custom", OBJPROP_BORDER_COLOR, C'60,64,72');
    ObjectSetInteger(0, PREFIX + "CP_Edit_Custom", OBJPROP_ALIGN, ALIGN_CENTER);
    
    // Button
    CreateButton("CP_Btn_Custom", "ADD", groupX + inputW + spacing, customY, btnW, 30, g_ColorBtnActive, g_ColorText);
    ObjectSetInteger(0, PREFIX + "CP_Btn_Custom", OBJPROP_ZORDER, 201);
    ObjectSetInteger(0, PREFIX + "CP_Btn_Custom", OBJPROP_BORDER_COLOR, C'0,122,255');
    ObjectSetInteger(0, PREFIX + "CP_Btn_Custom", OBJPROP_FONTSIZE, 8);
    ObjectSetString(0, PREFIX + "CP_Btn_Custom", OBJPROP_FONT, "Trebuchet MS Bold");
}
