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
        string hexStr = FP_ObjectGetString(0, PREFIX + "CP_Edit_Custom", OBJPROP_TEXT);
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
       color pickedCol = (color)FP_ObjectGetInteger(0, sparam, OBJPROP_BGCOLOR);
       ApplyColorChange(pickedCol);
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
