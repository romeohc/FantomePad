//+------------------------------------------------------------------+
//|                                              Panel_History.mqh   |
//|                                                MagicKey Project  |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| CREATION DU PANEL HISTORIQUE                                     |
//+------------------------------------------------------------------+
void CreateHistoryPanel()
{
   if(!IsHistoryPanelVisible) return;
   
   int width = 800; // Largeur
   int rowHeight = 30; 
   int headerHeight = 40;
   
   // Initial Init (Center if -1) -> Logic handled in GUI_Master dragging or fixed default
   // Here we use Globals: HistoryPanelX, HistoryPanelY
   
   int startX = HistoryPanelX;
   int startY = HistoryPanelY;
   
   // 1. Fond & Header
   CreateRect("Hist_Bg", startX, startY, width, headerHeight + HistoryViewportHeight + 10, g_ColorBg, BORDER_FLAT);
   CreateRect("Hist_Header", startX, startY, width, headerHeight, g_ColorHeader, BORDER_FLAT);
   CreateLabel("Hist_Title", "Transaction History", startX + 15, startY + 10, 10, clrWhite, "Trebuchet MS Bold");
   
   // 2. Headings
   int colY = startY + headerHeight + 10;
   int colX = startX + 20;
   
   // New Layout
   int wTime  = 160;
   int wType  = 100;
   int wSym   = 120; // Increased width
   int wFees  = 120; // New column
   // Profit gets the rest
   
   // Remove old headers if any (part of full redraw)
   CreateLabel("Hist_H_Time", "TIME", colX, colY, 8, g_ColorLabel, "Trebuchet MS Bold");
   CreateLabel("Hist_H_Type", "TYPE", colX + wTime, colY, 8, g_ColorLabel, "Trebuchet MS Bold");
   // Removed Size
   CreateLabel("Hist_H_Sym",  "SYMBOL", colX + wTime + wType, colY, 8, g_ColorLabel, "Trebuchet MS Bold");
   // Removed Price
   CreateLabel("Hist_H_Fees", "FEES", colX + wTime + wType + wSym, colY, 8, g_ColorLabel, "Trebuchet MS Bold"); // New!
   CreateLabel("Hist_H_Prof", "PROFIT", colX + wTime + wType + wSym + wFees, colY, 8, g_ColorLabel, "Trebuchet MS Bold");
   
   // Cleanup Old Labels (important if we switch panel content dynamically)
   if(ObjectFind(0, PREFIX + "Hist_H_Size") >= 0) ObjectDelete(0, PREFIX + "Hist_H_Size");
   if(ObjectFind(0, PREFIX + "Hist_H_Price") >= 0) ObjectDelete(0, PREFIX + "Hist_H_Price");
   
   // 3. Content
   int contentY = colY + 25;
   DrawHistoryContent(startX, contentY, width, rowHeight);
   
   // 4. Scrollbar
   DrawHistoryScrollbar(startX, contentY, width);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| DESSIN DU CONTENU (VIRTUAL SCROLL)                               |
//+------------------------------------------------------------------+
void DrawHistoryContent(int x, int y, int w, int rowH)
{
   // Cleanup old items
   for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
   {
       string name = ObjectName(0, i);
       if(StringFind(name, PREFIX + "Hist_Item_") >= 0) ObjectDelete(0, name);
   }

   int total = OrdersHistoryTotal();
   HistoryContentHeight = total * rowH;
   
   int maxVisibleRows = HistoryViewportHeight / rowH;
   
   // Calculate start index based on scroll pixel offset
   int startIdx = 0;
   if(HistoryContentHeight > HistoryViewportHeight)
   {
      // Proportional scroll
      // offset / (realHeight - viewHeight) * (total - visible) ? NO.
      // Simpler: offset represents pixels.
      // Index = offset / rowHeight
      startIdx = g_HistoryScrollY / rowH;
   }
   
   // Clamp
   if(startIdx > total - maxVisibleRows) startIdx = total - maxVisibleRows;
   if(startIdx < 0) startIdx = 0;
   
   int currentY = y;
   int paddingX = 20; // Matches Header
   
   int wTime  = 160;
   int wType  = 100;
   int wSym   = 120;
   int wFees  = 120;
   // wProfit = Rest

   // Loop maxVisibleRows
   for(int i = 0; i < maxVisibleRows; i++)
   {
       int logicalIndex = startIdx + i;
       // We want Newest First (Total-1 down to 0)
       int orderIndex = total - 1 - logicalIndex;
       
       if(orderIndex < 0) break;
       
       if(OrderSelect(orderIndex, SELECT_BY_POS, MODE_HISTORY))
       {
           string sfx = "_" + IntegerToString(logicalIndex);
           int itemY = currentY + (i * rowH);
           
           // Background
           string bgName = "Hist_Item_Bg" + sfx;
           CreateButton(bgName, "", x + 5, itemY, w - 25, rowH - 2, g_ColorInput, clrNONE);
           ObjectSetInteger(0, PREFIX + bgName, OBJPROP_BORDER_COLOR, g_ColorBg);
           ObjectSetInteger(0, PREFIX + bgName, OBJPROP_ZORDER, 10);
           
           // Data
           string timeStr = TimeToString(OrderCloseTime(), TIME_DATE|TIME_MINUTES);
           int type = OrderType();
           string typeStr = (type == OP_BUY) ? "BUY" : (type == OP_SELL) ? "SELL" : (type == OP_BUYLIMIT) ? "BUY LIM" : (type == OP_SELLLIMIT) ? "SELL LIM" : "PENDING";
           string symStr  = OrderSymbol();
           
           // Fees Calculation (Commission + Swap)
           double fees = OrderCommission() + OrderSwap();
           string feesStr = DoubleToString(fees, 2) + " " + AccountCurrency();
           
           // Profit (Includes fees in original requirement? Or Net? Usually separate means Breakdown)
           // But code was: OrderProfit() + OrderCommission() + OrderSwap(). This is Total Net Profit.
           // If we separate Fees, we should probably keep showing Total Net Profit so the user knows what they made.
           // Or should we show Gross Profit? 
           // User request: "colonne fees... qui affichera tous les frais compris de la position"
           // Usually users want to see Fees separate, and the Result separate. 
           // I will keep Profit as Net Profit (End result).
           double prof    = OrderProfit() + OrderCommission() + OrderSwap();
           string profStr = DoubleToString(prof, 2) + " " + AccountCurrency();
           
           color profCol = (prof >= 0) ? g_ColorGreen : g_ColorRed;
           color typeCol = (type==OP_BUY || type==OP_BUYLIMIT || type==OP_BUYSTOP) ? g_ColorGreen : g_ColorRed;
           
           int txtY = itemY + 6;
           int colX = x + paddingX;
           
           CreateLabel("Hist_Item_Time"+sfx, timeStr, colX, txtY, 8, g_ColorText, "Trebuchet MS");
           CreateLabel("Hist_Item_Type"+sfx, typeStr, colX + wTime, txtY, 8, typeCol, "Trebuchet MS");
           CreateLabel("Hist_Item_Sym"+sfx, symStr, colX + wTime + wType, txtY, 8, g_ColorText, "Trebuchet MS");
           CreateLabel("Hist_Item_Fees"+sfx, feesStr, colX + wTime + wType + wSym, txtY, 8, g_ColorLabel, "Trebuchet MS"); // Fees darker color
           CreateLabel("Hist_Item_Prof"+sfx, profStr, colX + wTime + wType + wSym + wFees, txtY, 8, profCol, "Trebuchet MS Bold");
           
           // ZOrder 12 for text
           ObjectSetInteger(0, PREFIX + "Hist_Item_Time"+sfx, OBJPROP_ZORDER, 12);
           ObjectSetInteger(0, PREFIX + "Hist_Item_Type"+sfx, OBJPROP_ZORDER, 12);
           ObjectSetInteger(0, PREFIX + "Hist_Item_Sym"+sfx, OBJPROP_ZORDER, 12);
           ObjectSetInteger(0, PREFIX + "Hist_Item_Fees"+sfx, OBJPROP_ZORDER, 12);
           ObjectSetInteger(0, PREFIX + "Hist_Item_Prof"+sfx, OBJPROP_ZORDER, 12);
       }
   }
}

//+------------------------------------------------------------------+
//| SCROLLBAR                                                        |
//+------------------------------------------------------------------+
void DrawHistoryScrollbar(int x, int y, int w)
{
   int trackW = 12;
   int trackH = HistoryViewportHeight;
   int trackX = x + w - trackW - 5;
   int trackY = y;
   
   CreateRect("Hist_ScrollTrack", trackX, trackY, trackW, trackH, g_ColorInput, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "Hist_ScrollTrack", OBJPROP_ZORDER, 15);
   
   int contentH = HistoryContentHeight;
   if(contentH <= HistoryViewportHeight) contentH = HistoryViewportHeight + 1; // Prevent div 0 or full
   
   double ratio = (double)HistoryViewportHeight / (double)contentH;
   if(ratio > 1.0) ratio = 1.0;
   
   int thumbH = (int)(trackH * ratio);
   if(thumbH < 20) thumbH = 20;
   
   int maxScroll = contentH - HistoryViewportHeight;
   if(maxScroll < 0) maxScroll = 0;
   
   int thumbY = trackY;
   if(maxScroll > 0)
   {
       double scrollPrc = (double)g_HistoryScrollY / (double)maxScroll;
       int availableTrack = trackH - thumbH;
       thumbY = trackY + (int)(scrollPrc * availableTrack);
   }
   
   CreateRect("Hist_ScrollThumb", trackX + 1, thumbY, trackW - 2, thumbH, g_ColorBtnValid, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "Hist_ScrollThumb", OBJPROP_ZORDER, 16);
   ObjectSetInteger(0, PREFIX + "Hist_ScrollThumb", OBJPROP_BGCOLOR, g_ColorLabel);
}

//+------------------------------------------------------------------+
//| TOGGLE                                                           |
//+------------------------------------------------------------------+
void ToggleHistoryPanel(bool visible)
{
   SetObjVisible("Hist_Bg", visible);
   SetObjVisible("Hist_Header", visible);
   SetObjVisible("Hist_Title", visible);
   
   SetObjVisible("Hist_H_Time", visible);
   SetObjVisible("Hist_H_Type", visible);
   SetObjVisible("Hist_H_Sym", visible);
   SetObjVisible("Hist_H_Fees", visible);
   SetObjVisible("Hist_H_Prof", visible);
   
   SetObjVisible("Hist_ScrollTrack", visible);
   SetObjVisible("Hist_ScrollThumb", visible);
   
   // Items
   // We might just delete them if hidden to save resources, or hide
   // Deleting is safer for dynamic lists
   if(!visible)
   {
       for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
       {
           string name = ObjectName(0, i);
           if(StringFind(name, PREFIX + "Hist_Item_") >= 0) ObjectDelete(0, name);
       }
   }
   else
   {
      CreateHistoryPanel(); // Will redraw items
   }
}
