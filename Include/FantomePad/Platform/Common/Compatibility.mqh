//+------------------------------------------------------------------+
//|                                                Compatibility.mqh |
//|                                              FantomePad Project  |
//|                         Data Abstraction Layer (DAL)             |
//+------------------------------------------------------------------+
#ifndef _COMPATIBILITY_MQH_
#define _COMPATIBILITY_MQH_
#property strict

// ===================================================================
// PLATFORM : METATRADER 4 (MQL4)
// ===================================================================
#ifdef __MQL4__

   // --- TRADE CONSTANTS MAPPING ---
   // On MT5, these are enums. On MT4, int. We map future MT5 enums to MT4 ints.
   #define ORDER_TYPE_BUY      OP_BUY
   #define ORDER_TYPE_SELL     OP_SELL
   #define ORDER_TYPE_BUY_LIMIT  OP_BUYLIMIT
   #define ORDER_TYPE_SELL_LIMIT OP_SELLLIMIT
   #define ORDER_TYPE_BUY_STOP   OP_BUYSTOP
   #define ORDER_TYPE_SELL_STOP  OP_SELLSTOP
   
   // --- POSITION IDENTIFICATION ---
   #define POSITION_TYPE_BUY   OP_BUY
   #define POSITION_TYPE_SELL  OP_SELL

   // --- WRAPPERS (To be used in Common Code instead of native calls) ---
   
   // Selection
   bool FP_OrderSelect(int ticket, int select, int pool=MODE_TRADES)
   {
      return OrderSelect(ticket, select, pool);
   }
   
   // Properties
   double FP_OrderOpenPrice() { return OrderOpenPrice(); }
   double FP_OrderStopLoss()  { return OrderStopLoss(); }
   double FP_OrderTakeProfit(){ return OrderTakeProfit(); }
   double FP_OrderLots()      { return OrderLots(); }
   int    FP_OrderTicket()    { return OrderTicket(); }
   string FP_OrderSymbol()    { return OrderSymbol(); }
   int    FP_OrderType()      { return OrderType(); }
   
   // Account
   double FP_AccountEquity()  { return AccountEquity(); }
   double FP_AccountBalance() { return AccountBalance(); }

// ===================================================================
// PLATFORM : METATRADER 5 (MQL5)
// ===================================================================
#else
   // MQL5 Logic will be implemented here during Phase 1.
   // It will map FP_Functions to PositionGetDouble/Integer...
#endif

#endif
