//+------------------------------------------------------------------+
//|                                              Panel_History.mqh   |
//|                                                MagicKey Project  |
//+------------------------------------------------------------------+
#property strict

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
      // Start of Week (Sunday/Monday depending on broker, let's use week start)
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      // Adjust to day 0 (Sunday) or 1 (Monday)? Usually start of week is straightforward
      // Simplest: TimeCurrent() - (DayOfWeek * 24*3600) + Clean Hours
      // But let's use iTime(NULL, PERIOD_W1, 0)
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
   // Reserve potentially needed memory to speed up?
   // ArrayResize(g_HistoryFilteredIndices, total); 
   // But we'll push back.
   
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
         
         // Fix: Exclude Balance/Credit operations (Type > 1) to prevent "Deposit" appearing as Profit
         // We only want OP_BUY (0) and OP_SELL (1)
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
   
   // Reset scroll if needed
   // g_HistoryScrollY = 0; // Maybe not force reset if just updating? But safe.
}

//+------------------------------------------------------------------+
//| HELPER: SET FILTER MODE                                          |
//+------------------------------------------------------------------+
void SetHistoryFilter(ENUM_HISTORY_FILTER mode)
{
    g_HistoryFilterMode = mode;
    g_HistoryScrollY = 0; // Reset scroll on view change
    UpdateHistoryFilter();
    CreateHistoryPanel(); // Redraw
}


