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
   int      TradeDigits; 
   double   TradePoint;
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

// --- Enum pour les types de résultat (Phase 1: Step 1) ---
enum ENUM_TRADE_ERROR_TYPE {
   TRADE_ERR_NONE = 0,
   TRADE_ERR_VALIDATION,     // Pre-flight check failed
   TRADE_ERR_BROKER,         // Broker rejected
   TRADE_ERR_MARKET,         // Market conditions (spread, closed)
   TRADE_ERR_MARGIN,         // Insufficient margin
   TRADE_ERR_STOPLEVEL,      // SL/TP/Entry too close
   TRADE_ERR_PERMISSION,     // Trading disabled
   TRADE_ERR_RETRY_EXHAUSTED,// All retries failed
   TRADE_ERR_BUSY,           // Trade context busy (MT4 only)
   TRADE_ERR_UNKNOWN
};

// DTO pour une demande d'exécution
struct TradeRequest {
   string   Symbol;
   int      Type;         // OP_BUY, OP_SELL, OP_BUYLIMIT, etc.
   double   Lots;
   double   Price;
   double   SL;
   double   TP;
   string   Comment;
   int      Magic;
   datetime Expiration;
   double   RiskPercent;  // Pour validation interne (optionnel)
};

// DTO pour le résultat
struct TradeResult {
   bool     Success;
   long     Ticket;
   int      ErrorCode;       // Code d'erreur natif broker
   ENUM_TRADE_ERROR_TYPE ErrorType;
   string   Message;         // Message user-friendly
   string   TechnicalDetail; // Détail technique (pour Print/Log)
};

// Helper constructors (fonctions statiques car MQL ne supporte pas les constructeurs complexes)
TradeResult MakeSuccessResult(long ticket, string msg = "")
{
   TradeResult r;
   r.Success = true;
   r.Ticket = ticket;
   r.ErrorCode = 0;
   r.ErrorType = TRADE_ERR_NONE;
   r.Message = (msg != "") ? msg : "Order executed successfully.";
   r.TechnicalDetail = "";
   return r;
}

TradeResult MakeErrorResult(int errCode, ENUM_TRADE_ERROR_TYPE errType, string userMsg, string techDetail = "")
{
   TradeResult r;
   r.Success = false;
   r.Ticket = -1;
   r.ErrorCode = errCode;
   r.ErrorType = errType;
   r.Message = userMsg;
   r.TechnicalDetail = techDetail;
   return r;
}

#endif
