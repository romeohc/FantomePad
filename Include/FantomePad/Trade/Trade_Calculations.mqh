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
double GetRiskPercentage(double riskValue)
{
   if(riskValue <= 0) return 0.0;
   
   if(RiskMode == 0) // Percentage
   {
      return riskValue;
   }
   else if(RiskMode == 1) // Currency
   {
      // Convert Amount to % of Equity
      // Using Equity for safer risk management
      double eq = AccountEquity();
      if(eq <= 0) return 0.0;
      return (riskValue / eq) * 100.0;
   }
   else if(RiskMode == 2) // Risk R
   {
      // R is multiplier of OneRPercent
      return riskValue * g_OneRPercent;
   }
   
   return 0.0;
}

// Security Check: Validate that SL is on the correct side of Entry
// Returns true if SL is valid directionally (Below Entry for BUY, Above for SELL)
bool ValidateSlDirection(int cmd, double entry, double sl)
{
   if(entry <= 0 || sl <= 0) return true; // Let other validation handle zero values
   
   if(cmd == OP_BUY || cmd == OP_BUYLIMIT || cmd == OP_BUYSTOP)
   {
      return (sl < entry);
   }
   else if(cmd == OP_SELL || cmd == OP_SELLLIMIT || cmd == OP_SELLSTOP)
   {
      return (sl > entry);
   }
   return true;
}

double CalculateLotSize(double entryPrice, double slPrice, double riskValue)
{
   if(entryPrice <= 0 || slPrice <= 0 || riskValue <= 0) return 0.0;
   if(AccountEquity() <= 0) return 0.0;
   if(MathAbs(entryPrice - slPrice) <= Point) return 0.0;
   
   string symbol = ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
   if(symbol == "") symbol = Symbol();
   
   double tickSize   = MarketInfo(symbol, MODE_TICKSIZE);
   double tickValue  = MarketInfo(symbol, MODE_TICKVALUE);
   double lotStep    = MarketInfo(symbol, MODE_LOTSTEP);
   double minLot     = MarketInfo(symbol, MODE_MINLOT);
   double maxLot     = MarketInfo(symbol, MODE_MAXLOT);
   
   if(tickSize <= 0 || tickValue <= 0 || lotStep <= 0) return 0.0;
   
   double riskMoney = 0;
   
   if(RiskMode == 1) // Currency
   {
      riskMoney = riskValue;
   }
   else if(RiskMode == 2) // Risk R
   {
        double riskPrc = riskValue * g_OneRPercent;
        riskMoney = AccountEquity() * (riskPrc / 100.0);
   }
   else // Percentage
   {
      riskMoney = AccountEquity() * (riskValue / 100.0);
   }
   
   double distance = MathAbs(entryPrice - slPrice);
   double steps = distance / tickSize;
   double lotSize = riskMoney / (steps * tickValue);
   
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   
   if(lotSize < minLot) return 0.0; 
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
   
   double lots = CalculateLotSize(entry, sl, risk);
   ObjectSetString(0, PREFIX + "Edit_Lot", OBJPROP_TEXT, DoubleToString(lots, 2));

   // UI Update (Buttons colors)
   if(CurrentTypeIndex == 0)
   {
      bool isValid = (sl > 0 && risk > 0 && lots > 0);
      
      // Check Max Risk
      double rPrc = GetRiskPercentage(risk);
      if(rPrc > g_MaxRiskPercent) isValid = false;

      if(CurrentDirection == 0)
      {
         color c = isValid ? g_ColorBtnActive : g_ColorBtnInvalid;
         ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_BGCOLOR, c);
         ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_BORDER_COLOR, c);
      }
      else
      {
         color c = isValid ? g_ColorBtnActive : g_ColorBtnInvalid;
         ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_BGCOLOR, c);
         ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_BORDER_COLOR, c);
      }
   }
   else
   {
       bool isValid = (sl > 0 && risk > 0 && entry > 0 && lots > 0);
       
       // Check Max Risk
       double rPrc = GetRiskPercentage(risk);
       if(rPrc > g_MaxRiskPercent) isValid = false;
       
       color actionCol = g_ColorBtnInvalid;
       if(isValid)
       {
          actionCol = g_ColorBtnActive;
       }
       ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_BGCOLOR, actionCol);
       ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_BORDER_COLOR, actionCol);
   }
}

void UpdateCalculatedRisk()
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
   double lots = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Lot", OBJPROP_TEXT));
   
   if(lots <= 0 || AccountEquity() <= 0) return;
   if(MathAbs(entry - sl) <= Point) return;

   double tickSize   = MarketInfo(symbol, MODE_TICKSIZE);
   double tickValue  = MarketInfo(symbol, MODE_TICKVALUE);
   
   if(tickSize == 0 || tickValue == 0) return;
   
   double distance = MathAbs(entry - sl);
   double steps = distance / tickSize;
   
   // Risk Money = Lot * Steps * TickValue
   double riskMoney = lots * steps * tickValue;
   
   double calculatedRiskVal = 0;
   
   if(RiskMode == 1) // Currency
   {
      calculatedRiskVal = riskMoney;
   }
   else if(RiskMode == 2) // Risk R
   {
       if(g_OneRPercent > 0)
         calculatedRiskVal = (riskMoney / AccountEquity()) * 100.0 / g_OneRPercent;
   }
   else // Percentage
   {
      calculatedRiskVal = (riskMoney / AccountEquity()) * 100.0;
   }
   
   ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, DoubleToString(calculatedRiskVal, 2));
}

#endif
