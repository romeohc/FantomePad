//+------------------------------------------------------------------+
//|                                               History_Filter.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

// Forward Declaration
void CreateHistoryPanel();

//+------------------------------------------------------------------+
//| HELPER: APPLY FILTER LOGIC                                       |
//+------------------------------------------------------------------+
void UpdateHistoryFilter()
{
   int total = OrdersHistoryTotal();
   ArrayResize(g_HistoryFilteredIndices, 0); // Start empty
   
   datetime startLimit = 0;
   datetime endLimit = 0; // 0 means no limit (or far future)
   
   if(g_HistoryFilterMode == H_FILTER_DAILY)
   {
      // Start of Today
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      dt.hour = 0; dt.min = 0; dt.sec = 0;
      startLimit = StructToTime(dt);
   }
   else if(g_HistoryFilterMode == H_FILTER_WEEKLY)
   {
      // Start of Week
      startLimit = iTime(NULL, PERIOD_W1, 0);
   }
   else if(g_HistoryFilterMode == H_FILTER_MONTHLY)
   {
      startLimit = iTime(NULL, PERIOD_MN1, 0);
   }
   else if(g_HistoryFilterMode == H_FILTER_CUSTOM)
   {
      startLimit = g_HistoryCustomStart;
      endLimit   = g_HistoryCustomEnd;
   }
   
   // Loop and Filter
   int count = 0;
   for(int i=0; i<total; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         datetime ct = OrderCloseTime();
         bool match = false;
         
         if(g_HistoryFilterMode == H_FILTER_CUSTOM)
         {
             if(ct >= startLimit && ct <= endLimit) match = true;
         }
         else
         {
             if(ct >= startLimit) match = true;
         }
         
         // Fix: Exclude Balance/Credit operations (Type > 1)
         if(OrderType() > 1) match = false;
         
         // Symbol Filter
         if(match && g_HistoryFilterSymbol != "")
         {
             if(StringFind(OrderSymbol(), g_HistoryFilterSymbol) == -1) match = false;
         }
         
         if(match)
         {
            ArrayResize(g_HistoryFilteredIndices, count+1);
            g_HistoryFilteredIndices[count] = i; // Save POSITION index
            count++;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| HELPER: SET FILTER MODE                                          |
//+------------------------------------------------------------------+
void SetHistoryFilter(ENUM_HISTORY_FILTER mode)
{
    g_HistoryFilterMode = mode;
    g_ScrollHistory.ScrollY = 0; // Reset scroll on view change
    UpdateHistoryFilter();
    CreateHistoryPanel(); // Redraw
}
