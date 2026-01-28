//+------------------------------------------------------------------+
//|                                                Trade_Manager.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _TRADE_MANAGER_MQH_
#define _TRADE_MANAGER_MQH_

#include "Trade_Execution.mqh"
#include "Trade_Calculations.mqh"
#include "Trade_Lines.mqh"

//+------------------------------------------------------------------+
//| HIGH LEVEL EXECUTION                                             |
//+------------------------------------------------------------------+
void ExecuteOrder(int cmd)
{
   string symbol = ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
   if(symbol == "") symbol = Symbol(); 
   
   double sl     = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
   double tp     = StringToDouble(ObjectGetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT));
   
   double volume = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Lot", OBJPROP_TEXT));
   
   if(volume <= 0) 
   {
      HandleTradeMessage("Invalid Volume (" + DoubleToString(volume, 2) + ")", g_ColorRed);
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
   
   int slippagePoints = GetSlippagePoints(MaxSlippage);
   int ticket = SafeOrderSend(symbol, cmd, volume, price, slippagePoints, sl, tp, "ProPanel", MagicNumber, 0, clrNONE);
   
   if(ticket >= 0) 
   {
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
}

#endif
