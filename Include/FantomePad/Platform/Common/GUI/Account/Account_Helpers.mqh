#ifndef ACCOUNT_HELPERS_MQH
#define ACCOUNT_HELPERS_MQH

#property strict

//+------------------------------------------------------------------+
//| GET ORDER TYPE STRING SHORT                                      |
//+------------------------------------------------------------------+
string GetOrderTypeStrShort(int type)
{
   switch(type)
   {
      case OP_BUY:      return "BUY";
      case OP_SELL:     return "SELL";
      case OP_BUYLIMIT: return "BUY LIMIT";
      case OP_SELLLIMIT: return "SELL LIMIT";
      case OP_BUYSTOP:  return "BUY STOP";
      case OP_SELLSTOP: return "SELL STOP";
      default:          return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| HELPER: CALCUL DEPOSIT / WITHDRAW                                |
//+------------------------------------------------------------------+
void GetAccountHistoryStats(double &outDeposit, double &outWithdraw, double &outNetProfit)
{
   static double cached_deposit = 0;
   static double cached_withdraw = 0;
   static double cached_netprofit = 0;
   static int    cached_total = -1;
   
   int total = OrdersHistoryTotal();
   
   // MT5 Cache Flush Protection: if history temporarily disappears, use cached data
   if(total == 0 && cached_total > 0)
   {
      outDeposit = cached_deposit;
      outWithdraw = cached_withdraw;
      outNetProfit = cached_netprofit;
      return;
   }
   
   outDeposit = 0;
   outWithdraw = 0;
   outNetProfit = 0;
   
   for(int i=0; i<total; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         int type = OrderType();
         if(type == OP_BALANCE) // Cross-platform: 6 on MT4, -2 on MT5
         {
            double amt = OrderProfit();
            if(amt > 0) outDeposit += amt;
            else        outWithdraw += MathAbs(amt);
         }
         else if(type >= 0 && type <= 1 && OrderCloseTime() > 0) // OP_BUY/OP_SELL, only exit deals
         {
            // CloseTime > 0 ensures we skip MT5 DEAL_ENTRY_IN (opening deals)
            // which have CloseTime = 0 and should not be counted in net profit.
            outNetProfit += (OrderProfit() + OrderCommission() + OrderSwap());
         }
      }
   }
   
   // Update Cache
   if(total > 0 || cached_total == -1)
   {
      cached_deposit = outDeposit;
      cached_withdraw = outWithdraw;
      cached_netprofit = outNetProfit;
      cached_total = total;
   }
}

#endif
