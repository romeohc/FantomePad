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
   outDeposit = 0;
   outWithdraw = 0;
   outNetProfit = 0;
   
   int total = OrdersHistoryTotal();
   for(int i=0; i<total; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         int type = OrderType();
         if(type == 6) // OP_BALANCE = 6 (Deposit/Withdraw)
         {
            double amt = OrderProfit();
            if(amt > 0) outDeposit += amt;
            else        outWithdraw += MathAbs(amt);
         }
         else if(type <= 1) // OP_BUY=0, OP_SELL=1
         {
            // Sum net profit (profit + commission + swap)
            outNetProfit += (OrderProfit() + OrderCommission() + OrderSwap());
         }
      }
   }
}

#endif
