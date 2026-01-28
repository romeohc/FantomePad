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
   string fullMsg = "Error " + IntegerToString(error) + ": " + desc;
   if(extraMsg != "") fullMsg += " (" + extraMsg + ")";
   
   Print(fullMsg);
   
   // Set Toast Global (picked up by GUI)
   g_ToastMsg = fullMsg;
   g_ToastColor = g_ColorRed;
   g_ToastStartTime = GetTickCount();
}

void HandleTradeMessage(string msg, color col)
{
   Print(msg);
   g_ToastMsg = msg;
   g_ToastColor = col;
   g_ToastStartTime = GetTickCount();
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
      
      if((cmd == OP_BUY || cmd == OP_SELL) && AccountFreeMargin() < requiredMargin)
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
