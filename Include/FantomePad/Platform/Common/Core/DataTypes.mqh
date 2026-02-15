//+------------------------------------------------------------------+
//|                                                    DataTypes.mqh |
//|                                              FantomePad Project  |
//|                                         Common Internal Structs  |
//+------------------------------------------------------------------+
#ifndef _DATATYPES_MQH_
#define _DATATYPES_MQH_

//Objectif: Standardiser les données entre MT4 et MT5

//--- Structure unifiée pour une Position ou un Ordre
struct FantomeTrade {
   long     Ticket;
   string   Symbol;
   int      Type;          // MT4: OP_BUY/OP_SELL... | MT5: ENUM_ORDER_TYPE / ENUM_POSITION_TYPE converted to int
   double   Lots;
   double   OpenPrice;
   double   StopLoss;
   double   TakeProfit;
   datetime OpenTime;
   datetime CloseTime;
   double   ClosePrice;
   double   Commission;
   double   Swap;
   double   Profit;
   string   Comment;
   int      Magic;
   
   // Helper fields
   int      Digits; 
   double   Point;
};

//--- Structure unifiée pour le Compte
struct FantomeAccount {
   long     Login;
   string   Name;
   string   Server;
   string   Currency;
   int      Leverage;
   double   Balance;
   double   Equity;
   double   Margin;
   double   FreeMargin;
   double   MarginLevel;
   double   Credit;
   bool     IsTradeAllowed;
   bool     IsExpertAllowed;
   int      LimitOrders;   // Max orders allowed
};

#endif
