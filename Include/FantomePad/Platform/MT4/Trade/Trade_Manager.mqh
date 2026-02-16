//+------------------------------------------------------------------+
//|                                                Trade_Manager.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _TRADE_MANAGER_MQH_
#define _TRADE_MANAGER_MQH_

#include "Trade_Execution.mqh"
#include "Trade_Calculations.mqh"
#include "Trade_Lines.mqh"
#include "../../Common/GUI/Main/Panel_Main_Shared.mqh"

//+------------------------------------------------------------------+
//| HIGH LEVEL EXECUTION                                             |
//+------------------------------------------------------------------+
void ExecuteOrder(int cmd)
{
   // --- SAFETY CHECK: AUTO-TRADING & ACCOUNT ---
   if(AccountInfoInteger(ACCOUNT_LOGIN) == 0)
   {
       ShowValidationError("No Account Connected");
       return;
   }
   
   if(!IsExpertEnabled())
   {
      ShowValidationError("Auto-Trading is OFF!");
      return;
   }
   if(!IsTradeAllowed())
   {
      ShowValidationError("Live Trading disabled!");
      return;
   }

   string symbol = ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
   if(symbol == "") symbol = Symbol(); 
   
   double sl     = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
   double tp     = StringToDouble(ObjectGetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT));
   double volume = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Lot", OBJPROP_TEXT));
   
   double price  = 0;
   double digits = MarketInfo(symbol, MODE_DIGITS);
   
   if(cmd == OP_BUY)         price = MarketInfo(symbol, MODE_ASK);
   else if(cmd == OP_SELL)   price = MarketInfo(symbol, MODE_BID);
   else                      price = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT)); 
   
   price = NormalizeDouble(price, (int)digits);
   sl    = NormalizeDouble(sl, (int)digits);
   tp    = NormalizeDouble(tp, (int)digits);

   // --- SECURITY POINT 1: OBLIGATORY STOP LOSS (MOTEUR) ---
   if(sl <= 0 && (cmd == OP_BUY || cmd == OP_SELL))
   {
      ShowValidationError("Stop Loss non défini !");
      return;
   }

   if(volume <= 0) 
   {
      ShowValidationError("Lot size non défini !");
      return; 
   } 

   // --- SECURITY POINT 2: ROBUST INTERNAL RISK VALIDATION ---
   double tickSize = MarketInfo(symbol, MODE_TICKSIZE);
   double tickValue = MarketInfo(symbol, MODE_TICKVALUE);
   if(tickSize > 0 && tickValue > 0 && sl > 0)
   {
      double distance = MathAbs(price - sl);
      double steps = distance / tickSize;
      double riskMoney = volume * steps * tickValue;
      double equity = AccountEquity();
      double realRiskPercent = (equity > 0) ? (riskMoney / equity) * 100.0 : 0;
      
      if(realRiskPercent > g_MaxRiskPercent + 0.01) // Epsilon for rounding
      {
         string errorMsg = "SÉCURITÉ : Risque (" + DoubleToString(realRiskPercent, 2) + "%) > Max (" + DoubleToString(g_MaxRiskPercent, 2) + "%) !";
         ShowValidationError(errorMsg);
         return;
      }
   }

   // --- SECURITY POINT 3: TECHNICAL GUARDRAILS (LOTS & MARGIN) ---
   double maxLot = MarketInfo(symbol, MODE_MAXLOT);
   if(volume > maxLot)
   {
      ShowValidationError("Lot trop élevé pour le courtier (Max: " + DoubleToString(maxLot, 2) + ") !");
      return;
   }

   double requiredMargin = MarketInfo(symbol, MODE_MARGINREQUIRED) * volume;
   if(AccountFreeMargin() < requiredMargin)
   {
      ShowValidationError("Fonds insuffisants (Marge requise: " + DoubleToString(requiredMargin, 2) + ") !");
      return;
   }

   // --- SPREAD PROTECTION ---
   if(cmd == OP_BUY || cmd == OP_SELL)
   {
        double ask = MarketInfo(symbol, MODE_ASK);
        double bid = MarketInfo(symbol, MODE_BID);
        double spread = (ask - bid) / MarketInfo(symbol, MODE_POINT);
        
        if(spread > g_MaxSpread)
        {
             ShowValidationError("Spread trop élevé (" + DoubleToString(spread, 0) + " > " + IntegerToString(g_MaxSpread) + ")!");
             return;
        }
   }
   
   // --- BRIDGE MIGRATION: USE UNIFIED ENGINE ---
   // We skip SafeOrderSend (Legacy) and use the new Engine
   
   TradeResult result;
   
   if(cmd == OP_BUY || cmd == OP_SELL)
   {
      result = g_TradeEngine.OpenMarket(symbol, cmd, volume, price, sl, tp, "ProPanel", MagicNumber);
   }
   else 
   {
      // Pending Order (Use 0 expiration for GTC as per default)
      result = g_TradeEngine.OpenPending(symbol, cmd, volume, price, sl, tp, "ProPanel", MagicNumber, 0);
   }
   
   if(result.Success) 
   {
      g_LastTradeErrorMsg = ""; 
      
      // Reset UI after success
      ObjectSetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT, "0.00000");
      ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, "0.00000");
      ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, "0.0");
      ObjectSetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT, "0.00000"); // Reset price for pending too? YES
      
      UpdateChartLines(); 
      UpdateOpenOrderLines();
      UpdateCalculatedLot(); 
      ChartRedraw();
   }
   else
   {
      // If Engine failed, it printed errors. We can also show general error toast here if needed.
      if(result.Message != "") g_LastTradeErrorMsg = result.Message;
      else if(g_LastTradeErrorMsg == "") g_LastTradeErrorMsg = "Execution Failed"; // Fallback
      
      if(g_LastTradeErrorMsg != "")
      {
         ShowValidationError(g_LastTradeErrorMsg);
         g_LastTradeErrorMsg = ""; 
      }
   }

}

#endif
