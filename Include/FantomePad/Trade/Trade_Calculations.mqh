//+------------------------------------------------------------------+
//|                                            Trade_Calculations.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _TRADE_CALCULATIONS_MQH_
#define _TRADE_CALCULATIONS_MQH_

#include "../Core/Defines.mqh"

//+------------------------------------------------------------------+
//| CALCULATIONS                                                     |
//+------------------------------------------------------------------+
double CalculateLotSize(double entryPrice, double slPrice, double riskValue)
{
   if(entryPrice <= 0 || slPrice <= 0 || riskValue <= 0) return 0.0;
   if(MathAbs(entryPrice - slPrice) <= Point) return 0.0;
   
   string symbol = ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
   if(symbol == "") symbol = Symbol();
   
   double tickSize   = MarketInfo(symbol, MODE_TICKSIZE);
   double tickValue  = MarketInfo(symbol, MODE_TICKVALUE);
   double lotStep    = MarketInfo(symbol, MODE_LOTSTEP);
   double minLot     = MarketInfo(symbol, MODE_MINLOT);
   double maxLot     = MarketInfo(symbol, MODE_MAXLOT);
   
   if(tickSize == 0 || tickValue == 0) return 0.0;
   
   double riskMoney = 0;
   
   if(RiskMode == 1) // Currency
   {
      riskMoney = riskValue;
   }
   else if(RiskMode == 2) // Risk R
   {
        double riskPrc = riskValue * g_OneRPercent;
        riskMoney = AccountBalance() * (riskPrc / 100.0);
   }
   else // Percentage
   {
      riskMoney = AccountEquity() * (riskValue / 100.0);
   }
   
   double distance = MathAbs(entryPrice - slPrice);
   double steps = distance / tickSize;
   double lotSize = riskMoney / (steps * tickValue);
   
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   
   if(lotSize < minLot) lotSize = minLot; 
   if(lotSize > maxLot) lotSize = maxLot;
   
   return lotSize;
}

void UpdateCalculatedLot()
{
   string symbol = ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
   if(symbol == "") symbol = Symbol();
   
   double entry = 0;
   double currentBid = MarketInfo(symbol, MODE_BID);
   double currentAsk = MarketInfo(symbol, MODE_ASK);
   
   if(CurrentTypeIndex == 0) // Market
   {
      if(CurrentDirection == 0) entry = currentAsk;
      else                      entry = currentBid;
   }
   else
   {
      entry = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT));
   }
   
   double sl = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
   double risk = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));
   
   // UI Update (Buttons colors)
   if(CurrentTypeIndex == 0)
   {
      bool isValid = (sl > 0 && risk > 0);
      if(CurrentDirection == 0)
      {
         color c = isValid ? g_ColorGreen : g_ColorBtnInvalid;
         ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_BGCOLOR, c);
         ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_BORDER_COLOR, c);
      }
      else
      {
         color c = isValid ? g_ColorRed : g_ColorBtnInvalid;
         ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_BGCOLOR, c);
         ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_BORDER_COLOR, c);
      }
   }
   else
   {
       bool isValid = (sl > 0 && risk > 0 && entry > 0);
       color actionCol = g_ColorBtnInvalid;
       if(isValid)
       {
          if(CurrentTypeIndex == 1 || CurrentTypeIndex == 3) actionCol = g_ColorGreen;
          else if(CurrentTypeIndex == 2 || CurrentTypeIndex == 4) actionCol = g_ColorRed;
          else actionCol = g_ColorBtnValid;
       }
       ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_BGCOLOR, actionCol);
       ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_BORDER_COLOR, actionCol);
   }
   
   double lots = CalculateLotSize(entry, sl, risk);
   ObjectSetString(0, PREFIX + "Edit_Lot", OBJPROP_TEXT, DoubleToString(lots, 2));
}

#endif
