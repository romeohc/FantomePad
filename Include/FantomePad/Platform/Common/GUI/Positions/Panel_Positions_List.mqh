//+------------------------------------------------------------------+
//|                                        Panel_Positions_List.mqh  |
//|                                           FantomePad Project     |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| GESTION LISTE POSITIONS                                         |
//+------------------------------------------------------------------+
void ClosePositionList()
{
   for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, PREFIX + "PosListItem_") >= 0 || 
         name == PREFIX + "PosListContainer" ||
         name == PREFIX + "PosListScrollTrack" || 
         name == PREFIX + "PosListScrollThumb") 
      {
         ObjectDelete(0, name);
      }
   }
   
   IsPosListOpen = false;
   g_PosListOffset = 0; 
   ChartRedraw();
}

void DrawPositionList()
{
   int x = (int)ObjectGetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_XDISTANCE);
   int y = (int)ObjectGetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_YDISTANCE);
   int w = (int)ObjectGetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_XSIZE);
   int h = (int)ObjectGetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_YSIZE);
   
   long tickets[];
   int count = 0;
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
          int type = OrderType();
          if(type == OP_BUY || type == OP_SELL || type == OP_BUYLIMIT || type == OP_SELLLIMIT || type == OP_BUYSTOP || type == OP_SELLSTOP)
          {
             ArrayResize(tickets, count+1);
             tickets[count] = (long)OrderTicket();
             count++;
          }
      }
   }
   
   if(count == 0)
   {
      ClosePositionList();
      
      int itemHeight = 25;
      int startY = y + h + 2; 
      CreateRect("PosListContainer", x, startY - 2, w, itemHeight + 4, g_ColorBg, BORDER_FLAT);
      ObjectSetInteger(0, PREFIX + "PosListContainer", OBJPROP_ZORDER, 15);
      ObjectSetInteger(0, PREFIX + "PosListContainer", OBJPROP_BORDER_COLOR, g_ColorBg);
      
      CreateButton("PosListItem_None", "No Positions", x + 2, startY, w - 4, itemHeight, g_ColorInput, g_ColorText);
      ObjectSetInteger(0, PREFIX + "PosListItem_None", OBJPROP_ZORDER, 16);
      ObjectSetInteger(0, PREFIX + "PosListItem_None", OBJPROP_STATE, false);
      IsPosListOpen = true;
      return; 
   }
   
   int itemHeight = 25;
   int scrollBarWidth = 10;
   
   int maxVis = (int)g_PosListMaxVisible;
   int visibleCount = (count > maxVis) ? maxVis : count;
   
   if(g_PosListOffset > count - visibleCount) g_PosListOffset = count - visibleCount;
   if(g_PosListOffset < 0) g_PosListOffset = 0;
   
   bool showScroll = (count > maxVis);
   
   int startY = y + h + 2; 
   int contentHeight = visibleCount * itemHeight;
   int containerWidth = w;
   
   CreateRect("PosListContainer", x, startY - 2, containerWidth, contentHeight + 4, g_ColorBg, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "PosListContainer", OBJPROP_ZORDER, 15);
   ObjectSetInteger(0, PREFIX + "PosListContainer", OBJPROP_BORDER_COLOR, g_ColorBg);
   
   int itemWidth = showScroll ? containerWidth - scrollBarWidth - 2 : containerWidth - 4;
   int itemX = x + 2;
   int currentY = startY;
   for(int i = 0; i < visibleCount; i++)
   {
      int dataIdx = (int)g_PosListOffset + i;
      if(dataIdx >= count) break;
      
      long tck = tickets[dataIdx];
      if(OrderSelect(tck, SELECT_BY_TICKET))
      {
         string typeStr = "";
         int type = OrderType();
         if(type == OP_BUY) typeStr = "BUY";
         else if(type == OP_SELL) typeStr = "SELL";
         else if(type == OP_BUYLIMIT) typeStr = "BUY LIM";
         else if(type == OP_SELLLIMIT) typeStr = "SELL LIM";
         else if(type == OP_BUYSTOP) typeStr = "BUY STP";
         else if(type == OP_SELLSTOP) typeStr = "SELL STP";
 
         string txt = OrderSymbol() + "  ·  " + DoubleToString(OrderLots(), 2);
         string btnName = "PosListItem_" + IntegerToString(tck);
         
         CreateButton(btnName, txt, itemX, currentY, itemWidth, itemHeight, g_ColorInput, g_ColorText);
         ObjectSetInteger(0, PREFIX + btnName, OBJPROP_ZORDER, 16);
         ObjectSetInteger(0, PREFIX + btnName, OBJPROP_BORDER_COLOR, g_ColorInput);
         
         currentY += itemHeight;
      }
   }
   
   if(showScroll)
   {
       int trackX = x + containerWidth - scrollBarWidth - 2;
       int trackH = contentHeight;
       int trackY = startY;
       
       CreateRect("PosListScrollTrack", trackX, trackY, scrollBarWidth, trackH, g_ColorBg, BORDER_FLAT);
       ObjectSetInteger(0, PREFIX + "PosListScrollTrack", OBJPROP_ZORDER, 16);
       
       double ratio = (double)visibleCount / (double)count;
       int thumbH = (int)(trackH * ratio);
       if(thumbH < 20) thumbH = 20; 
       
       int maxOffset = count - visibleCount;
       double scrollPrc = (maxOffset > 0) ? (double)g_PosListOffset / (double)maxOffset : 0;
       int relativeY = (int)(scrollPrc * (trackH - thumbH));
       
       CreateRect("PosListScrollThumb", trackX + 1, trackY + relativeY, scrollBarWidth - 2, thumbH, g_ColorBtnValid, BORDER_FLAT);
       ObjectSetInteger(0, PREFIX + "PosListScrollThumb", OBJPROP_ZORDER, 17);
   }
   
   ChartRedraw();
}

void TogglePositionList()
{
   if(IsPosListOpen) ClosePositionList();
   else 
   {
      IsPosListOpen = true;
      DrawPositionList();
   }
}
