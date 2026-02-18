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
                     C_TradeEngineMT4(void) : m_slippage(1000), m_maxRetries(3), m_retryDelay(100) {};
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
         ticket = OrderSend(symbol, type, lots, sendPrice, GetSlippagePoints(g_MaxSlippage), normSL, normTP, comment, magic, 0, arrow_color);

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

         ticket = OrderSend(symbol, type, lots, normPrice, GetSlippagePoints(g_MaxSlippage), normSL, normTP, comment, magic, expiration, arrow_color);

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

         // Handle Pending Orders vs Market Positions
         if(type <= OP_SELL) // Market
         {
             if(type == OP_BUY) closePrice = MarketInfo(symbol, MODE_BID);
             else               closePrice = MarketInfo(symbol, MODE_ASK);
             
             int digits = (int)MarketInfo(symbol, MODE_DIGITS);
             closePrice = NormalizeDouble(closePrice, digits);
             color arrow_color = (type == OP_BUY) ? clrRed : clrBlue;

             // --- ROBUST TAGGING for Original Lots (MT4 Market) ---
             // Since we cannot change comments on live orders, we use GlobalVariables as a "Tag" system.
             // Protocol: When closing ticket T1, we store "FP_ORIG_LOTS_{T1}" = OriginalLots.
             // When the partial close happens, the new ticket T2 will be created.
             // We need to pass the " Soul" of T1 to T2.
             // But we don't know T2 yet.
             // HOWEVER, the new order will likely have comment "from #T1".
             
             // 1. Ensure we have the original lots recorded for THIS ticket
             double origLots = GetOriginalLotSize(tkt);
             if(origLots <= 0) origLots = OrderLots();
             
             // Store it in a Global Variable with a unique key based on the ticket
             string gvarName = "FP_ORG_" + IntegerToString(tkt);
             GlobalVariableSet(gvarName, origLots);
             
             // Also, since MT4's "from #ticket" comment is automatic on partial close,
             // our GetOriginalLotSize function needs to check GlobalVariables too!
             // (We will update TradeCalc.mqh next)
             
             bool res = OrderClose(tkt, lots, closePrice, GetSlippagePoints(g_MaxSlippage), arrow_color);
             if(res) return MakeSuccessResult(ticket, "Order Closed");
         }
         else // Pending
         {
             double currentLots = OrderLots();
             if(lots >= currentLots - 0.001) 
             {
                return Delete(ticket); // Full close = Delete
             }
             
             // Simulation of Partial Close for Pending
             double remainLots = currentLots - lots;
             double price = OrderOpenPrice();
             double sl = OrderStopLoss();
             double tp = OrderTakeProfit();
             int magic = OrderMagicNumber();
             datetime exp = OrderExpiration();
             string sym = OrderSymbol();
             int pType = OrderType();
             
             // Extract optional user comment parts (if any)
             // Extract optional user comment parts (if any)
             string baseComment = OrderComment();
             
             // --- ROBUST TAGGING for Original Lots ---
             string tag = "";
             int tagPos = StringFind(baseComment, "Org:");
             if(tagPos >= 0)
             {
                 // Preserve existing tag
                 // Simple parse: extract until end or space
                 string sub = StringSubstr(baseComment, tagPos + 4);
                 double val = StringToDouble(sub);
                 tag = "Org:" + DoubleToString(val, 2); 
             }
             else
             {
                 // Create new tag from current total
                 tag = "Org:" + DoubleToString(currentLots, 2);
             }
             
             // Combine tag with trace info
             string newComment = tag + " from #" + IntegerToString((int)ticket);
             
             // 1. Delete
             if(!OrderDelete(tkt, clrNONE))
             {
                err = GetLastError();
                if(IsRetryableError(err)) { Sleep(m_retryDelay); continue; }
                break;
             }
             
             // 2. Re-Open with reduced lots
             TradeResult openRes = OpenPending(sym, pType, remainLots, price, sl, tp, newComment, magic, exp);
             if(openRes.Success)
             {
                return MakeSuccessResult(openRes.Ticket, "Pending Order Partially Closed (Simulated)");
             }
             return openRes; // Return error from OpenPending
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
