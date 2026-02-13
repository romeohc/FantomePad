//+------------------------------------------------------------------+
//|                                      Handler_PositionActions.mqh |
//+------------------------------------------------------------------+
#property strict

bool Handle_PositionActions_Events(string sparam)
{
    // --- PARTIAL CLOSE SHORTCUTS ---
   if(sparam == PREFIX + "Pos_Btn_25") 
   {
	  if(SelectedPositionTicket == -1) return true;
      if(g_PosPartialMode == 25) g_PosPartialMode = 0; // Toggle Off
      else g_PosPartialMode = 25;
      
      ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "0"); // Reset custom text
      UpdatePartialButtonsVisuals();
      UpdatePositionsValues(); // For Validate Button
      EffectButton(sparam);
      return true; // Added return true even though original didn't return, assuming these are buttons
   }
   
   if(sparam == PREFIX + "Pos_Btn_50") 
   {
      if(SelectedPositionTicket == -1) return true;
      if(g_PosPartialMode == 50) g_PosPartialMode = 0; // Toggle Off
      else g_PosPartialMode = 50;
      
      ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "0");
      UpdatePartialButtonsVisuals();
      UpdatePositionsValues(); 
      EffectButton(sparam);
      return true;
   }
   
   if(sparam == PREFIX + "Pos_Btn_100") 
   {
      if(SelectedPositionTicket == -1) return true;
      if(g_PosPartialMode == 100) g_PosPartialMode = 0; // Toggle Off
      else g_PosPartialMode = 100;
      
      ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "0");
      UpdatePartialButtonsVisuals();
      UpdatePositionsValues(); 
      EffectButton(sparam);
      return true;
   }
   
   // --- BE BUTTON LOGIC ---
   if(sparam == PREFIX + "Pos_Btn_BE")
   {
      if(SelectedPositionTicket != -1 && OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
      {
          // Check Eligibility (Profit/Loss)
          int type = OrderType();
          double open = OrderOpenPrice();
          double current = (type == OP_BUY) ? MarketInfo(OrderSymbol(), MODE_BID) : MarketInfo(OrderSymbol(), MODE_ASK);
          
          // Strict check: In Loss = cannot BE
          bool inLoss = (type == OP_BUY && current < open) || (type == OP_SELL && current > open);
          
          if(inLoss) return true; // Cannot activate if in loss
          
          // Toggle
          g_PosBE_Active = !g_PosBE_Active;
          
          if(g_PosBE_Active)
          {
              // Activate BE
              color bg = (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP) ? g_ColorGreen : g_ColorRed;
              
              ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, bg);
              ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, clrWhite);
              ObjectSetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT, DoubleToString(open, _Digits));
          }
          else
          {
              // Deactivate BE -> Restore Original SL
              ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, g_ColorInput);
              ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, g_ColorText);
              ObjectSetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT, DoubleToString(OrderStopLoss(), _Digits));
          }
          
          UpdatePositionsValues(); // Trigger Validate Button Check
          EffectButton(sparam);
      }
      return true;
   }
   
   // --- VALIDATE ACTION ---
   if(sparam == PREFIX + "Pos_Btn_Validate")
   {
      EffectButton(sparam);
      
      // --- SAFETY CHECK: AUTO-TRADING & LIVE TRADING ---
      if(!IsExpertEnabled())
      {
         ShowPosValidationError("Auto-Trading is OFF!");
         return true;
      }
      if(!IsTradeAllowed())
      {
         ShowPosValidationError("Live Trading disabled!");
         return true;
      }

      // --- VALIDATION CHECKS ---
      // 1. Check if position is selected
      if(SelectedPositionTicket == -1)
      {
          ShowPosValidationError("No position selected!");
          ChartRedraw();
          return true;
      }
      
      // 2. Check if order can be selected
      if(!OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
      {
          ShowPosValidationError("Position not found!");
          ChartRedraw();
          return true;
      }
      
      // 3. Check if order is still open
      if(OrderCloseTime() != 0)
      {
          ShowPosValidationError("Position is already closed!");
          SelectedPositionTicket = -1;
          UpdatePositionsValues();
          ChartRedraw();
          return true;
      }
      
      // 4. Check if any modifications were made
      double currentSL = OrderStopLoss();
      double currentTP = OrderTakeProfit();
      double currentOpen = OrderOpenPrice();
      int orderType = OrderType();
      
      double userSL = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT));
      double userTP = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_TP", OBJPROP_TEXT));
      double userEntry = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_Entry", OBJPROP_TEXT));
      double userClose = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT));
      double pctFromText = userClose;
      
      // Use Button Mode if text is empty/zero
      if(pctFromText <= 0.001 && g_PosPartialMode > 0) pctFromText = (double)g_PosPartialMode;
      
      bool isModified = false;
      
      if(MathAbs(userSL - currentSL) > Point) isModified = true;
      if(MathAbs(userTP - currentTP) > Point) isModified = true;
      if(orderType > 1 && MathAbs(userEntry - currentOpen) > Point) isModified = true;
      if(pctFromText > 0.001) isModified = true;
      if(g_PosBE_Active) isModified = true;
      
      if(!isModified)
      {
          ShowPosValidationError("No modifications to apply!");
          ChartRedraw();
          return true;
      }
      
      // --- VALIDATION PASSED - HIDE ERROR AND PROCEED ---
      HidePosValidationError();
      
      if(SelectedPositionTicket != -1 && OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
      {
          if(OrderCloseTime() == 0) // Must be open
          {
              // 1. HANDLE CLOSE
              double pct = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT));
              
              // Use Button Mode if text is empty/zero
              if(pct <= 0.001 && g_PosPartialMode > 0) pct = (double)g_PosPartialMode;
              
              if(pct > 0)
              {
                  double currentLots = OrderLots();
                  double toClose = 0.0;
                  
                  // ALWAYS calc based on ORIGINAL lots (User Request)
                  double originLots = GetOriginalLotSize(SelectedPositionTicket);
                  if(originLots <= 0) originLots = currentLots; // Safety fallback
                  
                  toClose = originLots * (pct / 100.0);
                  
                  // Normalize Lots
                  double step = MarketInfo(OrderSymbol(), MODE_LOTSTEP);
                  double min = MarketInfo(OrderSymbol(), MODE_MINLOT);
                  
                  // Round to step
                  toClose = MathFloor(toClose / step) * step;
                  
                  if(toClose < min) toClose = min; // At least close min
                  if(toClose > currentLots) toClose = currentLots; // Max all
                  
                  // If 100%, ensure close all despite rounding issues
                  if(pct >= 99.9) toClose = currentLots; 
                  
                  // Close
                  int cmd = OrderType();
                  bool closed = false;
                  
                  if(cmd > 1) // Pending Order (Limit/Stop)
                  {
                     // For pending orders, "Close" means Delete. 
                     // We ignore the percentage (toClose), assuming user wants to remove the order.
                     closed = SafeOrderDelete(SelectedPositionTicket, clrGray);
                  }
                  else // Market Order
                  {
                     double closePrice = (cmd == OP_BUY) ? MarketInfo(OrderSymbol(), MODE_BID) : MarketInfo(OrderSymbol(), MODE_ASK);
                     closed = SafeOrderClose(SelectedPositionTicket, toClose, 0, 10, clrGray); // Use SafeOrderClose with auto-price (0)
                  }
                  if(closed)
                  {
                      ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "0"); // Reset
                      g_PosPartialMode = 0; 
                      UpdatePartialButtonsVisuals();
                      
                      UpdateOpenOrderLines(); // <--- INSTANT LINES UPDATE (FIXES LATENCY)
                      UpdateCalculatedLot();  // <--- RECALC NEW LOTS (EQUITY CHANGED)
                      
                      if(g_PanelAccount.IsVisible) CreateAccountPanel();       // <--- UPDATE BALANCE/EQUITY
                      if(g_PanelHistory.IsVisible) CreateHistoryPanel(); // <--- UPDATE HISTORY
                      
                      if(toClose >= currentLots) 
                      {
                          SelectedPositionTicket = -1; // Fully Closed
                          UpdatePositionsValues();
                          ChartRedraw();
                          return true; // Stop here
                      }
                      
                      // Re-select if partial
                      if(OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET)) {}
                  }
                  else
                  {
                      // Alert("Close Error: " + IntegerToString(GetLastError()));
                  }
              }
              
              // 2. HANDLE MODIFY (SL/TP)
              // Re-read incase partial close changed something (unlikely for SL/TP values but good practice)
              if(SelectedPositionTicket != -1 && OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
              {
                  currentSL = OrderStopLoss();
                  currentTP = OrderTakeProfit();
                  currentOpen = OrderOpenPrice();
                  
                  double inputSL = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT));
                  double inputTP = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_TP", OBJPROP_TEXT));
                  double inputOpen = currentOpen;

                  // Only update Entry Price for Pending Orders
                  if(OrderType() > 1) 
                  {
                     inputOpen = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_Entry", OBJPROP_TEXT));
                  }
                  
                  // Check if changed
                  // If BE Active, override Input SL
                  if(g_PosBE_Active)
                  {
                     inputSL = OrderOpenPrice();
                  }

                  if(MathAbs(inputSL - currentSL) > Point || MathAbs(inputTP - currentTP) > Point || MathAbs(inputOpen - currentOpen) > Point)
                  {
                      bool res = SafeOrderModify(SelectedPositionTicket, inputOpen, inputSL, inputTP, (datetime)0, clrBlue);
                      if(res)
                      {
                          g_LastPosSL = inputSL;
                          g_LastPosTP = inputTP;
                          g_LastPosEntry = inputOpen;
                          
                          UpdateOpenOrderLines(); // <--- INSTANT LINES UPDATE
                          
                          // Reset BE State
                          if(g_PosBE_Active)
                          {
                              g_PosBE_Active = false;
                              ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, g_ColorInput);
                              ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, g_ColorText);
                          }
                      }
                      else
                      {
                          // Alert("Modify Error: " + IntegerToString(GetLastError()));
                      }
                  }
              }
         }
      }
      
      UpdatePositionsValues();
      ChartRedraw();
      return true;
   }
   
   return false;
}
