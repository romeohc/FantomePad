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
        return PositionsTotal() + OrdersTotal();
   }
   
   int FP_OrdersHistoryTotal()
   {
      return HistoryDealsTotal(); // Simplified approximation for now
   }
   
   // Selection state tracking
   static bool g_fp_is_position = false;
   static ulong g_fp_selected_ticket = 0;

   bool FP_OrderSelect(int index, int select, int pool=MODE_TRADES)
   {
      g_fp_is_position = false;
      g_fp_selected_ticket = 0;

      if(pool == MODE_TRADES)
      {
         int posTotal = PositionsTotal();
         if(select == SELECT_BY_POS)
         {
            if(index < posTotal)
            {
               string sym = PositionGetSymbol(index);
               if(sym != "") 
               {
                  g_fp_is_position = true;
                  g_fp_selected_ticket = PositionGetInteger(POSITION_TICKET);
                  return true;
               }
            }
            else
            {
               int ordIndex = index - posTotal;
               if(ordIndex < OrdersTotal())
               {
                  ulong ticket = OrderGetTicket(ordIndex);
                  if(ticket > 0)
                  {
                     g_fp_selected_ticket = ticket;
                     return true;
                  }
               }
            }
         }
         else // BY_TICKET
         {
            if(PositionSelectByTicket((ulong)index))
            {
               g_fp_is_position = true;
               g_fp_selected_ticket = (ulong)index;
               return true;
            }
            if(OrderSelect((ulong)index))
            {
               g_fp_selected_ticket = (ulong)index;
               return true;
            }
         }
      }
      return false; 
   }
   
   // --- MACROS TO FORCE USAGE OF FP_ FUNCTIONS ---
   #define OrderSelect FP_OrderSelect
   #define OrdersTotal FP_OrdersTotal
   #define OrdersHistoryTotal FP_OrdersHistoryTotal
   
   // --- ORDER PROPERTIES MAPPING ---
   double FP_OrderOpenPrice() 
   { 
      return g_fp_is_position ? PositionGetDouble(POSITION_PRICE_OPEN) : OrderGetDouble(ORDER_PRICE_OPEN); 
   }
   double FP_OrderStopLoss()  
   { 
      return g_fp_is_position ? PositionGetDouble(POSITION_SL) : OrderGetDouble(ORDER_SL); 
   }
   double FP_OrderTakeProfit()
   { 
      return g_fp_is_position ? PositionGetDouble(POSITION_TP) : OrderGetDouble(ORDER_TP); 
   }
   double FP_OrderLots()      
   { 
      return g_fp_is_position ? PositionGetDouble(POSITION_VOLUME) : OrderGetDouble(ORDER_VOLUME_INITIAL); 
   }
   int    FP_OrderTicket()    
   { 
      return (int)g_fp_selected_ticket;
   }
   string FP_OrderSymbol()    
   { 
      return g_fp_is_position ? PositionGetString(POSITION_SYMBOL) : OrderGetString(ORDER_SYMBOL); 
   }
   int    FP_OrderType()      
   { 
      if(g_fp_is_position)
      {
         int type = (int)PositionGetInteger(POSITION_TYPE);
         return (type == POSITION_TYPE_BUY) ? OP_BUY : OP_SELL;
      }
      return (int)OrderGetInteger(ORDER_TYPE);
   }
   double FP_OrderProfit()    
   { 
      return g_fp_is_position ? PositionGetDouble(POSITION_PROFIT) : 0; 
   }
   double FP_OrderSwap()      
   { 
      return g_fp_is_position ? PositionGetDouble(POSITION_SWAP) : 0; 
   }
   string FP_OrderComment()   
   { 
      return g_fp_is_position ? PositionGetString(POSITION_COMMENT) : OrderGetString(ORDER_COMMENT); 
   }
   double FP_OrderCommission() { return 0.0; }
   
   datetime FP_OrderOpenTime()
   { 
      return (datetime)(g_fp_is_position ? PositionGetInteger(POSITION_TIME) : OrderGetInteger(ORDER_TIME_SETUP)); 
   }
   
   datetime FP_OrderCloseTime()
   { 
      return 0; // Les positions/ordres actifs n'ont pas de CloseTime
   }

   int FP_OrderMagic()
   {
      return (int)(g_fp_is_position ? PositionGetInteger(POSITION_MAGIC) : OrderGetInteger(ORDER_MAGIC));
   }

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
   #define OrderOpenTime  FP_OrderOpenTime
   #define OrderMagic     FP_OrderMagic
   
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
           
           case 0: // MODE_MARGINREQUIRED placeholder
           {
              double margin = 0;
              if(OrderCalcMargin(ORDER_TYPE_BUY, symbol, 1.0, SymbolInfoDouble(symbol, SYMBOL_ASK), margin))
                 return margin;
              return 0.0;
           }
           
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
   // Note: We avoid naked #define Point to prevent breaking struct members
   #ifndef Point
      #define Point _Point
   #endif
   #ifndef Digits
      #define Digits _Digits
   #endif
   #define Bars iBars(_Symbol, _Period)

   // --- MACROS FOR WRAPPERS ---
   #define AccountNumber FP_AccountNumber
   #define IsTesting FP_IsTesting
   
   // FIX: POSITION_COMMISSION is deprecated/not available for open positions. Returning 0.
   // Removed duplicate definition

#endif

#endif
