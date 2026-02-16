//+------------------------------------------------------------------+
//|                                         TradeUIInteraction.mqh |
//|                                              FantomePad Project  |
//|                                       UI Interaction Logic       |
//+------------------------------------------------------------------+
#ifndef _TRADE_UI_INTERACTION_MQH_
#define _TRADE_UI_INTERACTION_MQH_

#include "TradeCalc.mqh"
#include "TradeVisuals.mqh"
#include "../../GUI/GraphicWrappers.mqh"

// ===================================================================
// UI INTERACTION LOGIC (Reads/Writes UI)
// ===================================================================

void UpdateCalculatedLot()
{
   string symbol = FP_ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
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
      entry = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT));
   }
   
   double sl = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
   double risk = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));
   
   // Updated call signature for CalculateLotSize
   double lots = CalculateLotSize(symbol, entry, sl, risk);
   FP_ObjectSetString(0, PREFIX + "Edit_Lot", OBJPROP_TEXT, DoubleToString(lots, 2));

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
         FP_ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_BGCOLOR, c);
         FP_ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_BORDER_COLOR, c);
      }
      else
      {
         color c = isValid ? g_ColorBtnActive : g_ColorBtnInvalid;
         FP_ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_BGCOLOR, c);
         FP_ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_BORDER_COLOR, c);
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
       FP_ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_BGCOLOR, actionCol);
       FP_ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_BORDER_COLOR, actionCol);
   }
}

void UpdateCalculatedRisk()
{
   string symbol = FP_ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
   if(symbol == "") symbol = Symbol();
   
   double entry = 0;
   // Note: Unused variables currentBid/currentAsk were removed unless needed.
   // Wait, original code calculated them but didn't use them? 
   // Original:
   // double currentBid = MarketInfo(symbol, MODE_BID);
   // double currentAsk = MarketInfo(symbol, MODE_ASK);
   // if(CurrentTypeIndex == 0) { if(dir==0) entry=currentAsk ... }
   
   double currentBid = MarketInfo(symbol, MODE_BID);
   double currentAsk = MarketInfo(symbol, MODE_ASK);
   
   if(CurrentTypeIndex == 0) // Market
   {
      if(CurrentDirection == 0) entry = currentAsk;
      else                      entry = currentBid;
   }
   else
   {
      entry = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT));
   }
   
   double sl = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
   double lots = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_Lot", OBJPROP_TEXT));
   
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
   
   FP_ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, DoubleToString(calculatedRiskVal, 2));
}

// Returns TRUE if the Order Type/Direction was automatically switched.
// The Caller is responsible for calling UpdateUIMode() if returns true.
bool AutoSwitchOrderType()
{
   double sl    = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
   double tp    = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT));
   double entry = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT));
   
   if(sl <= 0) return false;
   
   string symbol = FP_ObjectGetString(0, PREFIX + "Nav_Btn_SymbolSelect", OBJPROP_TEXT);
   if(symbol == "") symbol = Symbol();
   
   double bid = MarketInfo(symbol, MODE_BID);
   double ask = MarketInfo(symbol, MODE_ASK);
   
   bool changed = false;
   
   if(CurrentTypeIndex == 0) // Market
   {
      if(sl < bid && CurrentDirection == 1) // SL is below Bid, but we were Selling -> Switch to Buy
      {
         CurrentDirection = 0;
         changed = true;
      }
      else if(sl > ask && CurrentDirection == 0) // SL is above Ask, but we were Buying -> Switch to Sell
      {
         CurrentDirection = 1;
         changed = true;
      }
      
      // Auto-Adjust TP if it becomes invalid (wrong side of SL)
      if(tp > 0)
      {
         if(CurrentDirection == 0 && tp <= sl) 
         {
            double minDist = 100 * MarketInfo(symbol, MODE_POINT);
            tp = sl + minDist; 
            FP_ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, DoubleToString(tp, (int)MarketInfo(symbol, MODE_DIGITS)));
            UpdateChartLines();
         }
         else if(CurrentDirection == 1 && tp >= sl)
         {
            double minDist = 100 * MarketInfo(symbol, MODE_POINT);
            tp = sl - minDist;
            FP_ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, DoubleToString(tp, (int)MarketInfo(symbol, MODE_DIGITS)));
            UpdateChartLines();
         }
      }
   }
   else // Pending
   {
      if(entry > 0)
      {
         int targetDirection = -1;
         if(sl < entry) targetDirection = 0; // SL below Entry = Buy
         else           targetDirection = 1; // SL above Entry = Sell
         
         int targetType = -1;
         if(targetDirection == 0) // Buy
         {
            if(entry < ask) targetType = 1; // Buy Limit (Below current)
            else            targetType = 3; // Buy Stop (Above current)
         }
         else // Sell
         {
             if(entry > bid) targetType = 2; // Sell Limit (Above current)
             else            targetType = 4; // Sell Stop (Below current)
         }
         
         if(targetType != -1 && targetType != CurrentTypeIndex)
         {
            CurrentTypeIndex = targetType;
            if(targetType == 1 || targetType == 3) CurrentDirection = 0;
            else                                   CurrentDirection = 1;
            changed = true;
         }
         
         // Auto-Adjust TP
         if(tp > 0)
         {
             if(CurrentDirection == 0 && tp <= sl)
             {
                 double minDist = 100 * MarketInfo(symbol, MODE_POINT);
                 tp = sl + minDist;
                 FP_ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, DoubleToString(tp, (int)MarketInfo(symbol, MODE_DIGITS)));
                 UpdateChartLines();
             }
             else if(CurrentDirection == 1 && tp >= sl)
             {
                 double minDist = 100 * MarketInfo(symbol, MODE_POINT);
                 tp = sl - minDist;
                 FP_ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, DoubleToString(tp, (int)MarketInfo(symbol, MODE_DIGITS)));
                 UpdateChartLines();
             }
         }
      }
   }
   
   if(changed)
   {
      UpdateCalculatedLot();
      ChartRedraw();
   }
   
   return changed;
}

#endif
