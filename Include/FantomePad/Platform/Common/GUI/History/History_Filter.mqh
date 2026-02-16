//+------------------------------------------------------------------+
//|                                               History_Filter.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict


//+------------------------------------------------------------------+
//| HELPER: APPLY FILTER LOGIC                                       |
//+------------------------------------------------------------------+
void UpdateHistoryFilter()
{
   int total = OrdersHistoryTotal();
   
   // Pre-allocate to max possible size to avoid resize in loop
   ArrayResize(g_HistoryFilteredIndices, total);
   
   datetime startLimit = 0;
   datetime endLimit = 0; // 0 means no limit
   
   // Robust Time Calculation (No iTime dependency)
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   // Normalize to Start of Day (00:00:00)
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   datetime startOfDay = StructToTime(dt);
   
   if(g_HistoryFilterMode == H_FILTER_DAILY)
   {
      startLimit = startOfDay;
   }
   else if(g_HistoryFilterMode == H_FILTER_WEEKLY)
   {
      // Start of Week (Sunday 00:00)
      // day_of_week: 0=Sun, 6=Sat
      startLimit = startOfDay - (dt.day_of_week * 86400); 
   }
   else if(g_HistoryFilterMode == H_FILTER_MONTHLY)
   {
      // Start of Month (Day 1)
      dt.day = 1;
      startLimit = StructToTime(dt);
   }
   else if(g_HistoryFilterMode == H_FILTER_ALL)
   {
      startLimit = 0; 
   }
   else if(g_HistoryFilterMode == H_FILTER_CUSTOM)
   {
      startLimit = g_HistoryCustomStart;
      endLimit   = g_HistoryCustomEnd;
   }
   
   int count = 0;
   for(int i=0; i<total; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         bool match = false;
         datetime ct = OrderCloseTime();
         int type = OrderType();
         
         // 1. Basic Filters (Order Type)
         // Exclude Balance/Credit/Non-trade (type < 0 on MT5, type > 5 on MT4)
         if(type >= 0 && type <= 5) // OP_BUY..OP_SELLSTOP only
         {
              // CloseTime > 0 excludes MT5 DEAL_ENTRY_IN deals which shouldn't appear in history
              if(ct > 0)
              {
                  if(g_HistoryFilterMode == H_FILTER_CUSTOM)
                  {
                      if(ct >= startLimit && ct <= endLimit) match = true;
                  }
                  else
                  {
                      if(ct >= startLimit) match = true;
                  }
              }
         }
         
         // 2. Symbol Filter
         if(match && g_HistoryFilterSymbol != "")
         {
             if(StringFind(OrderSymbol(), g_HistoryFilterSymbol) == -1) match = false;
         }
         
         if(match)
         {
            g_HistoryFilteredIndices[count] = i;
            count++;
         }
      }
   }
   
   // Trim array to actual size
   ArrayResize(g_HistoryFilteredIndices, count);
}

//+------------------------------------------------------------------+
//| HELPER: SET FILTER MODE                                          |
//+------------------------------------------------------------------+
void SetHistoryFilter(ENUM_HISTORY_FILTER mode)
{
    g_HistoryFilterMode = mode;
    g_ScrollHistory.ScrollY = 0; // Reset scroll on view change
    UpdateHistoryFilter();
}
