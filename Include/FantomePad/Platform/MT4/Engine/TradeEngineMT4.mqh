//+------------------------------------------------------------------+
//|                                             TradeEngineMT4.mqh   |
//|                                                   FantomePad LLC |
//|                                  http://www.fantomepad.com       |
//+------------------------------------------------------------------+
#property copyright "FantomePad LLC"
#property link      "http://www.fantomepad.com"
#property strict

// Include the Interface and Error Handler
#include "../../Common/Core/Engine/ITradeEngine.mqh"
#include "../../Common/Core/Engine/TradeErrorHandler.mqh"

//+------------------------------------------------------------------+
//| MT4 Implementation of the Trading Engine                         |
//| Robust implementation with Retries, Busy Check, and Hardening.   |
//+------------------------------------------------------------------+
class C_TradeEngineMT4 : public ITradeEngine
  {
private:
   int               m_slippage;    // Default slippage points
   int               m_maxRetries;  // Max retries for trade operations
   int               m_retryDelay;  // Delay in ms between retries

   //Helper: Check if error is retryable
   bool IsRetryableError(int err)
     {
      // 135: Price Changed (Requote)
      // 136: Off Quotes
      // 137: Broker Busy
      // 138: Requote
      // 146: Trade Context Busy
      // 141: Too many requests
      if(err == 135 || err == 136 || err == 137 || err == 138 || err == 146 || err == 141)
         return true;
      return false;
     }

public:
                     C_TradeEngineMT4(void) : m_slippage(10), m_maxRetries(3), m_retryDelay(100) {};
                    ~C_TradeEngineMT4(void) {};

   //+------------------------------------------------------------------+
   //| Open Market Order                                                |
   //+------------------------------------------------------------------+
   virtual TradeResult OpenMarket(string symbol,
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
      if(lots <= 0) return MakeErrorResult(0, TRADE_ERR_VALIDATION, "Invalid lots");
      if(symbol == "") symbol = Symbol();

      color arrow_color = (type == OP_BUY) ? clrBlue : ((type == OP_SELL) ? clrRed : clrNONE);
      int ticket = -1;
      int err = 0;

      for(int i = 0; i < m_maxRetries; i++)
        {
         // 1. Check Context
         if(IsTradeContextBusy())
           {
            Sleep(m_retryDelay);
            continue;
           }

         // 2. Refresh Rates & Price
         RefreshRates();
         double sendPrice = price;
         
         // Always force fresh price for Market Execution to avoid stale prices
         if(type == OP_BUY) sendPrice = MarketInfo(symbol, MODE_ASK);
         else if(type == OP_SELL) sendPrice = MarketInfo(symbol, MODE_BID);
         
         // Normalize
         int digits = (int)MarketInfo(symbol, MODE_DIGITS);
         sendPrice = NormalizeDouble(sendPrice, digits);
         double normSL = NormalizeDouble(sl, digits);
         double normTP = NormalizeDouble(tp, digits);

         // 3. Execute
         ticket = OrderSend(symbol, type, lots, sendPrice, m_slippage, normSL, normTP, comment, magic, 0, arrow_color);

         if(ticket > 0)
           {
             return MakeSuccessResult(ticket, "Market Order Opened");
           }

         // 4. Handle Error
         err = GetLastError();
         if(IsRetryableError(err))
           {
            Sleep(m_retryDelay);
            continue;
           }
         else
           {
            // Fatal error, break immediately
            break;
           }
        }

      return TradeErrorHandler::FromBrokerError(err, "OpenMarket");
     }

   //+------------------------------------------------------------------+
   //| Open Pending Order                                               |
   //+------------------------------------------------------------------+
   virtual TradeResult OpenPending(string symbol,
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
      if(lots <= 0) return MakeErrorResult(0, TRADE_ERR_VALIDATION, "Invalid lots");
      if(symbol == "") symbol = Symbol();

      color arrow_color = clrGray;
      int ticket = -1;
      int err = 0;

      for(int i = 0; i < m_maxRetries; i++)
        {
         if(IsTradeContextBusy())
           {
            Sleep(m_retryDelay);
            continue;
           }

         RefreshRates(); // Good practice even for pending
         
         int digits = (int)MarketInfo(symbol, MODE_DIGITS);
         double normPrice = NormalizeDouble(price, digits);
         double normSL = NormalizeDouble(sl, digits);
         double normTP = NormalizeDouble(tp, digits);

         ticket = OrderSend(symbol, type, lots, normPrice, m_slippage, normSL, normTP, comment, magic, expiration, arrow_color);

         if(ticket > 0)
           {
             return MakeSuccessResult(ticket, "Pending Order Placed");
           }

         err = GetLastError();
         if(IsRetryableError(err))
           {
            Sleep(m_retryDelay);
            continue;
           }
         else
           {
            break;
           }
        }

      return TradeErrorHandler::FromBrokerError(err, "OpenPending");
     }

   //+------------------------------------------------------------------+
   //| Modify Order                                                     |
   //+------------------------------------------------------------------+
   virtual TradeResult Modify(long ticket,
                       double sl,
                       double tp)
     {
      ResetLastError();
      int digits = 0;
      double openPrice = 0;
      datetime expiration = 0;
      color arrow_color = clrNONE;

      // We must select the order to get open price and expiration
      if(OrderSelect((int)ticket, SELECT_BY_TICKET))
        {
          string symbol = OrderSymbol();
          digits = (int)MarketInfo(symbol, MODE_DIGITS);
          openPrice = OrderOpenPrice();
          expiration = OrderExpiration();
          arrow_color = (OrderType() == OP_BUY) ? clrBlue : ((OrderType() == OP_SELL) ? clrRed : clrGray);
        }
      else
        {
         return MakeErrorResult(GetLastError(), TRADE_ERR_BROKER, "Order not found");
        }

      double normSL = NormalizeDouble(sl, digits);
      double normTP = NormalizeDouble(tp, digits);
      openPrice = NormalizeDouble(openPrice, digits); // Be safe

      int err = 0;

      for(int i = 0; i < m_maxRetries; i++)
        {
         if(IsTradeContextBusy())
           {
            Sleep(m_retryDelay);
            continue;
           }

         bool res = OrderModify((int)ticket, openPrice, normSL, normTP, expiration, arrow_color);
         
         if(res) return MakeSuccessResult(ticket, "Order Modified");

         err = GetLastError();
         
         // Error 1: ERR_NO_RESULT (Values are the same) -> Treat as success
         if(err == 1) return MakeSuccessResult(ticket, "No changes needed");

         if(IsRetryableError(err))
           {
            Sleep(m_retryDelay);
            continue;
           }
         else
           {
            break;
           }
        }

      return TradeErrorHandler::FromBrokerError(err, "Modify");
     }

   //+------------------------------------------------------------------+
   //| Close Order                                                      |
   //+------------------------------------------------------------------+
   virtual TradeResult Close(long ticket,
                      double lots,
                      string comment)
     {
      ResetLastError();
      
      int tkt = (int)ticket;
      int err = 0;

      for(int i = 0; i < m_maxRetries; i++)
        {
         if(IsTradeContextBusy())
           {
            Sleep(m_retryDelay);
            continue;
           }
           
         // Always refresh and select to get latest state
         RefreshRates();
         if(!OrderSelect(tkt, SELECT_BY_TICKET))
           {
             return MakeErrorResult(GetLastError(), TRADE_ERR_BROKER, "Order not found during Close");
           }
           
         // Check if already closed
         if(OrderCloseTime() > 0) return MakeSuccessResult(ticket, "Order already closed");

         string symbol = OrderSymbol();
         int type = OrderType();
         double closePrice = 0.0;

         if(type == OP_BUY) closePrice = MarketInfo(symbol, MODE_BID);
         else if(type == OP_SELL) closePrice = MarketInfo(symbol, MODE_ASK);
         else 
           {
             return MakeErrorResult(0, TRADE_ERR_VALIDATION, "Cannot Close pending order");
           }

         int digits = (int)MarketInfo(symbol, MODE_DIGITS);
         closePrice = NormalizeDouble(closePrice, digits);
         color arrow_color = (type == OP_BUY) ? clrRed : clrBlue;

         bool res = OrderClose(tkt, lots, closePrice, m_slippage, arrow_color);
         
         if(res) return MakeSuccessResult(ticket, "Order Closed");
         
         err = GetLastError();
         if(IsRetryableError(err))
           {
            Sleep(m_retryDelay);
            continue;
           }
         else
           {
            break;
           }
        }

      return TradeErrorHandler::FromBrokerError(err, "Close");
     }

   //+------------------------------------------------------------------+
   //| Delete Order                                                     |
   //+------------------------------------------------------------------+
   virtual TradeResult Delete(long ticket)
     {
      ResetLastError();
      int tkt = (int)ticket;
      int err = 0;

      for(int i = 0; i < m_maxRetries; i++)
        {
         if(IsTradeContextBusy())
           {
            Sleep(m_retryDelay);
            continue;
           }

         // Optional: Check existence. 
         if(OrderSelect(tkt, SELECT_BY_TICKET) && OrderCloseTime() > 0)
            return MakeSuccessResult(ticket, "Order already deleted/closed");

         bool res = OrderDelete(tkt, clrNONE);
         
         if(res) return MakeSuccessResult(ticket, "Order Deleted");
         
         err = GetLastError();
         
         // Error 4051: Invalid function param value (sometimes happens if ticket invalid)
         // Error 4108: Invalid ticket
         if(err == 4108) return MakeErrorResult(err, TRADE_ERR_BROKER, "Invalid Ticket");

         if(IsRetryableError(err))
           {
            Sleep(m_retryDelay);
            continue;
           }
         else
           {
            break;
           }
        }

      return TradeErrorHandler::FromBrokerError(err, "Delete");
     }
  };
//+------------------------------------------------------------------+
