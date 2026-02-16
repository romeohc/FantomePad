//+------------------------------------------------------------------+
//|                                                 ITradeEngine.mqh |
//|                                                   FantomePad LLC |
//|                                  http://www.fantomepad.com       |
//+------------------------------------------------------------------+
#property copyright "FantomePad LLC"
#property link      "http://www.fantomepad.com"
#property strict

#include "../DataTypes.mqh"

//+------------------------------------------------------------------+
//| Interface for Trade Engines (Abstract Base Class)                |
//| Defines the contract that all platform-specific engines must     |
//| implement (MT4, MT5, etc.)                                       |
//+------------------------------------------------------------------+
class ITradeEngine
  {
public:
   //--- Destructor
   virtual ~ITradeEngine() {}

   //--- Market Orders
   // Returns TradeResult
   virtual TradeResult OpenMarket(string symbol, 
                          int type, 
                          double lots, 
                          double price, 
                          double sl, 
                          double tp, 
                          string comment, 
                          int magic) = 0;

   //--- Pending Orders
   // Returns TradeResult
   virtual TradeResult OpenPending(string symbol, 
                           int type, 
                           double lots, 
                           double price, 
                           double sl, 
                           double tp, 
                           string comment, 
                           int magic, 
                           datetime expiration) = 0;

   //--- Modify Orders
   // Returns TradeResult
   virtual TradeResult Modify(long ticket, 
                      double sl, 
                      double tp) = 0;

   //--- Close Orders (Market)
   // Returns TradeResult
   virtual TradeResult Close(long ticket, 
                     double lots, 
                     string comment) = 0;

   //--- Delete Orders (Pending)
   // Returns TradeResult
   virtual TradeResult Delete(long ticket) = 0;
  };
//+------------------------------------------------------------------+
