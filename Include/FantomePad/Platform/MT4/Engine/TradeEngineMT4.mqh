//+------------------------------------------------------------------+
//|                                             TradeEngineMT4.mqh   |
//|                                                   FantomePad LLC |
//|                                  http://www.fantomepad.com       |
//+------------------------------------------------------------------+
#property copyright "FantomePad LLC"
#property link      "http://www.fantomepad.com"
#property strict

// Include the Interface
#include "../../Common/Core/Engine/ITradeEngine.mqh"

//+------------------------------------------------------------------+
//| MT4 Implementation of the Trading Engine                         |
//+------------------------------------------------------------------+
class C_TradeEngineMT4 : public ITradeEngine
  {
private:
   int               m_slippage; // Default slippage points

public:
                     C_TradeEngineMT4(void) : m_slippage(10) {};
                    ~C_TradeEngineMT4(void) {};

   //+------------------------------------------------------------------+
   //| Open Market Order                                                |
   //+------------------------------------------------------------------+
   virtual long OpenMarket(string symbol,
                           int type,
                           double lots,
                           double price,
                           double sl,
                           double tp,
                           string comment,
                           int magic)
     {
      ResetLastError();
      
      // Basic validation
      if(lots <= 0) {
         Print("[Error] OpenMarket: Invalid lots: ", lots);
         return -1;
      }

      // Determine color based on order type
      color arrow_color=clrNONE;
      if(type==OP_BUY) arrow_color=clrBlue;
      else if(type==OP_SELL) arrow_color=clrRed;

      // Refresh rates before execution
      RefreshRates();
      
      // If price is 0, use current market price logic (optional safety, 
      // but usually the caller provides the price. In MT4 OrderSend needs specific price for market?)
      // Actually standard OrderSend for OP_BUY needs Ask, OP_SELL needs Bid.
      // We assume the caller ('price') passes the correct current price found via MarketInfo/SymbolInfoDouble.
      // But purely for safety, if user passes 0, we could fetch it. 
      // For now, respect the argument.

      int ticket = OrderSend(symbol, type, lots, price, m_slippage, sl, tp, comment, magic, 0, arrow_color);

      if(ticket < 0)
        {
         int err = GetLastError();
         Print("[Error] OpenMarket failed. Error: ", err, " | Symbol: ", symbol, " | Type: ", type, " | Price: ", price);
         return -1;
        }

      return (long)ticket;
     }

   //+------------------------------------------------------------------+
   //| Open Pending Order                                               |
   //+------------------------------------------------------------------+
   virtual long OpenPending(string symbol,
                            int type,
                            double lots,
                            double price,
                            double sl,
                            double tp,
                            string comment,
                            int magic,
                            datetime expiration)
     {
      ResetLastError();
      
      color arrow_color=clrGray;
      
      // Refresh rates not strictly needed for pending placement but good practice
      RefreshRates();

      int ticket = OrderSend(symbol, type, lots, price, m_slippage, sl, tp, comment, magic, expiration, arrow_color);

      if(ticket < 0)
        {
         int err = GetLastError();
         Print("[Error] OpenPending failed. Error: ", err, " | Symbol: ", symbol, " | Type: ", type, " | Price: ", price);
         return -1;
        }

      return (long)ticket;
     }

   //+------------------------------------------------------------------+
   //| Modify Order                                                     |
   //+------------------------------------------------------------------+
   virtual bool Modify(long ticket,
                       double sl,
                       double tp)
     {
      ResetLastError();

      // We must select the order to get open price and expiration
      if(!OrderSelect((int)ticket, SELECT_BY_TICKET))
        {
         int err = GetLastError();
         Print("[Error] Modify: Failed to select ticket ", ticket, ". Error: ", err);
         return false;
        }

      double open_price = OrderOpenPrice();
      datetime expiration = OrderExpiration();
      color arrow_color = OrderType() == OP_BUY ? clrBlue : (OrderType() == OP_SELL ? clrRed : clrGray);

      bool res = OrderModify((int)ticket, open_price, sl, tp, expiration, arrow_color);
      
      if(!res)
        {
         int err = GetLastError();
         Print("[Error] Modify failed. Ticket: ", ticket, " | Error: ", err);
         return false;
        }

      return true;
     }

   //+------------------------------------------------------------------+
   //| Close Market Order                                               |
   //+------------------------------------------------------------------+
   virtual bool Close(long ticket,
                      double lots,
                      string comment)
     {
      ResetLastError();

      // Select order to determine specific close price (Bid for Buy, Ask for Sell)
      if(!OrderSelect((int)ticket, SELECT_BY_TICKET))
        {
         int err = GetLastError();
         Print("[Error] Close: Failed to select ticket ", ticket, ". Error: ", err);
         return false;
        }

      string symbol = OrderSymbol();
      int type = OrderType();
      
      // Get current close price
      RefreshRates();
      double close_price = 0.0;
      
      if(type == OP_BUY)
         close_price = MarketInfo(symbol, MODE_BID);
      else if(type == OP_SELL)
         close_price = MarketInfo(symbol, MODE_ASK);
      else
        {
        // Not a market order? Maybe caller made a mistake invoking Close() on pending.
        // Try Delete() instead or return error.
        // Assuming Close() handles market orders as per contract.
        Print("[Warning] Close: Ticket ", ticket, " is not OP_BUY/OP_SELL.");
        // Try to close at OpenPrice? No, just fail or basic Close.
        // Actually, if it's pending, OrderClose fails.
        return false;
        }

      color arrow_color = (type == OP_BUY) ? clrRed : clrBlue; // Opposite color for close

      bool res = OrderClose((int)ticket, lots, close_price, m_slippage, arrow_color);

      if(!res)
        {
         int err = GetLastError();
         Print("[Error] Close failed. Ticket: ", ticket, " | Error: ", err);
         return false;
        }

      return true;
     }

   //+------------------------------------------------------------------+
   //| Delete Pending Order                                             |
   //+------------------------------------------------------------------+
   virtual bool Delete(long ticket)
     {
      ResetLastError();

      bool res = OrderDelete((int)ticket, clrNONE);

      if(!res)
        {
         int err = GetLastError();
         // Check if already closed/deleted
         Print("[Error] Delete failed. Ticket: ", ticket, " | Error: ", err);
         return false;
        }

      return true;
     }
  };
//+------------------------------------------------------------------+
