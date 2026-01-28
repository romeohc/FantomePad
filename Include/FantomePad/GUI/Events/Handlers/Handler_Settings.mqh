//+------------------------------------------------------------------+
//|                                             Handler_Settings.mqh |
//+------------------------------------------------------------------+
#property strict

bool Handle_Settings_Events(string sparam)
{
   // --- TOGGLE RISK MODE (% / CURRENCY) ---
   if(sparam == PREFIX + "Label_RiskPerc")
   {
      RiskMode++;
      if(RiskMode > 2) RiskMode = 0;
      
      // RESET to Default Value
      if(RiskMode == 1) // Currency
      {
         ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, "0");
      }
      else if(RiskMode == 2) // R
      {
          ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, "0");
      }
      else // %
      {
         ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, "0");
      }
      
      UpdateUIMode();
      UpdateCalculatedLot();
      // Petit effet visuel
      EffectButton(sparam);
      return true;
   }
   
   // --- SETTINGS ---
   if(sparam == PREFIX + "Set_Btn_NavPos")
   {
       g_NavigationPosition++;
       if(g_NavigationPosition > 5) g_NavigationPosition = 0;
       
       // Update Text
       ObjectSetString(0, PREFIX + "Set_Btn_NavPos", OBJPROP_TEXT, NavigationPositions[g_NavigationPosition]);
       
       // Update Real Panel
       UpdateNavigationPanel();
       EffectButton(sparam);
       return true;
   }

   if(sparam == PREFIX + "Set_Btn_ShowLines")
   {
       g_ShowOrderLines = !g_ShowOrderLines;
       
       // Update Text/Visuals
       string t = g_ShowOrderLines ? "ON" : "OFF";
       color b = g_ShowOrderLines ? g_ColorBtnActive : g_ColorInput;
       ObjectSetString(0, PREFIX + "Set_Btn_ShowLines", OBJPROP_TEXT, t);
       ObjectSetInteger(0, PREFIX + "Set_Btn_ShowLines", OBJPROP_BGCOLOR, b);
       
       UpdateChartLines(); 
       EffectButton(sparam);
       SaveConfigToFile();
       return true;
   }

   if(sparam == PREFIX + "Set_Btn_ShowPosLines")
   {
       g_ShowPositionLines = !g_ShowPositionLines;
       
       // Update Text/Visuals
       string t2 = g_ShowPositionLines ? "ON" : "OFF";
       color b2 = g_ShowPositionLines ? g_ColorBtnActive : g_ColorInput;
       ObjectSetString(0, PREFIX + "Set_Btn_ShowPosLines", OBJPROP_TEXT, t2);
       ObjectSetInteger(0, PREFIX + "Set_Btn_ShowPosLines", OBJPROP_BGCOLOR, b2);
       
       UpdateOpenOrderLines(); // Refresh the open position lines
       EffectButton(sparam);
       SaveConfigToFile();
       return true;
   }
   
   return false;
}
