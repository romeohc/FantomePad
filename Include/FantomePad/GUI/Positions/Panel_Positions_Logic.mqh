//+------------------------------------------------------------------+
//|                                       Panel_Positions_Logic.mqh  |
//|                                           FantomePad Project     |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| HELPER: VISUAL UPDATE FOR PARTIAL BUTTONS                        |
//+------------------------------------------------------------------+
void UpdatePartialButtonsVisuals()
{
   color activeCol = g_ColorBtnValid; // Fallback
   if(SelectedPositionTicket != -1 && OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
   {
      int type = OrderType();
      activeCol = (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP) ? g_ColorGreen : g_ColorRed;
   }

   // Button 25
   bool is25 = (g_PosPartialMode == 25);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_25", OBJPROP_BGCOLOR, is25 ? activeCol : g_ColorInput);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_25", OBJPROP_COLOR, is25 ? clrWhite : g_ColorText);
   
   // Button 50
   bool is50 = (g_PosPartialMode == 50);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_50", OBJPROP_BGCOLOR, is50 ? activeCol : g_ColorInput);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_50", OBJPROP_COLOR, is50 ? clrWhite : g_ColorText);

   // Button 100
   bool is100 = (g_PosPartialMode == 100);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_100", OBJPROP_BGCOLOR, is100 ? activeCol : g_ColorInput);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_100", OBJPROP_COLOR, is100 ? clrWhite : g_ColorText);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| MISE A JOUR DES VALEURS (TICK)                                   |
