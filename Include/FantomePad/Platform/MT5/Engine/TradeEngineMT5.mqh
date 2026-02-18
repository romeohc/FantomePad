//+------------------------------------------------------------------+
//|                                             TradeEngineMT5.mqh   |
//|                                                   FantomePad LLC |
//|                                  http://www.fantomepad.com       |
//+------------------------------------------------------------------+
#property copyright "FantomePad LLC"
#property link      "http://www.fantomepad.com"
#property strict

// Include the Interface
#include "../../Common/Core/Engine/ITradeEngine.mqh"
#include "../../Common/Core/Engine/TradeErrorHandler.mqh"

// --- FIX: MACRO CONFLICT RESOLUTION ---
// The Compatibility layer defines 'OrderSelect' as 'FP_OrderSelect' (MT4 Style).
// However, the MT5 Standard Library (<Trade/Trade.mqh>) uses the native 'OrderSelect' (1 arg).
// We must undefine the macro locally to allow the Standard Library to compile.
#ifdef OrderSelect
   #undef OrderSelect
#endif

// Include Standard Library for MT5
#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| MT5 Implementation of the Trading Engine                         |
//+------------------------------------------------------------------+
class C_TradeEngineMT5 : public ITradeEngine
  {
private:
   CTrade            m_trade;       // Standard Library Trade Object
   int               m_slippage;    // Default deviation
   int               m_maxRetries;  // Max retries for trade operations
   int               m_retryDelay;  // Delay in ms between retries

   //Helper: Check if error is retryable
   bool IsRetryableError(uint retcode)
     {
      // 10004: TRADE_RETCODE_REQUOTE
      // 10006: TRADE_RETCODE_REJECT
      // 10012: TRADE_RETCODE_CONNECTION
      // 10015: TRADE_RETCODE_TIMEOUT
      // 10020: TRADE_RETCODE_PRICE_CHANGED
      // 10021: TRADE_RETCODE_PRICE_OFF
      // 10024: TRADE_RETCODE_TOO_MANY_REQUESTS
      // 10028: TRADE_RETCODE_LOCKED
      if(retcode == 10004 || retcode == 10006 || retcode == 10012 || 
         retcode == 10015 || retcode == 10020 || retcode == 10021 || 
         retcode == 10024 || retcode == 10028)
         return true;
      return false;
     }

public:
                     C_TradeEngineMT5(void) : m_slippage(1000), m_maxRetries(3), m_retryDelay(100) 
     {
      // Log level can be adjusted
      m_trade.LogLevel(LOG_LEVEL_ERRORS);
      m_trade.SetDeviationInPoints(m_slippage);
      m_trade.SetAsyncMode(false); // Sync mode for reliability in this phase
     };
                    ~C_TradeEngineMT5(void) {};

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
      // Configure Request
      m_trade.SetExpertMagicNumber(magic);
      m_trade.SetDeviationInPoints(g_MaxSlippage);

      // Execute Type Mapping and Validation
      ENUM_ORDER_TYPE order_type = (ENUM_ORDER_TYPE)type;
      uint retcode = 0;

      for(int i = 0; i < m_maxRetries; i++)
        {
         // 1. Refresh Price (In MT5, SymbolInfoTick is better for fresh Bid/Ask)
         double sendPrice = price;
         if(order_type == ORDER_TYPE_BUY) sendPrice = SymbolInfoDouble(symbol, SYMBOL_ASK);
         else if(order_type == ORDER_TYPE_SELL) sendPrice = SymbolInfoDouble(symbol, SYMBOL_BID);

         // 2. Execute
         if(m_trade.PositionOpen(symbol, order_type, lots, sendPrice, sl, tp, comment))
           {
            return MakeSuccessResult(m_trade.ResultOrder());
           }

         // 3. Handle Error
         retcode = m_trade.ResultRetcode();
         if(IsRetryableError(retcode))
           {
            Sleep(m_retryDelay);
            continue;
           }
         else break;
        }

      return TradeErrorHandler::FromMT5RetCode(retcode, "OpenMarket");
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
      m_trade.SetExpertMagicNumber(magic);
      
      ENUM_ORDER_TYPE order_type = (ENUM_ORDER_TYPE)type;
      ENUM_ORDER_TYPE_TIME type_time = (expiration > 0) ? ORDER_TIME_SPECIFIED : ORDER_TIME_GTC;

      // Ensure expiration is valid if specified
      if(type_time == ORDER_TIME_SPECIFIED && expiration <= TimeCurrent())
      {
         return MakeErrorResult(0, TRADE_ERR_VALIDATION, "Expiration time in the past");
      }

      uint retcode = 0;
      for(int i = 0; i < m_maxRetries; i++)
        {
         if(m_trade.OrderOpen(symbol, order_type, lots, 0.0, price, sl, tp, type_time, expiration, comment))
           {
            return MakeSuccessResult(m_trade.ResultOrder());
           }

         retcode = m_trade.ResultRetcode();
         if(IsRetryableError(retcode))
           {
            Sleep(m_retryDelay);
            continue;
           }
         else break;
        }

      return TradeErrorHandler::FromMT5RetCode(retcode, "OpenPending");
     }

   //+------------------------------------------------------------------+
   //| Modify Order (Position or Pending)                               |
   //+------------------------------------------------------------------+
   virtual TradeResult Modify(long ticket,
                       double sl,
                       double tp)
     {
      uint retcode = 0;

      // Try to modify as Position first (Live Trade)
      if(PositionSelectByTicket(ticket))
      {
         for(int i = 0; i < m_maxRetries; i++)
           {
            if(m_trade.PositionModify(ticket, sl, tp))
              {
               return MakeSuccessResult(ticket);
              }

            retcode = m_trade.ResultRetcode();
            if(IsRetryableError(retcode))
              {
               Sleep(m_retryDelay);
               continue;
              }
            else break;
           }
         return TradeErrorHandler::FromMT5RetCode(retcode, "Modify Position");
      }
      
      // If not position, try to modify as Pending Order
      // Check if order exists
      // Note: We use native OrderSelect (1 arg) here because we undefined the macro above!
      if(OrderSelect(ticket)) 
      {
         // OrderModify in CTrade wraps OrderSend with REQUEST_MODIFY
         // Note: CTrade::OrderModify requires price, type_time, expiration.
         // We must fetch them to keep them unchanged.
         
         double price = OrderGetDouble(ORDER_PRICE_OPEN);
         datetime expiration = (datetime)OrderGetInteger(ORDER_TIME_EXPIRATION);
         ENUM_ORDER_TYPE_TIME type_time = (ENUM_ORDER_TYPE_TIME)OrderGetInteger(ORDER_TYPE_TIME);
         
         for(int i = 0; i < m_maxRetries; i++)
           {
            if(m_trade.OrderModify(ticket, price, sl, tp, type_time, expiration))
              {
               return MakeSuccessResult(ticket);
              }

            retcode = m_trade.ResultRetcode();
            if(IsRetryableError(retcode))
              {
               Sleep(m_retryDelay);
               continue;
              }
            else break;
           }
         return TradeErrorHandler::FromMT5RetCode(retcode, "Modify Order");
      }

      return MakeErrorResult(0, TRADE_ERR_VALIDATION, "Ticket not found (neither Position nor Order)");
     }

   //+------------------------------------------------------------------+
   //| Close Market Order (Position) or Pending Order                   |
   //+------------------------------------------------------------------+
   virtual TradeResult Close(long ticket,
                      double lots,
                      string comment)
     {
      // Try to select as Position first
      if(PositionSelectByTicket(ticket))
      {
         double vol = PositionGetDouble(POSITION_VOLUME);
         uint retcode = 0;
         
         if(lots < vol - 0.000001) // Partial close
         {
            MqlTradeRequest request;
            MqlTradeResult  result;
            
            for(int i = 0; i < m_maxRetries; i++)
            {
               ZeroMemory(request);
               ZeroMemory(result);
               
               request.action = TRADE_ACTION_DEAL;
               request.position = ticket;
               request.symbol = PositionGetString(POSITION_SYMBOL);
               request.volume = lots;
               request.deviation = g_MaxSlippage;
               request.magic = m_trade.RequestMagic();
               request.comment = comment; // Pass the comment
               
               long type = PositionGetInteger(POSITION_TYPE);
               if(type == POSITION_TYPE_BUY) request.type = ORDER_TYPE_SELL;
               else                          request.type = ORDER_TYPE_BUY;
               
               if(request.type == ORDER_TYPE_BUY) request.price = SymbolInfoDouble(request.symbol, SYMBOL_ASK);
               else                               request.price = SymbolInfoDouble(request.symbol, SYMBOL_BID);
               
               if(OrderSend(request, result))
               {
                  return MakeSuccessResult(result.order);
               }

               retcode = result.retcode;
               if(IsRetryableError(retcode))
               {
                  Sleep(m_retryDelay);
                  continue;
               }
               else break;
            }
            return TradeErrorHandler::FromMT5RetCode(retcode, "Partial Close");
         }
         else
         {
            // Full close
            for(int i = 0; i < m_maxRetries; i++)
            {
               if(m_trade.PositionClose(ticket, g_MaxSlippage))
               {
                  return MakeSuccessResult(ticket);
               }

               retcode = m_trade.ResultRetcode();
               if(IsRetryableError(retcode))
               {
                  Sleep(m_retryDelay);
                  continue;
               }
               else break;
            }
            return TradeErrorHandler::FromMT5RetCode(retcode, "Close");
         }
      }
      // If not position, try to select as Pending Order
      else if(OrderSelect(ticket))
      {
         double currentLots = OrderGetDouble(ORDER_VOLUME_INITIAL);
         if(lots >= currentLots - 0.00001) 
         {
            return Delete(ticket); // Full close = Delete
         }
         
         // Simulation of Partial Close for Pending
         double remainLots = currentLots - lots;
         double price = OrderGetDouble(ORDER_PRICE_OPEN);
         double sl = OrderGetDouble(ORDER_SL);
         double tp = OrderGetDouble(ORDER_TP);
         int magic = (int)OrderGetInteger(ORDER_MAGIC);
         datetime exp = (datetime)OrderGetInteger(ORDER_TIME_EXPIRATION);
         string sym = OrderGetString(ORDER_SYMBOL);
         int pType = (int)OrderGetInteger(ORDER_TYPE);
         
         // 1. Delete
         TradeResult delRes = Delete(ticket);
         if(!delRes.Success) return delRes;
         
         
         // --- ROBUST TAGGING for Original Lots ---
         string baseComment = OrderGetString(ORDER_COMMENT);
         string tag = "";
         int tagPos = StringFind(baseComment, "Org:");
         if(tagPos >= 0)
         {
             string sub = StringSubstr(baseComment, tagPos + 4);
             double val = StringToDouble(sub);
             tag = "Org:" + DoubleToString(val, 2); 
         }
         else
         {
             tag = "Org:" + DoubleToString(currentLots, 2);
         }
         
         // 2. Re-Open with reduced lots
         string newComment = tag + " from #" + IntegerToString((int)ticket);
         return OpenPending(sym, pType, remainLots, price, sl, tp, newComment, magic, exp);
      }
      
      return MakeErrorResult(0, TRADE_ERR_VALIDATION, "Ticket not found for close");
     }

   //+------------------------------------------------------------------+
   //| Delete Pending Order                                             |
   //+------------------------------------------------------------------+
   virtual TradeResult Delete(long ticket)
     {
      uint retcode = 0;
      for(int i = 0; i < m_maxRetries; i++)
        {
         if(m_trade.OrderDelete(ticket))
           {
            return MakeSuccessResult(ticket);
           }

         retcode = m_trade.ResultRetcode();
         if(IsRetryableError(retcode))
           {
            Sleep(m_retryDelay);
            continue;
           }
         else break;
        }

      return TradeErrorHandler::FromMT5RetCode(retcode, "Delete");
     }
  };

// --- RESTORE MACROS FOR SUBSEQUENT FILES ---
// We must restore OrderSelect to FP_OrderSelect so that the rest of the application (GUI) 
// continues to work with the compatibility layer.
#define OrderSelect FP_OrderSelect
//+------------------------------------------------------------------+
