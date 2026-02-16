//+------------------------------------------------------------------+
//|                                              Data_Wrapper.mqh    |
//|                                              FantomePad Project  |
//|                                                  (MT5 Specific)  |
//+------------------------------------------------------------------+
#property strict
#include "../../Common/Core/DataTypes.mqh"

//+------------------------------------------------------------------+
//| Remplir la structure FantomeTrade                                |
//| Pre-condition: Position ou Ordre déjà sélectionné par le caller  |
//+------------------------------------------------------------------+
void FP_GetTrade(FantomeTrade &trade)
{
   trade.Ticket    = OrderTicket(); 
   trade.Symbol    = OrderSymbol();
   trade.Type      = OrderType();
   trade.Lots      = OrderLots();
   trade.OpenPrice = OrderOpenPrice();
   trade.StopLoss  = OrderStopLoss();
   trade.TakeProfit= OrderTakeProfit();
   trade.OpenTime  = OrderOpenTime();
   trade.CloseTime = OrderCloseTime();
   trade.Profit    = OrderProfit();
   trade.Swap      = OrderSwap();
   trade.Commission= OrderCommission();
   trade.Comment   = OrderComment();
   trade.Magic     = OrderMagic();

   if(trade.Symbol == "") trade.Symbol = _Symbol;
   
   // Direct access to SymbolInfo to avoid macro collision on struct members
   trade.TradeDigits = (int)SymbolInfoInteger(trade.Symbol, SYMBOL_DIGITS);
   trade.TradePoint  = SymbolInfoDouble(trade.Symbol, SYMBOL_POINT);
}

//+------------------------------------------------------------------+
//| Remplir la structure FantomeAccount                              |
//+------------------------------------------------------------------+
void FP_GetAccount(FantomeAccount &account)
{
   account.Login      = AccountInfoInteger(ACCOUNT_LOGIN);
   account.Name       = AccountInfoString(ACCOUNT_NAME);
   account.Server     = AccountInfoString(ACCOUNT_SERVER);
   account.Currency   = AccountInfoString(ACCOUNT_CURRENCY);
   account.Leverage   = (int)AccountInfoInteger(ACCOUNT_LEVERAGE);
   account.Balance    = AccountInfoDouble(ACCOUNT_BALANCE);
   account.Equity     = AccountInfoDouble(ACCOUNT_EQUITY);
   account.Margin     = AccountInfoDouble(ACCOUNT_MARGIN);
   account.FreeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   account.MarginLevel= AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   account.Credit     = AccountInfoDouble(ACCOUNT_CREDIT);
   account.IsTradeAllowed = (bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
   account.IsExpertAllowed = (bool)AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
   account.LimitOrders = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
}
