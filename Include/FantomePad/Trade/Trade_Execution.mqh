//+------------------------------------------------------------------+
//|                                              Trade_Execution.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _TRADE_EXECUTION_MQH_
#define _TRADE_EXECUTION_MQH_

#include "../Core/Defines.mqh"
#include "Trade_Constants.mqh"
#include <stdlib.mqh>

//+------------------------------------------------------------------+
//| ERROR HANDLING HELPERS                                           |
//+------------------------------------------------------------------+
void HandleTradeError(int error, string extraMsg="")
{
   string desc = ErrorDescription(error);
   string userMsg = desc; 
   
   // simplify technical messages for the users
   if(error == 130) userMsg = "Invalid SL/TP or too close to price.";
   if(error == 132) userMsg = "Market is closed.";
   if(error == 133) userMsg = "Trading is disabled for this account/symbol.";
   if(error == 134) userMsg = "Insufficient Margin!";
   if(error == 4109) userMsg = "Expert Trading not allowed by broker.";
   
   // log detailed technical info to journal
   string logMsg = "Trade Error " + IntegerToString(error) + ": " + desc;
   if(extraMsg != "") logMsg += " (" + extraMsg + ")";
   Print(logMsg);
   
   // user friendly message for GUI
   g_ToastMsg = userMsg;
   g_ToastColor = g_ColorRed;
   g_ToastStartTime = GetTickCount();
   g_LastTradeErrorMsg = userMsg;
}

void HandleTradeMessage(string msg, color col)
{
   Print(msg);
   g_ToastMsg = msg;
   g_ToastColor = col;
   g_ToastStartTime = GetTickCount();
   g_LastTradeErrorMsg = msg;
}

//+------------------------------------------------------------------+
//| SAFE ORDER EXECUTION                                             |
//+------------------------------------------------------------------+
int SafeOrderSend(string symbol, int cmd, double volume, double price, int slippage, double sl, double tp, string comment, int magic, datetime expiration, color clr)
{
   int ticket = -1;
   int error = 0;
   
   for(int i = 0; i < MAX_RETRIES; i++)
   {
      RefreshRates();
      
      if(cmd == OP_BUY)       price = MarketInfo(symbol, MODE_ASK);
      if(cmd == OP_SELL)      price = MarketInfo(symbol, MODE_BID);
      
      price = NormalizeDouble(price, (int)MarketInfo(symbol, MODE_DIGITS));
      
      // MARGIN CHECK
      double requiredMargin = MarketInfo(symbol, MODE_MARGINREQUIRED) * volume;
      requiredMargin *= 1.10; // Safety buffer
      
      if(AccountFreeMargin() < requiredMargin)
      {
         HandleTradeError(134, "Insufficient Free Margin (Need: " + DoubleToString(requiredMargin, 2) + ", Have: " + DoubleToString(AccountFreeMargin(), 2) + ")");
         return -1;
      }

      // STOPLEVEL VALIDATION
      int stopLevel = (int)MarketInfo(symbol, MODE_STOPLEVEL);
      if(stopLevel > 0)
      {
         double minDist = stopLevel * MarketInfo(symbol, MODE_POINT);
         double digits = MarketInfo(symbol, MODE_DIGITS);
         
         if(sl > 0 && MathAbs(price - sl) < minDist)
         {
            HandleTradeError(130, "StopLoss too close (Min: " + DoubleToString(minDist, (int)digits) + " pts)");
            return -1;
         }
         if(tp > 0 && MathAbs(price - tp) < minDist)
         {
            HandleTradeError(130, "TakeProfit too close (Min: " + DoubleToString(minDist, (int)digits) + " pts)");
            return -1;
         }
         
         if(cmd > 1) // Pending Order
         {
             double currentPrice = (cmd == OP_BUYLIMIT || cmd == OP_BUYSTOP) ? MarketInfo(symbol, MODE_ASK) : MarketInfo(symbol, MODE_BID);
             if(MathAbs(price - currentPrice) < minDist)
             {
                 HandleTradeError(130, "Pending Entry too close to Market (Min: " + DoubleToString(minDist, (int)digits) + " pts)");
                 return -1;
             }
         }
      }
      
      ticket = OrderSend(symbol, cmd, volume, price, slippage, sl, tp, comment, magic, expiration, clr);
      if(ticket >= 0) return ticket;
      
      error = GetLastError();
      if(error == 135 || error == 136 || error == 137 || error == 138 || error == 146)
      {
         Sleep(RETRY_DELAY);
         continue; 
      }
      else break;
   }
   
   HandleTradeError(error, "SafeOrderSend Failed");
   return -1;
}

bool SafeOrderClose(int ticket, double lots, double price, int slippage, color clr)
{
   bool result = false;
   int error = 0;
   
   for(int i = 0; i < MAX_RETRIES; i++)
   {
      RefreshRates();
      if(OrderSelect(ticket, SELECT_BY_TICKET))
      {
         if(OrderType() == OP_BUY) price = MarketInfo(OrderSymbol(), MODE_BID);
         else                      price = MarketInfo(OrderSymbol(), MODE_ASK);
      }
      else return false;
      
      result = OrderClose(ticket, lots, price, slippage, clr);
      if(result) return true;
      
      error = GetLastError();
      if(error == 135 || error == 136 || error == 137 || error == 138 || error == 146)
      {
         Sleep(RETRY_DELAY);
         continue;
      }
      else break;
   }
   
   HandleTradeError(error, "SafeOrderClose Failed");
   return false;
}

bool SafeOrderModify(int ticket, double price, double sl, double tp, datetime expiration, color clr)
{
   bool result = false;
   int error = 0;
   
   for(int i = 0; i < MAX_RETRIES; i++)
   {
      if(IsTradeContextBusy()) 
      {
         Sleep(RETRY_DELAY);
         continue;
      }
      
      result = OrderModify(ticket, price, sl, tp, expiration, clr);
      if(result) return true;
      
      error = GetLastError();
      if(error == 1) return true; 
      
      if(error == 136 || error == 137 || error == 146)
      {
         Sleep(RETRY_DELAY);
         continue;
      }
      else break;
   }
   
   HandleTradeError(error, "SafeOrderModify Failed");
   return false;
}

bool SafeOrderDelete(int ticket, color clr = clrNONE)
{
   bool result = false;
   int error = 0;
   
   for(int i = 0; i < MAX_RETRIES; i++)
   {
      if(IsTradeContextBusy()) 
      {
         Sleep(RETRY_DELAY);
         continue;
      }
      
      result = OrderDelete(ticket, clr);
      if(result) return true;
      
      error = GetLastError();
      if(error == 146 || error == 4108)
      {
         Sleep(RETRY_DELAY);
         continue;
      }
      else break;
   }
   
   HandleTradeError(error, "SafeOrderDelete Failed for ticket #" + IntegerToString(ticket));
   return false;
}

#endif
