//+------------------------------------------------------------------+
//|                                         Handler_PositionList.mqh |
//+------------------------------------------------------------------+
#property strict

bool Handle_PositionList_Events(string sparam)
{
   // --- POSITION SELECTOR EVENTS ---
   
   // 1. Clic sur le bouton de selection de position
   if(sparam == PREFIX + "Pos_Btn_Select")
   {
      FP_ObjectSetInteger(0, sparam, OBJPROP_STATE, false); 
      TogglePositionList();
      ChartRedraw();
      return true; 
   }
   
   // 2. Clic sur un item de la liste des positions
   if(StringFind(sparam, PREFIX + "PosListItem_") >= 0 && sparam != PREFIX + "PosListItem_None")
   {
      string prefix = PREFIX + "PosListItem_";
      string sTicket = StringSubstr(sparam, StringLen(prefix));
      SelectedPositionTicket = (int)StringToInteger(sTicket);
      
      // Auto Switch Chart Symbol
      if(OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
      {
         if(OrderSymbol() != Symbol())
         {
            GlobalVariableSet("FantomePad_LastSelectedTicket", (double)SelectedPositionTicket);
            ChartSetSymbolPeriod(0, OrderSymbol(), Period());
         }
          else
          {
             // Same symbol: Update lines immediately (INSTANT UX)
             UpdateOpenOrderLines();
          }
      }
      
      ClosePositionList();
      UpdatePositionsValues(); 
      ChartRedraw();
      return true;
   }
   
   // Close List if clicked outside
   if(IsPosListOpen && 
      StringFind(sparam, PREFIX + "PosListItem_") < 0 && 
      sparam != PREFIX + "Pos_Btn_Select" &&
      sparam != PREFIX + "PosListScrollTrack" &&
      sparam != PREFIX + "PosListScrollThumb")
   {
      ClosePositionList();
      return false; // Continue processing
   }
   
   return false;
}
