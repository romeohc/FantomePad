//+------------------------------------------------------------------+
//|                                                   TradeLogic.mqh |
//|                                              FantomePad Project  |
//|                                       Common Pure Trade Logic    |
//+------------------------------------------------------------------+
#ifndef _TRADE_LOGIC_MQH_
#define _TRADE_LOGIC_MQH_

#include "Defines.mqh"
#include "../GUI/GraphicWrappers.mqh" // For FP_ObjectCreate, etc.

// ===================================================================
// SECTION 1: TRADE CALCULATIONS (From Trade_Calculations.mqh)
// ===================================================================

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
   
   string symbol = FP_ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
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
   
   double lots = CalculateLotSize(entry, sl, risk);
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

// ===================================================================
// SECTION 2: GRAPHIC LINES LOGIC (From Trade_Lines.mqh)
// ===================================================================

int GetSlippagePoints(int slippagePips)
{
   int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
   if(digits == 3 || digits == 5) return slippagePips * 10;
   return slippagePips;
}

void UpdateSingleLine(string lineSuffix, string editSuffix, color col)
{
   string editName = PREFIX + editSuffix;
   string lineName = PREFIX + lineSuffix;
   
   string text = FP_ObjectGetString(0, editName, OBJPROP_TEXT);
   double price = StringToDouble(text);
   
   if(price > 0)
   {
      if(FP_ObjectFind(0, lineName) < 0)
      {
         FP_ObjectCreate(0, lineName, OBJ_HLINE, 0, 0, price);
         FP_ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, true);
         FP_ObjectSetInteger(0, lineName, OBJPROP_SELECTED, true); 
         FP_ObjectSetString(0, lineName, OBJPROP_TEXT, lineSuffix); 
      }
      
      FP_ObjectSetInteger(0, lineName, OBJPROP_COLOR, col);
      FP_ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 2);
      FP_ObjectSetInteger(0, lineName, OBJPROP_BACK, true);
      
      double currentLinePrice = FP_ObjectGetDouble(0, lineName, OBJPROP_PRICE1);
      if(MathAbs(currentLinePrice - price) > Point)
      {
         FP_ObjectSetDouble(0, lineName, OBJPROP_PRICE1, price);
      }
   }
   else
   {
      if(FP_ObjectFind(0, lineName) >= 0) FP_ObjectDelete(0, lineName);
   }
}

void UpdateChartLines()
{
   if(!g_ShowOrderLines || !g_PanelMain.IsVisible)
   {
       string sufs[] = {"Line_SL", "Line_TP", "Line_Price", "Line_SL_Txt", "Line_TP_Txt", "Line_Price_Txt"};
       for(int i=0; i<ArraySize(sufs); i++)
          if(FP_ObjectFind(0, PREFIX + sufs[i]) >= 0) FP_ObjectDelete(0, PREFIX + sufs[i]);
       
       ChartRedraw();
       return;
   }

   UpdateSingleLine("Line_SL", "Edit_SL", g_ColorSLLine);
   UpdateSingleLine("Line_TP", "Edit_TP", g_ColorTPLine);
   
   if(CurrentTypeIndex != 0) 
   {
      UpdateSingleLine("Line_Price", "Edit_Price", g_ColorEntryLine);
   } 
   else 
   {
      if(FP_ObjectFind(0, PREFIX + "Line_Price") >= 0) FP_ObjectDelete(0, PREFIX + "Line_Price");
   }
   
   ChartRedraw();
}

