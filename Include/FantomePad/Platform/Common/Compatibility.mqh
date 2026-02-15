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

   // --- TRADE CONSTANTS MAPPING (No-op on MT4) ---
   #define ORDER_TYPE_BUY      OP_BUY
   #define ORDER_TYPE_SELL     OP_SELL
   #define ORDER_TYPE_BUY_LIMIT  OP_BUYLIMIT
   #define ORDER_TYPE_SELL_LIMIT OP_SELLLIMIT
   #define ORDER_TYPE_BUY_STOP   OP_BUYSTOP
   #define ORDER_TYPE_SELL_STOP  OP_SELLSTOP
   
   // --- POSITION IDENTIFICATION ---
   #define POSITION_TYPE_BUY   OP_BUY
   #define POSITION_TYPE_SELL  OP_SELL

   // --- DATA WRAPPERS ---
   // Map Common accessors back to simple native calls
   
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
   double FP_OrderProfit()    { return OrderProfit(); } 
   double FP_OrderSwap()      { return OrderSwap(); }
   double FP_OrderCommission(){ return OrderCommission(); }
   string FP_OrderComment()   { return OrderComment(); }
   datetime FP_OrderCloseTime(){ return OrderCloseTime(); }
   
   // Account
   double FP_AccountEquity()  { return AccountEquity(); }
   double FP_AccountBalance() { return AccountBalance(); }
   int    FP_AccountNumber()  { return AccountNumber(); }
   
   // Time wrappers
   datetime FP_iTime(string symbol, int timeframe, int shift)
   {
      return iTime(symbol, timeframe, shift);
   }
   
   // Testing
   bool FP_IsTesting() { return IsTesting(); }

