//+------------------------------------------------------------------+
//|                                          Handler_ColorPicker.mqh |
//+------------------------------------------------------------------+
#property strict

bool Handle_ColorPicker_Events(string sparam)
{
   // --- COLOR PICKER EVENTS ---
   // 1. Click on a Settings Color Button -> Open Picker
   if(StringFind(sparam, PREFIX + "Set_Btn_Color_") >= 0)
   {
      g_ColorPickerTarget = sparam;
      CreateColorPicker();
      return true;
   }
    // 2. Clic sur le bouton de couleur personnalisée
    if(sparam == PREFIX + "CP_Btn_Custom")
    {
        string hexStr = ObjectGetString(0, PREFIX + "CP_Edit_Custom", OBJPROP_TEXT);
        color pickedCol = HexStringToColor(hexStr);
        
        // --- ADD TO PALETTE IF NEW ---
        bool exists = false;
        for(int i=0; i<ArraySize(g_ColorPalette); i++) {
           if(g_ColorPalette[i] == pickedCol) { exists = true; break; }
        }
        
        if(!exists) {
           int size = ArraySize(g_ColorPalette);
           ArrayResize(g_ColorPalette, size + 1);
           g_ColorPalette[size] = pickedCol;
           
           // Redraw Picker to show new color in list immediately
           CreateColorPicker();
           ChartRedraw();
        }
        
        ApplyColorChange(pickedCol);
        CloseColorPicker();
        return true;
    }

    // 3. Click on a Color Picker Item -> Apply & Close
    if(StringFind(sparam, PREFIX + "CP_Item_") >= 0)
   {
      long pickedCol = ObjectGetInteger(0, sparam, OBJPROP_BGCOLOR);
      if(g_ColorPickerTarget != "")
      {
         ObjectSetInteger(0, g_ColorPickerTarget, OBJPROP_BGCOLOR, pickedCol);
         ObjectSetInteger(0, g_ColorPickerTarget, OBJPROP_BORDER_COLOR, pickedCol);
         
         // --- INSTANT SAVE ---
         if(StringFind(g_ColorPickerTarget, "_Bg") > 0)          g_ColorBg = (color)pickedCol;
         if(StringFind(g_ColorPickerTarget, "_Head") > 0)        g_ColorHeader = (color)pickedCol;
         if(StringFind(g_ColorPickerTarget, "_Input") > 0)       g_ColorInput = (color)pickedCol;
         if(StringFind(g_ColorPickerTarget, "_Txt") > 0)         g_ColorText = (color)pickedCol;
         // g_ColorLabel removed
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
         
         // 1. Refresh Main Panel
         CreatePanel(); 
         if(g_PanelMain.IsVisible) UpdateUIMode();
         else ToggleMainPanel(false); // Ensure phantom objects are hidden
         
         // 2. Refresh Account Panel
         CreateAccountPanel(); 
         if(!g_PanelAccount.IsVisible) ToggleAccountPanel(false);
         
         // 3. Refresh Other Panels
         CreateNavigationPanel();
         CreatePositionsPanel(); // Handles visibility internally
         CreateHistoryPanel(); // Handles visibility internally
         
         OpenSettings(); // Refresh Settings (incl. bg)
      }
      CloseColorPicker();
      return true;
   }
   
   // 4. CLICK OUTSIDE CHECK (For Color Picker)
    if(g_IsColorPickerOpen)
    {
        // If the clicked object is NOT part of the Color Picker
        if(StringFind(sparam, PREFIX + "CP_") < 0)
        {
            CloseColorPicker();
            // Do NOT return, as the user might have clicked on another valid button (like Buy/Sell)
            return false;
        }
    }
    
    return false;
}
