//+------------------------------------------------------------------+
//|                                              Handler_History.mqh |
//+------------------------------------------------------------------+
#property strict

bool Handle_History_Events(string sparam)
{
   // --- HISTORY FILTER EVENTS --- 
   if(sparam == PREFIX + "Hist_Btn_Daily")
   {
      SetHistoryFilter(H_FILTER_DAILY);
      CreateHistoryPanel();
      EffectButton(sparam);
      return true;
   }
   if(sparam == PREFIX + "Hist_Btn_Weekly")
   {
      SetHistoryFilter(H_FILTER_WEEKLY);
      CreateHistoryPanel();
      EffectButton(sparam);
      return true;
   }
   if(sparam == PREFIX + "Hist_Btn_Monthly")
   {
      SetHistoryFilter(H_FILTER_MONTHLY);
      CreateHistoryPanel();
      EffectButton(sparam);
      return true;
   }
   if(sparam == PREFIX + "Hist_Btn_All")
   {
      SetHistoryFilter(H_FILTER_ALL);
      CreateHistoryPanel();
      EffectButton(sparam);
      return true;
   }
   if(sparam == PREFIX + "Hist_Btn_Custom")
   {
      SetHistoryFilter(H_FILTER_CUSTOM);
      CreateHistoryPanel();
      EffectButton(sparam);
      return true;
   }
   if(sparam == PREFIX + "Hist_Btn_Apply")
   {
       // Deprecated - Auto Update logic moved to ENDEDIT
       return true;
   }
   
   return false;
}
