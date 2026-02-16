//+------------------------------------------------------------------+
//|                                            TradeErrorHandler.mqh |
//|                                              FantomePad Project  |
//|                         Unified Error Handling & Toast Feedback  |
//+------------------------------------------------------------------+
#ifndef _TRADE_ERROR_HANDLER_MQH_
#define _TRADE_ERROR_HANDLER_MQH_

#include "../DataTypes.mqh"
#include "../Defines.mqh"
#include <stdlib.mqh> // For ErrorDescription()

class TradeErrorHandler {
public:
   //+------------------------------------------------------------------+
   //| Convertit un code d'erreur natif en TradeResult user-friendly    |
   //+------------------------------------------------------------------+
   static TradeResult FromBrokerError(int error, string context = "")
   {
      string userMsg = "";
      ENUM_TRADE_ERROR_TYPE type = TRADE_ERR_BROKER;
      string desc = ErrorDescription(error);

      // Mapping Logic from Legacy Trade_Execution.mqh
      if(error == 130) {
         userMsg = "Invalid SL/TP or too close to price.";
         type = TRADE_ERR_STOPLEVEL;
      }
      else if(error == 132) {
         userMsg = "Market is closed.";
         type = TRADE_ERR_MARKET;
      }
      else if(error == 133) {
         userMsg = "Trading is disabled.";
         type = TRADE_ERR_PERMISSION;
      }
      else if(error == 134) {
         userMsg = "Insufficient Margin!";
         type = TRADE_ERR_MARGIN;
      }
      else if(error == 128 || error == 129 || error == 131) {
         userMsg = "Invalid volume/price.";
         type = TRADE_ERR_VALIDATION;
      }
      else if(error == 4109) {
         userMsg = "Expert Trading not allowed by broker.";
         type = TRADE_ERR_PERMISSION;
      }
      else if(error == 135 || error == 136 || error == 137 || error == 138 || error == 146) {
         userMsg = "Broker Busy/Requote (Retry failed).";
         type = TRADE_ERR_RETRY_EXHAUSTED;
      }
      else if(error == 0) {
         return MakeSuccessResult(0, "OK");
      }
      else {
         userMsg = "Error " + IntegerToString(error);
         type = TRADE_ERR_UNKNOWN;
      }
      
      // Fallback description if generic
      if(StringLen(userMsg) == 0) userMsg = desc;

      string techDetail = "Error " + IntegerToString(error) + ": " + desc;
      if(context != "") techDetail += " (" + context + ")";
      
      return MakeErrorResult(error, type, userMsg, techDetail);
   }

   //+------------------------------------------------------------------+
   //| Mappe les RetCodes MT5 en messages lisibles (Placeholder MT4/MT5)|
   //+------------------------------------------------------------------+
   static TradeResult FromMT5RetCode(uint retcode, string context = "")
   {
      // Basic mapping based on standard MT5 retcodes
      // 10009 = DONE, 10008 = PLACED
      if(retcode == 10009 || retcode == 10008) {
          return MakeSuccessResult(0, "Order executed");
      }

      string userMsg = "MT5 Error " + IntegerToString(retcode);
      ENUM_TRADE_ERROR_TYPE type = TRADE_ERR_BROKER;
      
      if(retcode == 10004) { userMsg = "Requote"; type = TRADE_ERR_BROKER; }
      else if(retcode == 10006) { userMsg = "Request Rejected"; type = TRADE_ERR_BROKER; }
      else if(retcode == 10011) { userMsg = "Request Failed"; type = TRADE_ERR_BROKER; }
      else if(retcode == 10013) { userMsg = "Invalid Request"; type = TRADE_ERR_VALIDATION; }
      else if(retcode == 10014) { userMsg = "Invalid Volume"; type = TRADE_ERR_VALIDATION; }
      else if(retcode == 10015) { userMsg = "Invalid Price"; type = TRADE_ERR_VALIDATION; }
      else if(retcode == 10016) { userMsg = "Invalid Stops"; type = TRADE_ERR_STOPLEVEL; }
      else if(retcode == 10017) { userMsg = "Trade Disabled"; type = TRADE_ERR_PERMISSION; }
      else if(retcode == 10018) { userMsg = "Market Closed"; type = TRADE_ERR_MARKET; }
      else if(retcode == 10019) { userMsg = "No Money"; type = TRADE_ERR_MARGIN; }
      else if(retcode == 10026) { userMsg = "Autotrading Disabled"; type = TRADE_ERR_PERMISSION; }
      else if(retcode == 10027) { userMsg = "EA Disabled by Server"; type = TRADE_ERR_PERMISSION; }
      
      string techDetail = "RetCode " + IntegerToString(retcode);
      if(context != "") techDetail += " (" + context + ")";
      
      return MakeErrorResult((int)retcode, type, userMsg, techDetail);
   }

   //+------------------------------------------------------------------+
   //| Affiche un Toast dans la GUI (SEUL point de contact avec la GUI) |
   //+------------------------------------------------------------------+
   static void ShowTradeToast(const TradeResult &result)
   {
      g_ToastMsg = result.Message;
      g_ToastStartTime = GetTickCount();
      
      if(result.Success) {
         g_ToastColor = g_ColorGreen; // defined in Defines.mqh
         // Clear last error on success
         g_LastTradeErrorMsg = "";
      } else {
         g_ToastColor = g_ColorRed;   // defined in Defines.mqh
         g_LastTradeErrorMsg = result.Message;
         
         // Optional: Print technical details to Expert Log
         if(result.TechnicalDetail != "")
            Print("FantomePad Error: ", result.TechnicalDetail);
      }
   }
};

#endif