//+------------------------------------------------------------------+
//| CREATION DU PANEL HISTORIQUE                                     |
//+------------------------------------------------------------------+
void CreateHistoryPanel()
{
   if(!IsHistoryPanelVisible) return;
   
   int width = 800; // Largeur
   int rowHeight = 30; 
   int headerHeight = 40;
   
   int startX = HistoryPanelX;
   int startY = HistoryPanelY;
   
   // --- Calculate Dynamic Offsets ---
   int toolbarHeight = 35;
   int customInputHeight = (g_HistoryFilterMode == H_FILTER_CUSTOM) ? 35 : 0;
   
   int topSectionHeight = headerHeight + toolbarHeight + customInputHeight;
   int footerHeight = 40; // Fixed footer height
   int footerMargin = 20; // Margin to separate list from footer
   
   // 1. Fond & Header (Adjusted height to include Footer)
   CreateRect("Hist_Bg", startX, startY, width, topSectionHeight + HistoryViewportHeight + footerMargin + footerHeight, g_ColorBg, BORDER_FLAT);
   CreateRect("Hist_Header", startX, startY, width, headerHeight, g_ColorBg, BORDER_FLAT);
   CreateLabel("Hist_Title", "Transaction History", startX + 15, startY + 10, 10, clrWhite, "Trebuchet MS Bold");
   
   // 2. Filter Buttons Toolbar
   int btnY = startY + headerHeight + 5;
   int btnW = 80;
   int btnH = 25;
   int gap = 10;
   int curBtnX = startX + 15;
   
   color bgDaily   = (g_HistoryFilterMode == H_FILTER_DAILY) ? ColorBtnActive : g_ColorInput;
   color bgWeekly  = (g_HistoryFilterMode == H_FILTER_WEEKLY) ? ColorBtnActive : g_ColorInput;
   color bgMonthly = (g_HistoryFilterMode == H_FILTER_MONTHLY) ? ColorBtnActive : g_ColorInput;
   color bgCustom  = (g_HistoryFilterMode == H_FILTER_CUSTOM) ? ColorBtnActive : g_ColorInput;
   
   CreateButton("Hist_Btn_Daily", "Daily", curBtnX, btnY, btnW, btnH, bgDaily, clrWhite);
   curBtnX += btnW + gap;
   CreateButton("Hist_Btn_Weekly", "Weekly", curBtnX, btnY, btnW, btnH, bgWeekly, clrWhite);
   curBtnX += btnW + gap;
   CreateButton("Hist_Btn_Monthly", "Monthly", curBtnX, btnY, btnW, btnH, bgMonthly, clrWhite);
   curBtnX += btnW + gap;
   CreateButton("Hist_Btn_Custom", "Custom", curBtnX, btnY, btnW, btnH, bgCustom, clrWhite);
   
   // Symbol Filter UI (Right of buttons)
   int symX = curBtnX + btnW + 30;
   CreateLabel("Hist_Lbl_SymFilter", "Symbol:", symX, btnY+3, 8, g_ColorText);
   CreateEdit("Hist_Input_Symbol", g_HistoryFilterSymbol, symX + 40, btnY, 80, btnH);
   
   // 2.5 Custom Inputs (If Active)
   if(g_HistoryFilterMode == H_FILTER_CUSTOM)
   {
       int inpY = btnY + btnH + 5;
       
       // Centering relative to the buttons (Total Buttons Width ~350px, Starts at startX + 15)
       // Center of buttons = startX + 15 + 175 = startX + 190.
       // Content Width approx: Lbl(35) + Inp(100) + Gap(20) + Lbl(25) + Inp(100) = 280px.
       // StartX for Content = (startX + 190) - (280/2) = startX + 50.
       
       int cursorX = startX + 50;
       int inpW = 100;
       
       CreateLabel("Hist_Lbl_From", "From:", cursorX, inpY+3, 8, g_ColorText);
       CreateEdit("Hist_Input_Start", TimeToString(g_HistoryCustomStart, TIME_DATE), cursorX + 35, inpY, inpW, 25);
       
       cursorX = cursorX + 35 + inpW + 20; // Move after first input + gap
       
       CreateLabel("Hist_Lbl_To", "To:", cursorX, inpY+3, 8, g_ColorText);
       CreateEdit("Hist_Input_End", TimeToString(g_HistoryCustomEnd, TIME_DATE), cursorX + 25, inpY, inpW, 25);
       
       // Apply button removed as requested (Auto-apply on edit)
   }
   else
   {
       // Cleanup inputs if switching away
       if(ObjectFind(0, PREFIX+"Hist_Input_Start") >= 0) ObjectDelete(0, PREFIX+"Hist_Input_Start");
       if(ObjectFind(0, PREFIX+"Hist_Input_End") >= 0) ObjectDelete(0, PREFIX+"Hist_Input_End");
       if(ObjectFind(0, PREFIX+"Hist_Lbl_From") >= 0) ObjectDelete(0, PREFIX+"Hist_Lbl_From");
       if(ObjectFind(0, PREFIX+"Hist_Lbl_To") >= 0) ObjectDelete(0, PREFIX+"Hist_Lbl_To");
   }
   
   // 3. Headings
   int colY = startY + topSectionHeight + 10;
   int colX = startX + 20;
   
   // Layout Dimensions
   int wTime  = 150;
   int wType  = 100;
   int wSym   = 100;
   int wFees  = 100;
   int wProf  = 120;
   int wRetP  = 90;
   // wRetR (Rest)
   
   CreateLabel("Hist_H_Time", "TIME", colX, colY, 8, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Hist_H_Type", "TYPE", colX + wTime, colY, 8, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Hist_H_Sym",  "SYMBOL", colX + wTime + wType, colY, 8, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Hist_H_Fees", "FEES", colX + wTime + wType + wSym, colY, 8, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Hist_H_Prof", "PROFIT", colX + wTime + wType + wSym + wFees, colY, 8, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Hist_H_RetP", "RETURN %", colX + wTime + wType + wSym + wFees + wProf, colY, 8, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Hist_H_RetR", "RETURN R", colX + wTime + wType + wSym + wFees + wProf + wRetP, colY, 8, g_ColorText, "Trebuchet MS Bold");
   
   // Cleanup Old Labels (Safety)
   if(ObjectFind(0, PREFIX + "Hist_H_Size") >= 0) ObjectDelete(0, PREFIX + "Hist_H_Size");
   if(ObjectFind(0, PREFIX + "Hist_H_Price") >= 0) ObjectDelete(0, PREFIX + "Hist_H_Price");
   
   // 4. Content
   int contentY = colY + 25;
   DrawHistoryContent(startX, contentY, width, rowHeight);
   
   // 5. Scrollbar
   // Adjust Scrollbar Y and H? 
   // Scrollbar should be aligned with content area
   int scrollY = contentY;
   DrawHistoryScrollbar(startX, scrollY, width);
   
   ChartRedraw();

   // 6. Footer (Totals) - Positioned with gap after viewport
   DrawHistoryFooter(startX, startY + topSectionHeight + HistoryViewportHeight + footerMargin, width, footerHeight);
}

