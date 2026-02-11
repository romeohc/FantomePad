//+------------------------------------------------------------------+
//|                                                   History_UI.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| DRAW TOOLBAR (FILTERS & SYMBOL)                                  |
//+------------------------------------------------------------------+
void DrawHistoryToolbar(int startX, int startY, int headerHeight)
{
   int btnY = startY + headerHeight + 5;
   int btnW = 80;
   int btnH = 25;
   int gap = 10;
   int curBtnX = startX + 15;
   
   color bgDaily   = (g_HistoryFilterMode == H_FILTER_DAILY) ? g_ColorBtnActive : g_ColorInput;
   color bgWeekly  = (g_HistoryFilterMode == H_FILTER_WEEKLY) ? g_ColorBtnActive : g_ColorInput;
   color bgMonthly = (g_HistoryFilterMode == H_FILTER_MONTHLY) ? g_ColorBtnActive : g_ColorInput;
   color bgCustom  = (g_HistoryFilterMode == H_FILTER_CUSTOM) ? g_ColorBtnActive : g_ColorInput;
   
   CreateButton("Hist_Btn_Daily", "Daily", curBtnX, btnY, btnW, btnH, bgDaily, g_ColorText);
   curBtnX += btnW + gap;
   CreateButton("Hist_Btn_Weekly", "Weekly", curBtnX, btnY, btnW, btnH, bgWeekly, g_ColorText);
   curBtnX += btnW + gap;
   CreateButton("Hist_Btn_Monthly", "Monthly", curBtnX, btnY, btnW, btnH, bgMonthly, g_ColorText);
   curBtnX += btnW + gap;
   CreateButton("Hist_Btn_Custom", "Custom", curBtnX, btnY, btnW, btnH, bgCustom, g_ColorText);
   
   // Symbol Filter UI (Right of buttons)
   int symX = curBtnX + btnW + 30;
   CreateLabel("Hist_Lbl_SymFilter", "Symbol:", symX, btnY+3, 8, g_ColorText);
   CreateEdit("Hist_Input_Symbol", g_HistoryFilterSymbol, symX + 40, btnY, 80, btnH);
   
   // Custom Inputs (If Active)
   if(g_HistoryFilterMode == H_FILTER_CUSTOM)
   {
       int inpY = btnY + btnH + 5;
       int cursorX = startX + 50;
       int inpW = 100;
       
       CreateLabel("Hist_Lbl_From", "From:", cursorX, inpY+3, 8, g_ColorText);
       CreateEdit("Hist_Input_Start", TimeToString(g_HistoryCustomStart, TIME_DATE), cursorX + 35, inpY, inpW, 25);
       
       cursorX = cursorX + 35 + inpW + 20;
       
       CreateLabel("Hist_Lbl_To", "To:", cursorX, inpY+3, 8, g_ColorText);
       CreateEdit("Hist_Input_End", TimeToString(g_HistoryCustomEnd, TIME_DATE), cursorX + 25, inpY, inpW, 25);
   }
   else
   {
       if(ObjectFind(0, PREFIX+"Hist_Input_Start") >= 0) ObjectDelete(0, PREFIX+"Hist_Input_Start");
       if(ObjectFind(0, PREFIX+"Hist_Input_End") >= 0) ObjectDelete(0, PREFIX+"Hist_Input_End");
       if(ObjectFind(0, PREFIX+"Hist_Lbl_From") >= 0) ObjectDelete(0, PREFIX+"Hist_Lbl_From");
       if(ObjectFind(0, PREFIX+"Hist_Lbl_To") >= 0) ObjectDelete(0, PREFIX+"Hist_Lbl_To");
   }
}

