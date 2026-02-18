//+------------------------------------------------------------------+
//|                                                    TradeCalc.mqh |
//|                                              FantomePad Project  |
//|                                          Pure Trade Calculations |
//+------------------------------------------------------------------+
#ifndef _TRADE_CALC_MQH_
#define _TRADE_CALC_MQH_

#include "../Defines.mqh"

// ===================================================================
// PURE MATH CALCULATIONS (0 UI DEPENDENCY)
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

double CalculateLotSize(string symbol, double entryPrice, double slPrice, double riskValue)
{
   if(entryPrice <= 0 || slPrice <= 0 || riskValue <= 0) return 0.0;
   if(AccountEquity() <= 0) return 0.0;
   
   // Safety check for distance
   double point = MarketInfo(symbol, MODE_POINT);
   if(point == 0) point = Point; // Fallback
   if(MathAbs(entryPrice - slPrice) <= point) return 0.0;
   
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

int GetSlippagePoints(int slippagePips)
{
   int safeSlippage = MathAbs(slippagePips);
   int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
   if(digits == 3 || digits == 5) return safeSlippage * 10;
   return safeSlippage;
}


//+------------------------------------------------------------------+
//| HELPER: RETRIEVE ORIGINAL LOT SIZE (TRACE HISTORY)               |
//+------------------------------------------------------------------+
double GetOriginalLotSize(long ticket)
{
   if(!OrderSelect(ticket, SELECT_BY_TICKET)) return 0.0;
   
   double currentLots = OrderLots();
   string comment = OrderComment();
   
   // --- METHOD 1: CHECK FOR EXPLICIT "Org:TAG" (Priority 1) ---
   // This solves the Pending Order "Inflation" bug by avoiding history math entirely.
   int tagPos = StringFind(comment, "Org:");
   if(tagPos >= 0)
   {
      string subTag = StringSubstr(comment, tagPos + 4);
      double taggedLots = StringToDouble(subTag);
      if(taggedLots > 0) return taggedLots;
   }
   
   // --- METHOD 2: CHECK FOR GLOBAL VARIABLE TAG (MT4 Market Fallback) ---
   // Used when comments cannot be modified (Live Market Orders on MT4).
   string gvarName = "FP_ORG_" + IntegerToString((int)ticket);
   if(GlobalVariableCheck(gvarName))
   {
      double gvarLots = GlobalVariableGet(gvarName);
      if(gvarLots > 0) return gvarLots;
   }
   
   // --- METHOD 3: MT5 NATIVE POSITION HISTORY (Priority 3) ---
   // Only for Market Orders (Positions Identifier) on MT5
   #ifdef __MQL5__
      if(OrderType() <= 1) // OP_BUY or OP_SELL
      {
         long posID = (long)PositionGetInteger(POSITION_IDENTIFIER);
         if(posID > 0)
         {
            if(HistorySelectByPosition(posID))
            {
               int deals = HistoryDealsTotal();
               // Iterate to find the very first DEAL_ENTRY_IN
               for(int i = 0; i < deals; i++)
               {
                  ulong dealTicket = HistoryDealGetTicket(i);
                  if(dealTicket > 0)
                  {
                     long entry = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);
                     if(entry == DEAL_ENTRY_IN)
                     {
                        // Found original entry
                        return HistoryDealGetDouble(dealTicket, DEAL_VOLUME);
                     }
                  }
               }
            }
         }
      }
   #endif

   // --- METHOD 3: MT4 MARKET ORDER TRACE (Fallback) ---
   // For legacy MT4 Market orders where tickets change and "from #" is used.
   // We only use this if NO tag was found.
   
   double totalLots = currentLots;
   int safety = 0;
   
   while(StringFind(comment, "from #") >= 0 && safety < 50)
   {
      int pos = StringFind(comment, "from #");
      // Extract ticket number carefully
      string sub = StringSubstr(comment, pos + 6);
      
      // Stop at next space or non-digit (in case comment continues)
      int endPos = -1;
      int subLen = StringLen(sub);
      for(int k=0; k<subLen; k++) {
         #ifdef __MQL5__
            ushort charCode = StringGetCharacter(sub, k);
         #else
            int charCode = StringGetChar(sub, k);
         #endif
         if(charCode < '0' || charCode > '9') { endPos = k; break; }
      }
      if(endPos != -1) sub = StringSubstr(sub, 0, endPos);
      
      long prevTicket = StringToInteger(sub);
      
      if(OrderSelect(prevTicket, SELECT_BY_TICKET, MODE_HISTORY))
      {
         // CRITICAL CORRECTION:
         // In MT4, the history order represents the CLOSED part.
         // We add it to our running total.
         totalLots += OrderLots(); 
         comment = OrderComment();
      }
      else break;
      
      safety++;
   }
   
   return totalLots;
}

#endif