// ===================================================================
// PLATFORM : METATRADER 5 (MQL5)
// ===================================================================
#else

   // --- TRADE CONSTANTS MAPPING ---
   #define OP_BUY          ORDER_TYPE_BUY
   #define OP_SELL         ORDER_TYPE_SELL
   #define OP_BUYLIMIT     ORDER_TYPE_BUY_LIMIT
   #define OP_SELLLIMIT    ORDER_TYPE_SELL_LIMIT
   #define OP_BUYSTOP      ORDER_TYPE_BUY_STOP
   #define OP_SELLSTOP     ORDER_TYPE_SELL_STOP
   
   #define MODE_BID        SYMBOL_BID
   #define MODE_ASK        SYMBOL_ASK
   #define MODE_POINT      SYMBOL_POINT
   #define MODE_DIGITS     SYMBOL_DIGITS
   #define MODE_SPREAD     SYMBOL_SPREAD
   #define MODE_STOPLEVEL  SYMBOL_TRADE_STOPS_LEVEL
   #define MODE_LOTSTEP    SYMBOL_VOLUME_STEP
   #define MODE_MINLOT     SYMBOL_VOLUME_MIN
   #define MODE_MAXLOT     SYMBOL_VOLUME_MAX
   #define MODE_TICKVALUE  SYMBOL_TRADE_TICK_VALUE
   #define MODE_TICKSIZE   SYMBOL_TRADE_TICK_SIZE
   #define MODE_MARGINREQUIRED 0 

   // --- SELECTION MAPPING ---
   #define MODE_TRADES 0
   #define MODE_HISTORY 1
   #define SELECT_BY_POS 0
   #define SELECT_BY_TICKET 1
   
   // Use FP_ prefix to avoid ambiguity with system functions
   int FP_OrdersTotal() 
   {
       return PositionsTotal();
   }
   
   int FP_OrdersHistoryTotal()
   {
      return HistoryDealsTotal(); // Simplified approximation for now
   }
   
   bool FP_OrderSelect(int index, int select, int pool=MODE_TRADES)
   {
      if(pool == MODE_TRADES)
      {
         if(select == SELECT_BY_POS)
         {
             string sym = PositionGetSymbol(index);
             return (sym != "");
         }
         else // BY_TICKET
         {
             return PositionSelectByTicket((ulong)index);
         }
      }
      return false; // History not fully implemented yet in Phase 1
   }
   
   // --- MACROS TO FORCE USAGE OF FP_ FUNCTIONS ---
   #define OrderSelect FP_OrderSelect
   #define OrdersTotal FP_OrdersTotal
   #define OrdersHistoryTotal FP_OrdersHistoryTotal
   
   // --- ORDER PROPERTIES MAPPING ---
   double FP_OrderOpenPrice() { return PositionGetDouble(POSITION_PRICE_OPEN); }
   double FP_OrderStopLoss()  { return PositionGetDouble(POSITION_SL); }
   double FP_OrderTakeProfit(){ return PositionGetDouble(POSITION_TP); }
   double FP_OrderLots()      { return PositionGetDouble(POSITION_VOLUME); }
   int    FP_OrderTicket()    { return (int)PositionGetInteger(POSITION_TICKET); }
   string FP_OrderSymbol()    { return PositionGetString(POSITION_SYMBOL); }
   int    FP_OrderType()      { return (int)PositionGetInteger(POSITION_TYPE); }
   double FP_OrderProfit()    { return PositionGetDouble(POSITION_PROFIT); }
   double FP_OrderSwap()      { return PositionGetDouble(POSITION_SWAP); }
   string FP_OrderComment()   { return PositionGetString(POSITION_COMMENT); }
   datetime FP_OrderCloseTime(){ return (datetime)PositionGetInteger(POSITION_TIME); } // Approx for open pos

   #define OrderOpenPrice FP_OrderOpenPrice
   #define OrderStopLoss  FP_OrderStopLoss
   #define OrderTakeProfit FP_OrderTakeProfit
   #define OrderLots      FP_OrderLots
   #define OrderTicket    FP_OrderTicket
   #define OrderSymbol    FP_OrderSymbol
   #define OrderType      FP_OrderType
   #define OrderProfit    FP_OrderProfit
   #define OrderSwap      FP_OrderSwap
   #define OrderCommission FP_OrderCommission
   #define OrderComment   FP_OrderComment
   #define OrderCloseTime FP_OrderCloseTime
   
   // --- GLOBAL VARIABLES MACROS ---
   #define Ask SymbolInfoDouble(_Symbol, SYMBOL_ASK)
   #define Bid SymbolInfoDouble(_Symbol, SYMBOL_BID)
   
   // --- DATA WRAPPERS ---

   // 1. Account Info
   double AccountEquity()
   {
      return AccountInfoDouble(ACCOUNT_EQUITY);
   }
   
   double AccountBalance()
   {
      return AccountInfoDouble(ACCOUNT_BALANCE);
   }
   
   double AccountFreeMargin()
   {
      return AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   }
   
   int AccountLeverage()
   {
      return (int)AccountInfoInteger(ACCOUNT_LEVERAGE);
   }
   
   string AccountCurrency()
   {
      return AccountInfoString(ACCOUNT_CURRENCY);
   }
   
   int FP_AccountNumber()
   {
      return (int)AccountInfoInteger(ACCOUNT_LOGIN);
   }
   
   bool IsTradeAllowed()
   {
      return (bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
   }
   
   bool IsExpertEnabled()
   {
       return (bool)AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
   }
   
   // 2. Market Info
   double MarketInfo(string symbol, int type)
   {
       switch(type)
       {
           case SYMBOL_BID:              return SymbolInfoDouble(symbol, SYMBOL_BID);
           case SYMBOL_ASK:              return SymbolInfoDouble(symbol, SYMBOL_ASK);
           case SYMBOL_POINT:            return SymbolInfoDouble(symbol, SYMBOL_POINT);
           case SYMBOL_TRADE_TICK_VALUE: return SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
           case SYMBOL_TRADE_TICK_SIZE:  return SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
           case SYMBOL_VOLUME_STEP:      return SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
           case SYMBOL_VOLUME_MIN:       return SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
           case SYMBOL_VOLUME_MAX:       return SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
           case SYMBOL_DIGITS:           return (double)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
           case SYMBOL_SPREAD:           return (double)SymbolInfoInteger(symbol, SYMBOL_SPREAD);
           case SYMBOL_TRADE_STOPS_LEVEL: return (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
           default: return 0.0;
       }
   }
   
   // 3. Time Functions
   datetime FP_iTime(string symbol, int timeframe, int shift)
   {
      datetime times[];
      if(CopyTime(symbol, (ENUM_TIMEFRAMES)timeframe, shift, 1, times) > 0)
         return times[0];
      return 0;
   }
   
   #define iTime FP_iTime
   
   // 4. Testing
   bool FP_IsTesting()
   {
      return (bool)MQLInfoInteger(MQL_TESTER);
   }
   
   // 5. Constants & Globals Mapping
   #define OBJPROP_PRICE1 OBJPROP_PRICE
   #define OBJPROP_TIME1  OBJPROP_TIME
   #define OBJPROP_TIME2  OBJPROP_TIME
   
   // MT5 defines Point as a function, MT4 as a var. We map to _Point (_Digits).
   #define Point _Point
   #define Digits _Digits
   #define Bars iBars(_Symbol, _Period)

   // --- MACROS FOR WRAPPERS ---
   #define AccountNumber FP_AccountNumber
   #define IsTesting FP_IsTesting
   
   // FIX: POSITION_COMMISSION is deprecated/not available for open positions. Returning 0.
   double FP_OrderCommission() { return 0.0; } // Was PositionGetDouble(POSITION_COMMISSION);

#endif

#endif
