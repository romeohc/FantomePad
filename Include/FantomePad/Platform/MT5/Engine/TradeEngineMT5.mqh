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

public:
                     C_TradeEngineMT5(void) : m_slippage(10) 
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
      m_trade.SetDeviationInPoints(m_slippage);

      // Execute Type Mapping and Validation
      // Assumes 'type' matches MT4 OP_BUY/OP_SELL which match MT5 ORDER_TYPE_BUY/SELL
      ENUM_ORDER_TYPE order_type = (ENUM_ORDER_TYPE)type;

      // Executing
      // We use PositionOpen for explicitly opening a position at market
      if(!m_trade.PositionOpen(symbol, order_type, lots, price, sl, tp, comment))
        {
         return TradeErrorHandler::FromMT5RetCode(m_trade.ResultRetcode(), "OpenMarket");
        }

      // Return the Deal Order Ticket (which becomes the Position Ticket in Hedging)
      return MakeSuccessResult(m_trade.ResultOrder());
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

      // limit_price is 0 for standard pending orders (StopLimit not supported nicely in this unified interface yet)
      if(!m_trade.OrderOpen(symbol, order_type, lots, 0.0, price, sl, tp, type_time, expiration, comment))
        {
         return TradeErrorHandler::FromMT5RetCode(m_trade.ResultRetcode(), "OpenPending");
        }

      return MakeSuccessResult(m_trade.ResultOrder());
     }

   //+------------------------------------------------------------------+
   //| Modify Order (Position or Pending)                               |
   //+------------------------------------------------------------------+
   virtual TradeResult Modify(long ticket,
                       double sl,
                       double tp)
     {
      // Try to modify as Position first (Live Trade)
      if(PositionSelectByTicket(ticket))
        {
         if(!m_trade.PositionModify(ticket, sl, tp))
           {
            return TradeErrorHandler::FromMT5RetCode(m_trade.ResultRetcode(), "Modify Position");
           }
         return MakeSuccessResult(ticket);
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
         
         if(!m_trade.OrderModify(ticket, price, sl, tp, type_time, expiration))
           {
            return TradeErrorHandler::FromMT5RetCode(m_trade.ResultRetcode(), "Modify Order");
           }
         return MakeSuccessResult(ticket);
        }

      return MakeErrorResult(0, TRADE_ERR_VALIDATION, "Ticket not found (neither Position nor Order)");
     }

   //+------------------------------------------------------------------+
   //| Close Market Order (Position)                                    |
   //+------------------------------------------------------------------+
   virtual TradeResult Close(long ticket,
                      double lots,
                      string comment)
     {
      // Check if ticket exists
      if(!PositionSelectByTicket(ticket))
        {
         return MakeErrorResult(0, TRADE_ERR_VALIDATION, "Position not found for close");
        }
        
      double vol = PositionGetDouble(POSITION_VOLUME);
      
      if(lots < vol - 0.000001) // Partial close
      {
         // Fix: Proper initialization of MqlTradeRequest to avoid 'cannot convert 0 to enum' error
         MqlTradeRequest request;
         ZeroMemory(request);
         
         MqlTradeResult  result;
         ZeroMemory(result);
         
         request.action = TRADE_ACTION_DEAL;
         request.position = ticket;
         request.symbol = PositionGetString(POSITION_SYMBOL);
         request.volume = lots;
         request.deviation = m_slippage;
         request.magic = m_trade.RequestMagic();
         
         // OPPOSITE TYPE
         long type = PositionGetInteger(POSITION_TYPE);
         if(type == POSITION_TYPE_BUY) request.type = ORDER_TYPE_SELL;
         else                          request.type = ORDER_TYPE_BUY;
         
         // PRICE
         // We need current Bid/Ask
         if(request.type == ORDER_TYPE_BUY) request.price = SymbolInfoDouble(request.symbol, SYMBOL_ASK);
         else                               request.price = SymbolInfoDouble(request.symbol, SYMBOL_BID);
         
         if(!OrderSend(request, result))
         {
             return TradeErrorHandler::FromMT5RetCode(result.retcode, "Partial Close");
         }
         return MakeSuccessResult(result.order);
      }
      else
      {
         // Full close
         if(!m_trade.PositionClose(ticket, m_slippage))
           {
            return TradeErrorHandler::FromMT5RetCode(m_trade.ResultRetcode(), "Close");
           }
         return MakeSuccessResult(ticket);
      }
     }

   //+------------------------------------------------------------------+
   //| Delete Pending Order                                             |
   //+------------------------------------------------------------------+
   virtual TradeResult Delete(long ticket)
     {
      if(!m_trade.OrderDelete(ticket))
        {
         return TradeErrorHandler::FromMT5RetCode(m_trade.ResultRetcode(), "Delete");
        }
      return MakeSuccessResult(ticket);
     }
  };

// --- RESTORE MACROS FOR SUBSEQUENT FILES ---
// We must restore OrderSelect to FP_OrderSelect so that the rest of the application (GUI) 
// continues to work with the compatibility layer.
#define OrderSelect FP_OrderSelect
//+------------------------------------------------------------------+
