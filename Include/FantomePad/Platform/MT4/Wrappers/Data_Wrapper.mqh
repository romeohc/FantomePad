//+------------------------------------------------------------------+
//|                                              Data_Wrapper.mqh    |
//|                                              FantomePad Project  |
//|                                                  (MT4 Specific)  |
//+------------------------------------------------------------------+
#property strict
#include "../../Common/Core/DataTypes.mqh"

//+------------------------------------------------------------------+
//| Remplir la structure FantomeTrade depuis l'ordre sélectionné     |
//+------------------------------------------------------------------+
void FP_GetTrade(FantomeTrade &trade)
{
   trade.Ticket      = OrderTicket();
   trade.Symbol      = OrderSymbol();
   trade.Type        = OrderType();
   trade.Lots        = OrderLots();
   trade.OpenPrice   = OrderOpenPrice();
   trade.StopLoss    = OrderStopLoss();
   trade.TakeProfit  = OrderTakeProfit();
   trade.OpenTime    = OrderOpenTime();
   trade.CloseTime   = OrderCloseTime();
   trade.ClosePrice  = OrderClosePrice();
   trade.Commission  = OrderCommission();
   trade.Swap        = OrderSwap();
   trade.Profit      = OrderProfit();
   trade.Comment     = OrderComment();
   trade.Magic       = OrderMagicNumber();
   
   trade.Digits      = (int)MarketInfo(trade.Symbol, MODE_DIGITS);
   trade.Point       = MarketInfo(trade.Symbol, MODE_POINT);
}

//+------------------------------------------------------------------+
//| Remplir la structure FantomeAccount                              |
//+------------------------------------------------------------------+
void FP_GetAccount(FantomeAccount &account)
{
   account.Login     = AccountNumber();
   account.Name      = AccountName();
   account.Server    = AccountServer();
   account.Currency  = AccountCurrency();
   account.Leverage  = AccountLeverage();
   account.Balance   = AccountBalance();
   account.Equity    = AccountEquity();
   account.Margin    = AccountMargin();
   account.FreeMargin= AccountFreeMargin();
   
   if(AccountMargin() > 0)
      account.MarginLevel = AccountEquity() / AccountMargin() * 100.0;
   else
      account.MarginLevel = 0.0; // Or standard MAX_DOUBLE
      
   account.Credit    = AccountCredit();
   account.IsTradeAllowed = IsTradeAllowed();
   account.IsExpertAllowed = IsExpertEnabled();
   account.LimitOrders = 10000; // Virtually unlimited
}