//+------------------------------------------------------------------+
//| DESSIN DU CONTENU (VIRTUAL SCROLL)                               |
//+------------------------------------------------------------------+
void DrawHistoryContent(int x, int y, int w, int rowH)
{
   // Cleanup old visible items
   for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
   {
       string name = ObjectName(0, i);
       if(StringFind(name, PREFIX + "Hist_Item_") >= 0) ObjectDelete(0, name);
   }

   // Use Filtered Indices
   int total = ArraySize(g_HistoryFilteredIndices);
   HistoryContentHeight = total * rowH;
   
   int maxVisibleRows = HistoryViewportHeight / rowH;
   
   // Calculate start index based on scroll pixel offset
   int startIdx = 0;
   if(HistoryContentHeight > HistoryViewportHeight)
   {
      startIdx = g_HistoryScrollY / rowH;
   }
   
   // Clamp
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

   // Loop maxVisibleRows
   for(int i = 0; i < maxVisibleRows; i++)
   {
       int logicalIndex = startIdx + i;
       // We want Newest First (Total-1 down to 0) from the filtered list?
       // g_HistoryFilteredIndices stores indices in ascending order (OLD -> NEW) usually if loop was 0..Total
       // So we want the end of the array.
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
           
           // Fees Calculation (Commission + Swap)
           double fees = OrderCommission() + OrderSwap();
           string feesStr = DoubleToString(fees, 2);
           
           // Net Profit (including fees)
           double prof    = OrderProfit() + OrderCommission() + OrderSwap();
           string profStr = DoubleToString(prof, 2);
           
           // Return % Calculation relative to CURRENT Balance (Estimation)
           // ideally it should be relative to Balance AT OPEN, but complex to query. Current balance is standard approx.
           double bal = AccountBalance(); 
           double retPrc = 0.0;
           if(bal > 0) retPrc = (prof / bal) * 100.0;
           string retPrcStr = DoubleToString(retPrc, 2) + "%";
           
           // Return R Calculation
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
           
           // New Columns
           CreateLabel("Hist_Item_RetP"+sfx, retPrcStr, colX + wTime + wType + wSym + wFees + wProf, txtY, 8, profCol, "Trebuchet MS");
           CreateLabel("Hist_Item_RetR"+sfx, retRStr, colX + wTime + wType + wSym + wFees + wProf + wRetP, txtY, 8, profCol, "Trebuchet MS");
           
           // ZOrder 12 for text
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
   int trackH = HistoryViewportHeight;
   int trackX = x + w - trackW - 5;
   int trackY = y;
   
   CreateRect("Hist_ScrollTrack", trackX, trackY, trackW, trackH, g_ColorInput, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "Hist_ScrollTrack", OBJPROP_ZORDER, 15);
   
   int contentH = HistoryContentHeight;
   if(contentH <= HistoryViewportHeight) contentH = HistoryViewportHeight + 1; 
   
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
   ObjectSetInteger(0, PREFIX + "Hist_ScrollThumb", OBJPROP_BGCOLOR, g_ColorText);
}

//+------------------------------------------------------------------+
//| DRAW FOOTER (TOTALS)                                             |
//+------------------------------------------------------------------+
void DrawHistoryFooter(int x, int y, int w, int h)
{
   // 1. Calculate Sums
   double sumFees = 0.0;
   double sumProf = 0.0;
   
   // We iterate the filtered list (visible items)
   int total = ArraySize(g_HistoryFilteredIndices);
   for(int i=0; i<total; i++)
   {
      int ticketIndex = g_HistoryFilteredIndices[i];
      if(OrderSelect(ticketIndex, SELECT_BY_POS, MODE_HISTORY))
      {
         double fees = OrderCommission() + OrderSwap();
         double prof = OrderProfit() + fees; // Net Profit
         
         sumFees += fees;
         sumProf += prof;
      }
   }
   
   // 2. Global Return Calculations (Based on Total Profit, not sum of %)
   double bal = AccountBalance();
   double totalRetP = 0.0;
   double totalRetR = 0.0;
   
   if(bal > 0)
   {
      totalRetP = (sumProf / bal) * 100.0;
   }
   
   if(g_OneRPercent > 0)
   {
      totalRetR = totalRetP / g_OneRPercent;
   }
   
   // 3. Draw Labels aligned with Headers
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
   
   // Separator Line (Top of footer)
   CreateRect("Hist_Footer_Line", x, y, w, 1, g_ColorInput, BORDER_FLAT);
   
   int textY = y + 10; // Vertical centering for text

   // Draw Totals columns
   CreateLabel("Hist_Foot_Fees", sFees, colX + wTime + wType + wSym, textY, 8, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Hist_Foot_Prof", sProf, colX + wTime + wType + wSym + wFees, textY, 8, colProf, "Trebuchet MS Bold");
   CreateLabel("Hist_Foot_RetP", sRetP, colX + wTime + wType + wSym + wFees + wProf, textY, 8, colProf, "Trebuchet MS Bold");
   CreateLabel("Hist_Foot_RetR", sRetR, colX + wTime + wType + wSym + wFees + wProf + wRetP, textY, 8, colProf, "Trebuchet MS Bold");
   
   // Label "TOTAL" aligned to LEFT (Styled like headers: Size 8, Bold, ColorLabel)
   CreateLabel("Hist_Foot_Label", "TOTAL", x + 15, textY, 8, g_ColorText, "Trebuchet MS Bold");
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
   SetObjVisible("Hist_H_RetP", visible);
   SetObjVisible("Hist_H_RetR", visible);
   
   SetObjVisible("Hist_Footer_Line", visible);
   SetObjVisible("Hist_Foot_Label", visible);
   SetObjVisible("Hist_Foot_Fees", visible);
   SetObjVisible("Hist_Foot_Prof", visible);
   SetObjVisible("Hist_Foot_RetP", visible);
   SetObjVisible("Hist_Foot_RetR", visible);
   
   SetObjVisible("Hist_ScrollTrack", visible);
   SetObjVisible("Hist_ScrollThumb", visible);
   
   SetObjVisible("Hist_Btn_Daily", visible);
   SetObjVisible("Hist_Btn_Weekly", visible);
   SetObjVisible("Hist_Btn_Monthly", visible);
   SetObjVisible("Hist_Btn_Custom", visible);
   
   SetObjVisible("Hist_Lbl_SymFilter", visible);
   SetObjVisible("Hist_Input_Symbol", visible);
   
   if(visible && g_HistoryFilterMode == H_FILTER_CUSTOM)
   {
       SetObjVisible("Hist_Input_Start", true);
       SetObjVisible("Hist_Input_End", true);
       SetObjVisible("Hist_Lbl_From", true);
       SetObjVisible("Hist_Lbl_To", true);
   }
   else
   {
       SetObjVisible("Hist_Input_Start", false);
       SetObjVisible("Hist_Input_End", false);
       SetObjVisible("Hist_Lbl_From", false);
       SetObjVisible("Hist_Lbl_To", false);
   }
   
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
       UpdateHistoryFilter(); // Refresh filter on open
       CreateHistoryPanel(); 
   }
}