//+------------------------------------------------------------------+
//| DRAW CONTENT (VIRTUAL SCROLL)                                    |
//+------------------------------------------------------------------+
void DrawHistoryContent(int x, int y, int w, int rowH)
{
   // Cleanup old items
   for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
   {
       string name = ObjectName(0, i);
       if(StringFind(name, PREFIX + "Hist_Item_") >= 0) ObjectDelete(0, name);
   }

   int total = ArraySize(g_HistoryFilteredIndices);
   g_ScrollHistory.ContentHeight = total * rowH;
   
   int maxVisibleRows = g_ScrollHistory.ViewportHeight / rowH;
   
   int startIdx = 0;
   if(g_ScrollHistory.ContentHeight > g_ScrollHistory.ViewportHeight)
   {
      startIdx = g_ScrollHistory.ScrollY / rowH;
   }
   
   if(startIdx > total - maxVisibleRows) startIdx = total - maxVisibleRows;
   if(startIdx < 0) startIdx = 0;
   
   int currentY = y;
   int paddingX = 20; 
   
   int wTime  = 150;
   int wType  = 100;
   int wSym   = 100;
   int wFees  = 100;
   int wProf  = 120;
   int wRetP  = 90;

   for(int i = 0; i < maxVisibleRows; i++)
   {
       int logicalIndex = startIdx + i;
       int arrayIndex = total - 1 - logicalIndex;
       
       if(arrayIndex < 0) break;
       
       int orderIndex = g_HistoryFilteredIndices[arrayIndex];
       
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
           
           double fees = OrderCommission() + OrderSwap();
           string feesStr = DoubleToString(fees, 2);
           
           double prof    = OrderProfit() + OrderCommission() + OrderSwap();
           string profStr = DoubleToString(prof, 2);
           
           double bal = AccountBalance(); 
           double retPrc = 0.0;
           if(bal > 0) retPrc = (prof / bal) * 100.0;
           string retPrcStr = DoubleToString(retPrc, 2) + "%";
           
           double retR = 0.0;
           if(g_OneRPercent > 0) retR = retPrc / g_OneRPercent;
           string retRStr = DoubleToString(retR, 2) + " R";
           
           color profCol = (prof >= 0) ? g_ColorGreen : g_ColorRed;
           color typeCol = (type==OP_BUY || type==OP_BUYLIMIT || type==OP_BUYSTOP) ? g_ColorGreen : g_ColorRed;
           
           int txtY = itemY + 6;
           int colX = x + paddingX;
           
           CreateLabel("Hist_Item_Time"+sfx, timeStr, colX, txtY, 8, g_ColorText, "Trebuchet MS");
           CreateLabel("Hist_Item_Type"+sfx, typeStr, colX + wTime, txtY, 8, typeCol, "Trebuchet MS");
           CreateLabel("Hist_Item_Sym"+sfx, symStr, colX + wTime + wType, txtY, 8, g_ColorText, "Trebuchet MS");
           CreateLabel("Hist_Item_Fees"+sfx, feesStr, colX + wTime + wType + wSym, txtY, 8, g_ColorText, "Trebuchet MS"); 
           CreateLabel("Hist_Item_Prof"+sfx, profStr, colX + wTime + wType + wSym + wFees, txtY, 8, profCol, "Trebuchet MS");
           CreateLabel("Hist_Item_RetP"+sfx, retPrcStr, colX + wTime + wType + wSym + wFees + wProf, txtY, 8, profCol, "Trebuchet MS");
           CreateLabel("Hist_Item_RetR"+sfx, retRStr, colX + wTime + wType + wSym + wFees + wProf + wRetP, txtY, 8, profCol, "Trebuchet MS");
           
           ObjectSetInteger(0, PREFIX + "Hist_Item_Time"+sfx, OBJPROP_ZORDER, 12);
           ObjectSetInteger(0, PREFIX + "Hist_Item_Type"+sfx, OBJPROP_ZORDER, 12);
           ObjectSetInteger(0, PREFIX + "Hist_Item_Sym"+sfx, OBJPROP_ZORDER, 12);
           ObjectSetInteger(0, PREFIX + "Hist_Item_Fees"+sfx, OBJPROP_ZORDER, 12);
           ObjectSetInteger(0, PREFIX + "Hist_Item_Prof"+sfx, OBJPROP_ZORDER, 12);
           ObjectSetInteger(0, PREFIX + "Hist_Item_RetP"+sfx, OBJPROP_ZORDER, 12);
           ObjectSetInteger(0, PREFIX + "Hist_Item_RetR"+sfx, OBJPROP_ZORDER, 12);
       }
   }
}

