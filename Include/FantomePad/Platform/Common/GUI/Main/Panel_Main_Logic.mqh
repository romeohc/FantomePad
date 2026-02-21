//+------------------------------------------------------------------+
//|                                           Panel_Main_Logic.mqh   |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _PANEL_MAIN_LOGIC_MQH_
#define _PANEL_MAIN_LOGIC_MQH_
#property strict

#include "Panel_Main_Shared.mqh"

// Cross-file logic implemented here

//+------------------------------------------------------------------+
//| VISIBLE CHART PRICE RANGE HELPER                                 |
//+------------------------------------------------------------------+
void GetVisibleChartPriceRange(double &priceMin, double &priceMax)
{
   int firstVisibleBar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
   int barsVisible = (int)ChartGetInteger(0, CHART_WIDTH_IN_BARS);
   
   int lastVisibleBar = firstVisibleBar - barsVisible;
   if(lastVisibleBar < 0) lastVisibleBar = 0;
   
   double highest = -1e10;
   double lowest  = 1e10;
   
   for(int i = lastVisibleBar; i <= firstVisibleBar && i < Bars; i++)
   {
      double h = iHigh(Symbol(), Period(), i);
      double l = iLow(Symbol(), Period(), i);
      if(h > highest) highest = h;
      if(l < lowest)  lowest = l;
   }
   
   if(highest < lowest)
   {
      highest = Ask + 100 * Point;
      lowest = Bid - 100 * Point;
   }
   
   priceMin = lowest;
   priceMax = highest;
}

// AutoSwitchOrderType is now in Common/Core/TradeLogic.mqh
// The global logic is reused.
// The caller should invoke UpdateUIMode() if needed.


//+------------------------------------------------------------------+
//| APPLY DEFAULT VALUES (Entry/SL/TP)                               |
//+------------------------------------------------------------------+
void ApplyDefaultTradeValues()
{
   string symbol = ObjectGetString(0, PREFIX + "Nav_Btn_SymbolSelect", OBJPROP_TEXT);
   if(symbol == "") symbol = Symbol();
   
   double bid = MarketInfo(symbol, MODE_BID);
   double ask = MarketInfo(symbol, MODE_ASK);
   double point = MarketInfo(symbol, MODE_POINT);
   int digits = (int)MarketInfo(symbol, MODE_DIGITS);
   
   if(point == 0) return;
   
   double priceMin, priceMax;
   GetVisibleChartPriceRange(priceMin, priceMax);
   
   double visibleRange = priceMax - priceMin;
   double proportionEntry = 0.05;
   double proportionSL = 0.15;
   double proportionTP = 0.25;
   
   double distEntry = visibleRange * proportionEntry;
   double distSL = visibleRange * proportionSL;  
   double distTP = visibleRange * proportionTP;
   
   double minDist = 100 * point;
   if(distEntry < minDist) distEntry = minDist;
   if(distSL < minDist * 2) distSL = minDist * 2;
   if(distTP < minDist * 3) distTP = minDist * 3;
   
   double entry = 0, sl = 0, tp = 0;
   
   if(CurrentTypeIndex == 0)
   {
       if(CurrentDirection == 0) entry = ask;
       else                      entry = bid;
   }
   else if(CurrentTypeIndex == 1) entry = ask - distEntry;
   else if(CurrentTypeIndex == 2) entry = bid + distEntry;
   else if(CurrentTypeIndex == 3) entry = ask + distEntry;
   else if(CurrentTypeIndex == 4) entry = bid - distEntry;
   
   int dir = CurrentDirection;
   if(CurrentTypeIndex > 0)
   {
       if(CurrentTypeIndex == 1 || CurrentTypeIndex == 3) dir = 0;
       else dir = 1;
   }
   
   if(dir == 0) { sl = entry - distSL; tp = entry + distTP; }
   else         { sl = entry + distSL; tp = entry - distTP; }
   
   double margin = visibleRange * 0.05;
   double clampMin = priceMin + margin;
   double clampMax = priceMax - margin;
   
   if(CurrentTypeIndex != 0)
   {
       if(entry < clampMin) entry = clampMin;
       if(entry > clampMax) entry = clampMax;
   }
   
   if(dir == 0) { sl = entry - distSL; tp = entry + distTP; }
   else         { sl = entry + distSL; tp = entry - distTP; }
   
   if(sl < clampMin) sl = clampMin;
   if(sl > clampMax) sl = clampMax;
   
   if(tp < clampMin) tp = clampMin;
   if(tp > clampMax) tp = clampMax;
   
   if(CurrentTypeIndex != 0)
      ObjectSetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT, DoubleToString(entry, digits));
   
   ObjectSetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT, DoubleToString(sl, digits));
   ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, DoubleToString(tp, digits));
   
   UpdateChartLines();
   UpdateCalculatedLot();
}

//+------------------------------------------------------------------+
//| INVERT VALUES WHEN SWITCHING DIRECTION                           |
//+------------------------------------------------------------------+
void InvertTradeInputs(int oldDir, int newDir, int oldType, int newType)
{
   if(oldDir == newDir) return;
   
   string symbol = ObjectGetString(0, PREFIX + "Nav_Btn_SymbolSelect", OBJPROP_TEXT);
   if(symbol == "") symbol = Symbol();
   int digits = (int)MarketInfo(symbol, MODE_DIGITS);
   
   double entryPrice = 0;
   if(oldType == 0) // Market
   {
       entryPrice = (oldDir == 0) ? MarketInfo(symbol, MODE_ASK) : MarketInfo(symbol, MODE_BID);
   }
   else // Pending
   {
       string entryStr = ObjectGetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT);
       entryPrice = StringToDouble(entryStr);
   }
   
   if(entryPrice <= 0) return;
   
   double newEntryPrice = entryPrice;
   if(newType == 0)
   {
       newEntryPrice = (newDir == 0) ? MarketInfo(symbol, MODE_ASK) : MarketInfo(symbol, MODE_BID);
   }
   else if (oldType == 0 && newType != 0)
   {
       newEntryPrice = (newDir == 0) ? MarketInfo(symbol, MODE_ASK) : MarketInfo(symbol, MODE_BID);
   }
   
   string slStr = ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT);
   string tpStr = ObjectGetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT);
   if(slStr == "" || tpStr == "") return;
   
   double sl = StringToDouble(slStr);
   double tp = StringToDouble(tpStr);
   if(sl <= 0) return;
   
   double distSL = MathAbs(entryPrice - sl);
   double distTP = 0;
   if(tp > 0) distTP = MathAbs(entryPrice - tp);
   
   if(newDir == 0)
   {
       sl = newEntryPrice - distSL;
       if(tp > 0) tp = newEntryPrice + distTP;
   }
   else
   {
       sl = newEntryPrice + distSL;
       if(tp > 0) tp = newEntryPrice - distTP;
   }
   
   ObjectSetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT, DoubleToString(sl, digits));
   if(tp > 0) ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, DoubleToString(tp, digits));
   else       ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, "0");
   
   if(newType != 0)
   {
       ObjectSetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT, DoubleToString(newEntryPrice, digits));
   }
}

#endif
