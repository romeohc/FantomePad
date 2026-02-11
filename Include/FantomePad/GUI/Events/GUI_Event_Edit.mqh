//+------------------------------------------------------------------+
//|                                              GUI_Event_Edit.mqh  |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| EVENT: OBJECT END EDIT                                           |
//+------------------------------------------------------------------+
void OnEvent_EndEdit(string sparam)
{
   // RESET PARTIAL BUTTONS IF CUSTOM TEXT ENTERED
   if(sparam == PREFIX + "Pos_Edit_Close")
   {
      string txt = ObjectGetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT);
      double val = StringToDouble(txt);
      if(val > 0)
      {
          g_PosPartialMode = 0;
          UpdatePartialButtonsVisuals();
          
          if(StringFind(txt, "%") < 0)
          {
             ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, DoubleToString(val, 0) + "%");
          }
      }
      UpdatePositionsValues();
   }

   // INSTANT SAVE RISK
    // REMOVED DEFAULT RISK HANDLERS
   
   if(sparam == PREFIX + "Set_Edit_OneRPercent")
   {
       double r = StringToDouble(ObjectGetString(0, PREFIX + "Set_Edit_OneRPercent", OBJPROP_TEXT));
       if(r > 0) 
       {
          g_OneRPercent = r;
          SaveConfigToFile();
          CreatePanel(); 
          if(g_PanelMain.IsVisible) UpdateUIMode();
          else ToggleMainPanel(false);
       }
   }

   if(sparam == PREFIX + "Set_Edit_MaxRiskPercent")
   {
       double r = StringToDouble(ObjectGetString(0, PREFIX + "Set_Edit_MaxRiskPercent", OBJPROP_TEXT));
       if(r > 0) 
       {
          g_MaxRiskPercent = r;
          SaveConfigToFile();
       }
   }
   
   if(StringFind(sparam, PREFIX + "Edit_") >= 0)
   {
      // Validation: Ne pas autoriser les cellules vides pour SL, TP et Risk
      string currentText = ObjectGetString(0, sparam, OBJPROP_TEXT);
      StringTrimLeft(currentText);
      StringTrimRight(currentText);
      
      if(currentText == "")
      {
          if(sparam == PREFIX + "Edit_SL" || sparam == PREFIX + "Edit_TP" || sparam == PREFIX + "Edit_Risk")
          {
              ObjectSetString(0, sparam, OBJPROP_TEXT, "0");
          }
      }
      
      UpdateChartLines(); 
      AutoSwitchOrderType(); // Vérification logique après édition manuelle
      if(sparam == PREFIX + "Edit_Lot")
      {
           UpdateCalculatedRisk();
      }
      else
      {
           UpdateCalculatedLot();
      }
   }
   
   // --- UPDATE POSITION SL/TP (Old Auto Logic Removed) ---
   // We do nothing here now, waiting for Validate button.
   

   // --- HISTORY SYMBOL FILTER AUTO-UPDATE ---
   if(sparam == PREFIX + "Hist_Input_Symbol")
   {
       string sSym = ObjectGetString(0, PREFIX + "Hist_Input_Symbol", OBJPROP_TEXT);
       StringToUpper(sSym);
       StringTrimLeft(sSym);
       StringTrimRight(sSym);
       
       g_HistoryFilterSymbol = sSym;
       ObjectSetString(0, PREFIX + "Hist_Input_Symbol", OBJPROP_TEXT, g_HistoryFilterSymbol);
       
       UpdateHistoryFilter();
       CreateHistoryPanel();
   }

   // --- HISTORY CUSTOM DATE AUTO-UPDATE ---
   if(sparam == PREFIX + "Hist_Input_Start" || sparam == PREFIX + "Hist_Input_End")
   {
       string sStart = ObjectGetString(0, PREFIX + "Hist_Input_Start", OBJPROP_TEXT);
       string sEnd   = ObjectGetString(0, PREFIX + "Hist_Input_End", OBJPROP_TEXT);
       
       g_HistoryCustomStart = StringToTime(sStart);
       g_HistoryCustomEnd   = StringToTime(sEnd);
       
       UpdateHistoryFilter();
       CreateHistoryPanel(); // Redraw with new filter
   }
}

//+------------------------------------------------------------------+
//| EVENT: OBJECT DRAG                                               |
//+------------------------------------------------------------------+
void OnEvent_ObjectDrag(string sparam)
{
   bool dragged = false;
   
   if(sparam == PREFIX + "Line_SL")
   {
      double price = ObjectGetDouble(0, sparam, OBJPROP_PRICE1);
      ObjectSetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT, DoubleToString(price, _Digits));
      dragged = true;
   }
   if(sparam == PREFIX + "Line_TP")
   {
      double price = ObjectGetDouble(0, sparam, OBJPROP_PRICE1);
      ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, DoubleToString(price, _Digits));
      dragged = true;
   }
   if(sparam == PREFIX + "Line_Price")
   {
      double price = ObjectGetDouble(0, sparam, OBJPROP_PRICE1);
      ObjectSetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT, DoubleToString(price, _Digits));
      dragged = true;
   }
   
   if(dragged)
   {
      AutoSwitchOrderType(); // Vérification logique après drag
      UpdateCalculatedLot();
   }
}