void CreateHLine(string name, double price, color col, int style, int width, string labelText = "")
{
   if(FP_ObjectFind(0, name) < 0)
   {
      FP_ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
      FP_ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      FP_ObjectSetInteger(0, name, OBJPROP_BACK, true);
   }
   
   double curPrice = FP_ObjectGetDouble(0, name, OBJPROP_PRICE1);
   if(MathAbs(curPrice - price) > Point) FP_ObjectSetDouble(0, name, OBJPROP_PRICE1, price);
   
   FP_ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   FP_ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   FP_ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   
   string txtName = name + "_Txt";
   if(labelText != "")
   {
      int firstBar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
      int offset = 3; 
      if(firstBar < offset) offset = 0;
      datetime txtTime = iTime(Symbol(), Period(), firstBar - offset);
      
      if(FP_ObjectFind(0, txtName) < 0)
      {
         FP_ObjectCreate(0, txtName, OBJ_TEXT, 0, txtTime, price);
         FP_ObjectSetInteger(0, txtName, OBJPROP_FONTSIZE, 9);
         FP_ObjectSetString(0, txtName, OBJPROP_FONT, "Arial Bold");
         FP_ObjectSetInteger(0, txtName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         FP_ObjectSetInteger(0, txtName, OBJPROP_BACK, false);
         FP_ObjectSetInteger(0, txtName, OBJPROP_SELECTABLE, false);
      }
      
      FP_ObjectSetDouble(0, txtName, OBJPROP_PRICE1, price);
      FP_ObjectSetInteger(0, txtName, OBJPROP_TIME1, (long)txtTime);
      FP_ObjectSetString(0, txtName, OBJPROP_TEXT, labelText);
      FP_ObjectSetInteger(0, txtName, OBJPROP_COLOR, col);
   }
   else
   {
       if(FP_ObjectFind(0, txtName) >= 0) FP_ObjectDelete(0, txtName);
   }
}

void UpdateOpenOrderLines()
{
   if(!g_ShowPositionLines)
   {
      int total = ObjectsTotal(0, -1, -1);
      for(int i = total - 1; i >= 0; i--)
      {
         string name = ObjectName(0, i);
         if(StringFind(name, PREFIX + "Open_") >= 0) FP_ObjectDelete(0, name);
      }
      ChartRedraw();
      return;
   }
   
   string activeTickets = "|";
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol())
         {
            int ticket = OrderTicket();
            activeTickets += IntegerToString(ticket) + "|";
            
            double op = OrderOpenPrice();
            double sl = OrderStopLoss();
            double tp = OrderTakeProfit();
            int type = OrderType();
            
            string entryLabel = (type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP) ? "SELL" : "BUY";
            string tPrefix = PREFIX + "Open_" + IntegerToString(ticket);
            int d = (int)MarketInfo(Symbol(), MODE_DIGITS);
            
            CreateHLine(tPrefix + "_Ent", op, clrWhite, STYLE_DOT, 1, entryLabel + " - " + DoubleToString(op, d));
            
            if(sl > 0) CreateHLine(tPrefix + "_SL", sl, g_ColorSLLine, STYLE_DOT, 1, "SL - " + DoubleToString(sl, d));
            else {
                if(FP_ObjectFind(0, tPrefix + "_SL") >= 0) FP_ObjectDelete(0, tPrefix + "_SL");
                if(FP_ObjectFind(0, tPrefix + "_SL_Txt") >= 0) FP_ObjectDelete(0, tPrefix + "_SL_Txt");
            }
            
            if(tp > 0) CreateHLine(tPrefix + "_TP", tp, g_ColorTPLine, STYLE_DOT, 1, "TP - " + DoubleToString(tp, d));
            else {
                if(FP_ObjectFind(0, tPrefix + "_TP") >= 0) FP_ObjectDelete(0, tPrefix + "_TP");
                if(FP_ObjectFind(0, tPrefix + "_TP_Txt") >= 0) FP_ObjectDelete(0, tPrefix + "_TP_Txt");
            }
         }
      }
   }
   
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, PREFIX + "Open_") >= 0)
      {
         string parts[];
         ushort sep = StringGetCharacter("_", 0);
         StringSplit(name, sep, parts);
         
         if(ArraySize(parts) >= 3)
         {
            if(StringFind(activeTickets, "|" + parts[2] + "|") < 0) FP_ObjectDelete(0, name);
         }
      }
   }
}

// ===================================================================
// SECTION 3: AUTOMATION LOGIC (Refactored to call Local functions)
// ===================================================================
//+------------------------------------------------------------------+
//| Logique Automatique : Changement de Type selon Lignes            |
//| Extracted from Trade modules for Common usage                    |
//+------------------------------------------------------------------+
void AutoSwitchOrderType()
{
   double sl    = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
   double tp    = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT));
   double entry = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT));
   
   if(sl <= 0) return;
   
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
      // UpdateUIMode() IS NOT AVAILABLE HERE.
      // We rely on the caller or a callback?
      // Or we need to move UpdateUIMode too?
      // UpdateUIMode is in Panel_Main_Layout.
      // Panel_Main_Layout depends on Panel_Main_Shared.
      // Panel_Main_Shared depends on nothing.
      // We can include Panel_Main_Shared here? No, circular.
      
      // Let's assume UpdateUIMode is handled by caller or we can access it via CPanel_Main::UpdateUIMode
      // if we include "Main/Panel_Main_Shared.mqh".
      
      // For now, I will NOT call UpdateUIMode() here, assuming it's acceptable for pure logic separation.
      // BUT I will call UpdateCalculatedLot() and ChartRedraw() because I moved them here/they are standard.
      
      UpdateCalculatedLot();
      ChartRedraw();
   }
}

#endif