//+------------------------------------------------------------------+
void UpdatePositionsValues()
{
   if(!g_PanelPositions.IsVisible) return;
   
   if(SelectedPositionTicket != -1)
   {
      if(OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
      {
         if(OrderCloseTime() == 0 && OrderSymbol() == Symbol())
         {
             double lots = OrderLots();
             double profit = OrderProfit();
             double comm = OrderCommission();
             double swap = OrderSwap();
             double open = OrderOpenPrice();
             double sl = OrderStopLoss();
             double tp = OrderTakeProfit();
             
             ObjectSetString(0, PREFIX + "Pos_Val_Size", OBJPROP_TEXT, DoubleToString(lots, 2));
             
             string sProfit = DoubleToString(profit, 2) + " " + AccountCurrency();
             ObjectSetString(0, PREFIX + "Pos_Val_Profit", OBJPROP_TEXT, sProfit);
             ObjectSetInteger(0, PREFIX + "Pos_Val_Profit", OBJPROP_COLOR, (profit >= 0) ? g_ColorGreen : g_ColorRed);

             double bal = AccountBalance();
             double profitPrc = 0.0;
             double profitR = 0.0;
             if(bal > 0) profitPrc = (profit / bal) * 100.0;
             if(g_OneRPercent > 0) profitR = profitPrc / g_OneRPercent;
             
             string sProfitR = DoubleToString(profitR, 2) + " R";
             ObjectSetString(0, PREFIX + "Pos_Val_ProfitR", OBJPROP_TEXT, sProfitR);
             ObjectSetInteger(0, PREFIX + "Pos_Val_ProfitR", OBJPROP_COLOR, (profit >= 0) ? g_ColorGreen : g_ColorRed);

             string sProfitPrc = DoubleToString(profitPrc, 2) + "%";
             ObjectSetString(0, PREFIX + "Pos_Val_ProfitPrc", OBJPROP_TEXT, sProfitPrc);
             ObjectSetInteger(0, PREFIX + "Pos_Val_ProfitPrc", OBJPROP_COLOR, (profit >= 0) ? g_ColorGreen : g_ColorRed);
             
             string sComm = DoubleToString(comm, 2) + " " + AccountCurrency();
             ObjectSetString(0, PREFIX + "Pos_Val_Comm", OBJPROP_TEXT, sComm);
             
             string sSwap = DoubleToString(swap, 2) + " " + AccountCurrency();
             ObjectSetString(0, PREFIX + "Pos_Val_Swap", OBJPROP_TEXT, sSwap);
             
             // --- RISK CALCULATION ---
             string sRiskR = "-";
             string sRiskPrc = "-";
             
             if(sl > 0)
             {
                 double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
                 double tickVal  = MarketInfo(Symbol(), MODE_TICKVALUE);
                 if(tickSize > 0)
                 {
                     double dist = MathAbs(OrderOpenPrice() - sl);
                     double riskValMoney = (dist / tickSize) * tickVal * lots;
                     
                     bal = AccountBalance();
                     if(bal > 0) {
                        double riskPrc = (riskValMoney / bal) * 100.0;
                        sRiskPrc = DoubleToString(riskPrc, 2) + "%";
                        
                        if(g_OneRPercent > 0) {
                           double riskRVal = riskPrc / g_OneRPercent;
                           sRiskR = DoubleToString(riskRVal, 2) + " R";
                        }
                     }
                 }
             }
             else 
             {
                sRiskR = "-";
                sRiskPrc = "No SL";
             }
             
             ObjectSetString(0, PREFIX + "Pos_Val_RiskR", OBJPROP_TEXT, sRiskR);
             ObjectSetString(0, PREFIX + "Pos_Val_RiskPrc", OBJPROP_TEXT, sRiskPrc);
             
             bool ticketChanged = (SelectedPositionTicket != g_LastPosTicket);
             
             if(ticketChanged || MathAbs(sl - g_LastPosSL) > Point)
             {
                 ObjectSetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT, DoubleToString(sl, Digits));
                 g_LastPosSL = sl;
             }
             
             if(ticketChanged || MathAbs(tp - g_LastPosTP) > Point)
             {
                 ObjectSetString(0, PREFIX + "Pos_Edit_TP", OBJPROP_TEXT, DoubleToString(tp, Digits));
                 g_LastPosTP = tp;
             }
             
             if(ticketChanged || MathAbs(open - g_LastPosEntry) > Point)
             {
                 ObjectSetString(0, PREFIX + "Pos_Edit_Entry", OBJPROP_TEXT, DoubleToString(open, Digits));
                 g_LastPosEntry = open;
             }
             
             if(ticketChanged)
             {
                 g_PosBE_Active = false;
                 g_PosPartialMode = 0; // Reset Partial Mode
                 UpdatePartialButtonsVisuals(); // Visually reset
                 
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, g_ColorInput);
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, g_ColorText);
             }
             
             string typeStr = "";
             color typeBg = g_ColorInput;
             int type = OrderType();
             
             if(type == OP_BUY) { typeStr = "BUY MARKET"; typeBg = g_ColorGreen; }
             else if(type == OP_SELL) { typeStr = "SELL MARKET"; typeBg = g_ColorRed; }
             else if(type == OP_BUYLIMIT) { typeStr = "BUY LIMIT"; typeBg = g_ColorGreen; }
             else if(type == OP_SELLLIMIT) { typeStr = "SELL LIMIT"; typeBg = g_ColorRed; }
             else if(type == OP_BUYSTOP) { typeStr = "BUY STOP"; typeBg = g_ColorGreen; }
             else if(type == OP_SELLSTOP) { typeStr = "SELL STOP"; typeBg = g_ColorRed; }
             
             ObjectSetString(0, PREFIX + "Pos_Btn_Select", OBJPROP_TEXT, typeStr + " " + DoubleToString(lots, 2));
             ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_BGCOLOR, typeBg);
             ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_BORDER_COLOR, typeBg);
             ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_COLOR, clrWhite);
             
             // Enable/Disable Entry Price Edit based on Type
             if(type <= 1) // Market Order (OP_BUY=0, OP_SELL=1)
             {
                 ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_READONLY, true);
                 ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_BGCOLOR, g_ColorBtnInvalid); // INACTIVE COLOR
                 ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_COLOR, g_ColorText); 
             }
             else // Pending Order
             {
                 ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_READONLY, false);
                 ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_BGCOLOR, g_ColorInput);
                 ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_COLOR, g_ColorText);
             }
             
             // BE BUTTON STATE (IN LOSS CHECKS)
             double current = (type == OP_BUY) ? MarketInfo(OrderSymbol(), MODE_BID) : MarketInfo(OrderSymbol(), MODE_ASK);
             bool inLoss = (type == OP_BUY && current < open) || (type == OP_SELL && current > open);
             
             if(inLoss)
             {
                 g_PosBE_Active = false; // Force Disable
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, g_ColorBtnInvalid); // INACTIVE COLOR
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, g_ColorText); 
             }
             else if(!g_PosBE_Active)
             {
                 // If eligible but not active, ensure inputs color (normal state)
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, g_ColorInput);
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, g_ColorText);
             }
             
             // Update Validate Button State
             double userSL = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT));
             double userTP = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_TP", OBJPROP_TEXT));
             double userEntry = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_Entry", OBJPROP_TEXT));
             double userClose = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT));
             
             bool isModified = false;
             
             if(MathAbs(userSL - sl) > Point) isModified = true;
             if(MathAbs(userTP - tp) > Point) isModified = true;
             
             if(type > 1) 
             {
                 if(MathAbs(userEntry - open) > Point) isModified = true;
             }
             
             if(userClose > 0.001) isModified = true;
             if(g_PosPartialMode > 0) isModified = true; 
             if(g_PosBE_Active) isModified = true; 
             
             color valCol = g_ColorBtnInvalid;
             if(isModified)
             {
                 valCol = (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP) ? g_ColorGreen : g_ColorRed;
             }
             
             ObjectSetInteger(0, PREFIX + "Pos_Btn_Validate", OBJPROP_BGCOLOR, valCol);
             ObjectSetInteger(0, PREFIX + "Pos_Btn_Validate", OBJPROP_BORDER_COLOR, valCol);
             
             g_LastPosTicket = SelectedPositionTicket;
             return; 
         }
      }
      
      SelectedPositionTicket = -1;
      g_LastPosTicket = -1;
   }
   
   ObjectSetString(0, PREFIX + "Pos_Btn_Select", OBJPROP_TEXT, "Select Position...");
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_BGCOLOR, g_ColorInput);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_BORDER_COLOR, g_ColorInput);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_COLOR, g_ColorText);
   
   ObjectSetString(0, PREFIX + "Pos_Val_Size", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_Profit", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_ProfitR", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_ProfitPrc", OBJPROP_TEXT, "-");
   ObjectSetInteger(0, PREFIX + "Pos_Val_ProfitR", OBJPROP_COLOR, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Val_ProfitPrc", OBJPROP_COLOR, g_ColorText);
   ObjectSetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT, "0");
   ObjectSetString(0, PREFIX + "Pos_Edit_Entry", OBJPROP_TEXT, "0");
   ObjectSetString(0, PREFIX + "Pos_Edit_TP", OBJPROP_TEXT, "0");
   ObjectSetString(0, PREFIX + "Pos_Val_Comm", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_Swap", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_RiskR", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_RiskPrc", OBJPROP_TEXT, "-");
   ObjectSetInteger(0, PREFIX + "Pos_Val_Profit", OBJPROP_COLOR, g_ColorText);
   
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Validate", OBJPROP_BGCOLOR, g_ColorBtnInvalid);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Validate", OBJPROP_BORDER_COLOR, g_ColorBtnInvalid);
}
