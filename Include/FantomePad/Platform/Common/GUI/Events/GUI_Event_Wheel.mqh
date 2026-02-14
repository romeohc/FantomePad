//+------------------------------------------------------------------+
//|                                              GUI_Event_Wheel.mqh |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| EVENT: MOUSE WHEEL                                               |
//+------------------------------------------------------------------+
void OnEvent_Wheel(int delta)
{
   if(IsListOpen)
   {
       // Check if mouse is over ListContainer
       long lx = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_XDISTANCE);
       long ly = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_YDISTANCE);
       long lw = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_XSIZE);
       long lh = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_YSIZE);
       
       if(LastMouseX >= lx && LastMouseX <= lx + lw && LastMouseY >= ly && LastMouseY <= ly + lh)
       {
           int total = SymbolsTotal(true);
           
           if(delta > 0) // SCROLL UP
           {
               if(g_SymbolListOffset > 0) g_SymbolListOffset--;
           }
           else // SCROLL DOWN
           {
               if(g_SymbolListOffset < total - VisibleListItems) g_SymbolListOffset++;
           }
           
           DrawSymbolList();
           // Prevent chart scrolling if possible, but MQL4 doesn't easily allow consuming this event.
           // However, since we handled it, the user sees the list scroll.
       }
   }
   
   // --- MOUSE WHEEL FOR ACCOUNT ORDERS ---
   if(g_PanelAccount.IsVisible && g_TotalAccountOrderCount > g_AccountOrdersMaxVisible)
   {
       // Check if mouse is over the orders list area in Account Panel
       // We check if there's a scrollbar visible (meaning > 3 orders)
       if(ObjectFind(0, PREFIX + "Account_Ord_ScrollTrack") >= 0)
       {
           long trackX = ObjectGetInteger(0, PREFIX + "Account_Ord_ScrollTrack", OBJPROP_XDISTANCE);
           long trackY = ObjectGetInteger(0, PREFIX + "Account_Ord_ScrollTrack", OBJPROP_YDISTANCE);
           long trackH = ObjectGetInteger(0, PREFIX + "Account_Ord_ScrollTrack", OBJPROP_YSIZE);
           
           // Use the first order card to determine the list area
           if(ObjectFind(0, PREFIX + "Account_Ord_Bg_0") >= 0)
           {
               long ordX = ObjectGetInteger(0, PREFIX + "Account_Ord_Bg_0", OBJPROP_XDISTANCE);
               long ordY = ObjectGetInteger(0, PREFIX + "Account_Ord_Bg_0", OBJPROP_YDISTANCE);
               long ordW = ObjectGetInteger(0, PREFIX + "Account_Ord_Bg_0", OBJPROP_XSIZE);
               
               // Check if mouse is over the orders list area (including scrollbar)
               int scrollAreaWidth = 260 - 40; // panel width - padding*2
               if(LastMouseX >= ordX && LastMouseX <= ordX + scrollAreaWidth && 
                  LastMouseY >= ordY && LastMouseY <= ordY + trackH + 10)
               {
                   int maxOffset = g_TotalAccountOrderCount - g_AccountOrdersMaxVisible;
                   
                   if(delta > 0) // SCROLL UP
                   {
                       if(g_AccountOrdersScrollOffset > 0) g_AccountOrdersScrollOffset--;
                   }
                   else // SCROLL DOWN
                   {
                       if(g_AccountOrdersScrollOffset < maxOffset) g_AccountOrdersScrollOffset++;
                   }
                   
                   UpdateAccountLayout();
                   UpdateAccountPanel();
               }
           }
       }
   }
}