//+------------------------------------------------------------------+
//| SCROLLBAR                                                        |
//+------------------------------------------------------------------+
void DrawHistoryScrollbar(int x, int y, int w)
{
   int trackW = 12;
   int trackH = g_ScrollHistory.ViewportHeight;
   int trackX = x + w - trackW - 5;
   int trackY = y;
   
   CreateRect("Hist_ScrollTrack", trackX, trackY, trackW, trackH, g_ColorInput, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "Hist_ScrollTrack", OBJPROP_ZORDER, 15);
   
   int contentH = g_ScrollHistory.ContentHeight;
   if(contentH <= g_ScrollHistory.ViewportHeight) contentH = g_ScrollHistory.ViewportHeight + 1; 
   
   double ratio = (double)g_ScrollHistory.ViewportHeight / (double)contentH;
   if(ratio > 1.0) ratio = 1.0;
   
   int thumbH = (int)(trackH * ratio);
   if(thumbH < 20) thumbH = 20;
   
   int maxScroll = contentH - g_ScrollHistory.ViewportHeight;
   if(maxScroll < 0) maxScroll = 0;
   
   int thumbY = trackY;
   if(maxScroll > 0)
   {
       double scrollPrc = (double)g_ScrollHistory.ScrollY / (double)maxScroll;
       int availableTrack = trackH - thumbH;
       thumbY = trackY + (int)(scrollPrc * availableTrack);
   }
   
   CreateRect("Hist_ScrollThumb", trackX + 1, thumbY, trackW - 2, thumbH, g_ColorBtnValid, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "Hist_ScrollThumb", OBJPROP_ZORDER, 16);
   ObjectSetInteger(0, PREFIX + "Hist_ScrollThumb", OBJPROP_BGCOLOR, g_ColorText);
}

//+------------------------------------------------------------------+
//| DRAW FOOTER (TOTALS)                                             |
//+------------------------------------------------------------------+
void DrawHistoryFooter(int x, int y, int w, int h)
{
   double sumFees = 0.0;
   double sumProf = 0.0;
   
   int total = ArraySize(g_HistoryFilteredIndices);
   for(int i=0; i<total; i++)
   {
      int ticketIndex = g_HistoryFilteredIndices[i];
      if(OrderSelect(ticketIndex, SELECT_BY_POS, MODE_HISTORY))
      {
         double fees = OrderCommission() + OrderSwap();
         double prof = OrderProfit() + fees;
         
         sumFees += fees;
         sumProf += prof;
      }
   }
   
   double bal = AccountBalance();
   double totalRetP = 0.0;
   double totalRetR = 0.0;
   
   if(bal > 0) totalRetP = (sumProf / bal) * 100.0;
   if(g_OneRPercent > 0) totalRetR = totalRetP / g_OneRPercent;
   
   int paddingX = 20;
   int colX = x + paddingX;
   
   int wTime  = 150;
   int wType  = 100;
   int wSym   = 100;
   int wFees  = 100;
   int wProf  = 120;
   int wRetP  = 90;
   
   string sFees = DoubleToString(sumFees, 2);
   string sProf = DoubleToString(sumProf, 2);
   string sRetP = DoubleToString(totalRetP, 2) + "%";
   string sRetR = DoubleToString(totalRetR, 2) + " R";
   
   color colProf = (sumProf >= 0) ? g_ColorGreen : g_ColorRed;
   
   CreateRect("Hist_Footer_Line", x, y, w, 1, C'50,50,50', BORDER_FLAT);
   
   int textY = y + 10;
   CreateLabel("Hist_Foot_Fees", sFees, colX + wTime + wType + wSym, textY, 8, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Hist_Foot_Prof", sProf, colX + wTime + wType + wSym + wFees, textY, 8, colProf, "Trebuchet MS Bold");
   CreateLabel("Hist_Foot_RetP", sRetP, colX + wTime + wType + wSym + wFees + wProf, textY, 8, colProf, "Trebuchet MS Bold");
   CreateLabel("Hist_Foot_RetR", sRetR, colX + wTime + wType + wSym + wFees + wProf + wRetP, textY, 8, colProf, "Trebuchet MS Bold");
   CreateLabel("Hist_Foot_Label", "TOTAL", x + 15, textY, 8, g_ColorText, "Trebuchet MS Bold");
}
