//+------------------------------------------------------------------+
//|                                                Trade_Manager.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _TRADE_MANAGER_MQH_
#define _TRADE_MANAGER_MQH_

#include "Trade_Execution.mqh"
#include "Trade_Calculations.mqh"
#include "Trade_Lines.mqh"
#include "../GUI/Main/Panel_Main_Shared.mqh"

//+------------------------------------------------------------------+
//| HIGH LEVEL EXECUTION                                             |
//+------------------------------------------------------------------+
void ExecuteOrder(int cmd)
{
   // --- SAFETY CHECK: AUTO-TRADING & LIVE TRADING ---
   if(!IsExpertEnabled())
   {
      ShowValidationError("Auto-Trading is OFF!");
      return;
   }
   if(!IsTradeAllowed())
   {
      // If Expert is enabled but Trade is not allowed, it's usually the "Allow live trading" checkbox
      ShowValidationError("Live Trading disabled!");
      return;
   }

   string symbol = ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
   if(symbol == "") symbol = Symbol(); 
   
   double sl     = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
   double tp     = StringToDouble(ObjectGetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT));
   
   double volume = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Lot", OBJPROP_TEXT));
   
   if(volume <= 0) 
   {
      string errorMsg = "Lot size too small! Increase risk or tighten SL.";
      ShowValidationError(errorMsg);
      return; 
   } 
   
   double price  = 0;
   double digits = MarketInfo(symbol, MODE_DIGITS);
   
   if(cmd == OP_BUY)         price = MarketInfo(symbol, MODE_ASK);
   else if(cmd == OP_SELL)   price = MarketInfo(symbol, MODE_BID);
   else                      price = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT)); 
   
   price = NormalizeDouble(price, (int)digits);
   sl    = NormalizeDouble(sl, (int)digits);
   tp    = NormalizeDouble(tp, (int)digits);
   
   // --- SPREAD PROTECTION ---
   if(cmd == OP_BUY || cmd == OP_SELL)
   {
       double ask = MarketInfo(symbol, MODE_ASK);
       double bid = MarketInfo(symbol, MODE_BID);
       double spread = (ask - bid) / MarketInfo(symbol, MODE_POINT);
       
       if(spread > g_MaxSpread)
       {
            string errorMsg = "Spread too high (" + DoubleToString(spread, 0) + " > " + IntegerToString(g_MaxSpread) + ")!";
            ShowValidationError(errorMsg);
            return;
       }
   }
   
   int slippagePoints = (int)(MaxSlippage * MathPow(10, (digits == 3 || digits == 5) ? 1 : 0)); // Points
   int ticket = SafeOrderSend(symbol, cmd, volume, price, slippagePoints, sl, tp, "ProPanel", MagicNumber, 0, clrNONE);
   
   if(ticket >= 0) 
   {
      g_LastTradeErrorMsg = ""; // Clear on success
      
      // Reset UI after success
      ObjectSetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT, "0.00000");
      ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, "0.00000");
      ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, "0.0");
      ObjectSetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT, "0.00000");
      
      UpdateChartLines(); 
      UpdateOpenOrderLines();
      UpdateCalculatedLot(); 
      ChartRedraw();
   }
   else
   {
      if(g_LastTradeErrorMsg != "")
      {
         ShowValidationError(g_LastTradeErrorMsg);
         g_LastTradeErrorMsg = ""; // Reset after showing
      }
   }
}

#endif
