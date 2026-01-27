//+------------------------------------------------------------------+
//|                                              Panel_Info.mqh      |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

// GLOBAL pour suivre le nombre d'ordres affichés
int g_LastInfoOrderCount = 0;
int g_TotalInfoOrderCount = 0; // Total orders (including non-visible due to scroll)
int g_InfoOrdersTickets[];     // Tickets of currently visible orders (for click handling)

// Optimization: Cache history stats to avoid O(N) loop every tick
int    g_LastHistoryTotal = -1;
double g_CachedDeposit    = 0.0;
double g_CachedWithdraw   = 0.0;

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
void GetAccountHistoryStats(double &outDeposit, double &outWithdraw)
{
   outDeposit = 0;
   outWithdraw = 0;
   int total = OrdersHistoryTotal();
   for(int i=0; i<total; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         if(OrderType() == 6) // OP_BALANCE = 6 (Deposit/Withdraw)
         {
            double amt = OrderProfit();
            if(amt > 0) outDeposit += amt;
            else        outWithdraw += MathAbs(amt);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| HELPER: DRAW ORDERS SCROLLBAR                                    |
//+------------------------------------------------------------------+
void DrawInfoOrdersScrollbar(int trackX, int trackY, int trackH, int totalOrders, int maxVisible)
{
   int scrollBarWidth = 8;
   
   // 1. Track Background
   if(ObjectFind(0, PREFIX + "Info_Ord_ScrollTrack") < 0)
   {
      CreateRect("Info_Ord_ScrollTrack", trackX, trackY, scrollBarWidth, trackH, g_ColorBg, BORDER_FLAT);
   }
   SetObjPosition("Info_Ord_ScrollTrack", trackX, trackY);
   ObjectSetInteger(0, PREFIX + "Info_Ord_ScrollTrack", OBJPROP_XSIZE, scrollBarWidth);
   ObjectSetInteger(0, PREFIX + "Info_Ord_ScrollTrack", OBJPROP_YSIZE, trackH);
   ObjectSetInteger(0, PREFIX + "Info_Ord_ScrollTrack", OBJPROP_BGCOLOR, g_ColorBg);
   ObjectSetInteger(0, PREFIX + "Info_Ord_ScrollTrack", OBJPROP_BORDER_COLOR, g_ColorBg);
   ObjectSetInteger(0, PREFIX + "Info_Ord_ScrollTrack", OBJPROP_ZORDER, 16);
   
   // 2. Thumb
   double ratio = (double)maxVisible / (double)totalOrders;
   if(ratio > 1.0) ratio = 1.0;
   
   int thumbH = (int)(trackH * ratio);
   if(thumbH < 20) thumbH = 20; // Min size
   
   // Position
   int maxScroll = totalOrders - maxVisible;
   if(maxScroll <= 0) maxScroll = 1;
   
   double p = (double)g_InfoOrdersScrollOffset / (double)maxScroll;
   if(p < 0) p = 0;
   if(p > 1) p = 1;
   
   int thumbY = trackY + (int)(p * (trackH - thumbH));
   
   if(ObjectFind(0, PREFIX + "Info_Ord_ScrollThumb") < 0)
   {
      CreateButton("Info_Ord_ScrollThumb", "", trackX + 1, thumbY, scrollBarWidth - 2, thumbH, g_ColorText, clrNONE);
   }
   SetObjPosition("Info_Ord_ScrollThumb", trackX + 1, thumbY);
   ObjectSetInteger(0, PREFIX + "Info_Ord_ScrollThumb", OBJPROP_XSIZE, scrollBarWidth - 2);
   ObjectSetInteger(0, PREFIX + "Info_Ord_ScrollThumb", OBJPROP_YSIZE, thumbH);
   ObjectSetInteger(0, PREFIX + "Info_Ord_ScrollThumb", OBJPROP_BGCOLOR, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Info_Ord_ScrollThumb", OBJPROP_BORDER_COLOR, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Info_Ord_ScrollThumb", OBJPROP_ZORDER, 17);
}

//+------------------------------------------------------------------+
//| HELPER: HIDE ORDERS SCROLLBAR                                    |
//+------------------------------------------------------------------+
void HideInfoOrdersScrollbar()
{
   SetObjVisible("Info_Ord_ScrollTrack", false);
   SetObjVisible("Info_Ord_ScrollThumb", false);
}

//+------------------------------------------------------------------+
//| MISE A JOUR DU LAYOUT (POSITIONNEMENT)                           |
//+------------------------------------------------------------------+
void UpdateInfoLayout()
{
   int startX = g_PanelInfo.X;
   int startY = g_PanelInfo.Y;
   int width  = 260; // Wider Panel for better spacing
   
   int paddingX = 20;
   int rowH     = 28; // Height of an order row
   int gapY     = 4;  // Gap between rows
   int scrollBarWidth = 8;
   
   int currentY = startY + 50; 
   
   // --- HEAD & BG ---
   SetObjPosition("Info_Bg", startX, startY);
   SetObjPosition("Info_Header", startX, startY);
   SetObjPosition("Info_Title", startX + 15, startY + 12);
   
   ObjectSetInteger(0, PREFIX + "Info_Bg", OBJPROP_XSIZE, width);
   ObjectSetInteger(0, PREFIX + "Info_Header", OBJPROP_XSIZE, width);
   
   // --- ACCOUNT SECTION (GROUPED) ---
   int statsBgH = 200; // Reduced height to remove extra space (was 245)
   
   SetObjPosition("Info_Stats_Bg", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Info_Stats_Bg", OBJPROP_XSIZE, width - (paddingX*2));
   ObjectSetInteger(0, PREFIX + "Info_Stats_Bg", OBJPROP_YSIZE, statsBgH);
   
   int statsDescX = startX + paddingX + 15;
   int statsTopY  = currentY + 10;
   int colW  = (width - (paddingX*2) - 30) / 2;
   
   // Balance (Row 1 Left)
   SetObjPosition("Info_Lbl_Balance", statsDescX, statsTopY);
   SetObjPosition("Info_Val_Balance", statsDescX, statsTopY + 15);
   
   // PNL (Row 1 Right)
   SetObjPosition("Info_Lbl_PnL", statsDescX + colW, statsTopY);
   SetObjPosition("Info_Val_PnL", statsDescX + colW, statsTopY + 15);
   
   // --- ROW 2: ROI % & ROI R ---
   int row2Y = statsTopY + 45;
   
   // ROI % (Row 2 Left)
   SetObjPosition("Info_Lbl_PerfP", statsDescX, row2Y);
   SetObjPosition("Info_Val_PerfP", statsDescX, row2Y + 15);
   
   // ROI R (Row 2 Right)
   SetObjPosition("Info_Lbl_PerfR", statsDescX + colW, row2Y);
   SetObjPosition("Info_Val_PerfR", statsDescX + colW, row2Y + 15);
   
   // --- ROW 3: EQUITY & MARGIN ---
   int row3Y = row2Y + 45;
   
   // Equity (Left)
   SetObjPosition("Info_Lbl_Equity", statsDescX, row3Y);
   SetObjPosition("Info_Val_Equity", statsDescX, row3Y + 15);
   
   // Margin (Right)
   SetObjPosition("Info_Lbl_Margin", statsDescX + colW, row3Y);
   SetObjPosition("Info_Val_Margin", statsDescX + colW, row3Y + 15);
   
   // --- ROW 4: DEPOSIT & WITHDRAW ---
   int row4Y = row3Y + 45;
   
   // Deposit (Left)
   SetObjPosition("Info_Lbl_Deposit", statsDescX, row4Y);
   SetObjPosition("Info_Val_Deposit", statsDescX, row4Y + 15);
   
   // Withdraw (Right)
   SetObjPosition("Info_Lbl_Withdraw", statsDescX + colW, row4Y);
   SetObjPosition("Info_Val_Withdraw", statsDescX + colW, row4Y + 15);
   
   // Adjust height if needed or keep standard
   int row5Y = row4Y + 45; // Just for consistency logic if we added more
   
   currentY += statsBgH + 15;
   
   // --- SEPARATOR ---
   SetObjPosition("Info_Sep", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Info_Sep", OBJPROP_XSIZE, width - (paddingX*2));
   
   currentY += 15;
   
   // --- POSITIONS HEADER ---
   SetObjPosition("Info_SubTitle_Pos", startX + paddingX, currentY);
   currentY += 20;
   
   // --- ORDERS LIST CONTAINER (Fixed Size when scrolling) ---
   int ordersListY = currentY;
   bool needsScroll = (g_TotalInfoOrderCount > g_InfoOrdersMaxVisible);
   int visibleCount = needsScroll ? g_InfoOrdersMaxVisible : g_TotalInfoOrderCount;
   int itemWidth = needsScroll ? (width - (paddingX*2) - scrollBarWidth - 4) : (width - (paddingX*2));
   
   // Clamp scroll offset
   if(needsScroll)
   {
      int maxOffset = g_TotalInfoOrderCount - g_InfoOrdersMaxVisible;
      if(g_InfoOrdersScrollOffset > maxOffset) g_InfoOrdersScrollOffset = maxOffset;
      if(g_InfoOrdersScrollOffset < 0) g_InfoOrdersScrollOffset = 0;
   }
   else
   {
      g_InfoOrdersScrollOffset = 0;
   }
   
   // --- POSITIONS LIST ---
   // We iterate through visible items only (based on scroll offset)
   for(int i=0; i<visibleCount; i++)
   {
      string suffix = "_" + IntegerToString(i);
      
      // Background Card
      SetObjPosition("Info_Ord_Bg" + suffix, startX + paddingX, currentY);
      ObjectSetInteger(0, PREFIX + "Info_Ord_Bg" + suffix, OBJPROP_XSIZE, itemWidth);
      ObjectSetInteger(0, PREFIX + "Info_Ord_Bg" + suffix, OBJPROP_YSIZE, rowH);
      
      // Symbol (Left)
      SetObjPosition("Info_Ord_Sym" + suffix, startX + paddingX + 8, currentY + 6);
      
      // Type (Right) - Adjust position based on scroll area
      int typeX = needsScroll ? (startX + width - paddingX - scrollBarWidth - 75) : (startX + width - paddingX - 70);
      SetObjPosition("Info_Ord_Typ" + suffix, typeX, currentY + 7);
      
      currentY += rowH + gapY;
   }
   
   // Hide extra items beyond visible count
   for(int k=visibleCount; k<g_LastInfoOrderCount; k++)
   {
      string suffix = "_" + IntegerToString(k);
      SetObjVisible("Info_Ord_Bg" + suffix, false);
      SetObjVisible("Info_Ord_Sym" + suffix, false);
      SetObjVisible("Info_Ord_Typ" + suffix, false);
   }
   
   // --- SCROLLBAR ---
   if(needsScroll && g_PanelInfo.IsVisible)
   {
      int trackH = visibleCount * (rowH + gapY) - gapY;
      int trackX = startX + width - paddingX - scrollBarWidth;
      DrawInfoOrdersScrollbar(trackX, ordersListY, trackH, g_TotalInfoOrderCount, g_InfoOrdersMaxVisible);
      SetObjVisible("Info_Ord_ScrollTrack", true);
      SetObjVisible("Info_Ord_ScrollThumb", true);
   }
   else
   {
      HideInfoOrdersScrollbar();
   }
   
   if(g_TotalInfoOrderCount == 0)
   {
      SetObjPosition("Info_NoOrd_Msg", startX + paddingX, currentY);
      currentY += 20;
   }
   
   // Ajustement hauteur fond
   int totalHeight = currentY - startY + 15;
   ObjectSetInteger(0, PREFIX + "Info_Bg", OBJPROP_YSIZE, totalHeight);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| CRÉATION DES OBJETS                                              |
//+------------------------------------------------------------------+
void CreateInfoPanel()
{
   int width = 260;
   
   // 1. Fond & Header
   CreateRect("Info_Bg", 0, 0, width, 100, g_ColorBg, BORDER_FLAT); 
   CreateRect("Info_Header", 0, 0, width, 45, g_ColorBg, BORDER_FLAT);
   CreateLabel("Info_Title", "Account Overview", 0, 0, 10, g_ColorText, "Trebuchet MS Bold");
   
   // 2. Account Data
   CreateRect("Info_Stats_Bg", 0, 0, width - 40, 110, g_ColorInput, BORDER_FLAT); // Grouping Box
   ObjectSetInteger(0, PREFIX + "Info_Stats_Bg", OBJPROP_BORDER_COLOR, g_ColorInput);

   CreateLabel("Info_Lbl_Balance", "BALANCE", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Info_Val_Balance", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold"); // Reduced to 9
   
   CreateLabel("Info_Lbl_Equity", "EQUITY", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Info_Val_Equity", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Info_Lbl_Margin", "MARGIN", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Info_Val_Margin", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Info_Lbl_Deposit", "DEPOSIT", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Info_Val_Deposit", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Info_Lbl_Withdraw", "WITHDRAW", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Info_Val_Withdraw", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Info_Lbl_PnL", "PNL", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Info_Val_PnL", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Info_Lbl_PerfP", "ROI", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Info_Val_PerfP", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Info_Lbl_PerfR", "ROI", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Info_Val_PerfR", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   // 3. Separator Line
   CreateRect("Info_Sep", 0, 0, 100, 1, C'50,50,50', BORDER_FLAT);
   
   // 4. SubHeader
   CreateLabel("Info_SubTitle_Pos", "Active Orders", 0, 0, 8, g_ColorText, "Trebuchet MS Bold");
   
   // 5. No Orders Message
   CreateLabel("Info_NoOrd_Msg", "No active orders", 0, 0, 8, g_ColorText, "Trebuchet MS");
   
   UpdateInfoLayout();
   UpdateInfoPanel();
}

//+------------------------------------------------------------------+
//| MISE A JOUR DES VALEURS (TICK)                                   |
//+------------------------------------------------------------------+
void UpdateInfoPanel()
{
   if(!g_PanelInfo.IsVisible) return;

   string currency = AccountCurrency();
   
   double bal = AccountBalance();
   double equ = AccountEquity();
   double marg = AccountFreeMargin();
   
   string sBal = DoubleToString(bal, 2);
   string sEqu = DoubleToString(equ, 2);
   string sMarg = DoubleToString(marg, 2);
   
   ObjectSetString(0, PREFIX + "Info_Val_Balance", OBJPROP_TEXT, sBal);
   ObjectSetString(0, PREFIX + "Info_Val_Equity", OBJPROP_TEXT, sEqu);
   ObjectSetString(0, PREFIX + "Info_Val_Margin", OBJPROP_TEXT, sMarg);
   
   // --- DEPOSIT / WITHDRAW UPDATE ---
   double deps = 0, wits = 0;
   
   // OPTIMIZATION: Only recalculate if history count changed
   int currentHistoryTotal = OrdersHistoryTotal();
   if(currentHistoryTotal != g_LastHistoryTotal)
   {
      GetAccountHistoryStats(g_CachedDeposit, g_CachedWithdraw);
      g_LastHistoryTotal = currentHistoryTotal;
   }
   
   deps = g_CachedDeposit;
   wits = g_CachedWithdraw;
   
   string sDeps = DoubleToString(deps, 2);
   string sWits = DoubleToString(wits, 2);
   
   ObjectSetString(0, PREFIX + "Info_Val_Deposit", OBJPROP_TEXT, sDeps);
   ObjectSetString(0, PREFIX + "Info_Val_Withdraw", OBJPROP_TEXT, sWits);
   
   // --- CALCUL P&L et PERF ---
   // P&L = Balance + Withdraw - Deposit
   double pnl = bal + wits - deps;
   
   // Perf % = (P&L / Deposit) * 100 
   double perfP = 0.0;
   if(deps > 0) perfP = (pnl / deps) * 100.0;
   
   // Perf R = Perf % / 1R_Value
   double perfR = 0.0;
   if(g_OneRPercent > 0) perfR = perfP / g_OneRPercent;
   
   string sPnL   = DoubleToString(pnl, 2);
   string sPerfP = DoubleToString(perfP, 2) + " %";
   string sPerfR = DoubleToString(perfR, 2) + " R";
   
   ObjectSetString(0, PREFIX + "Info_Val_PnL", OBJPROP_TEXT, sPnL);
   
   // Couleurs conditionnelles pour P&L
   if(pnl >= 0) ObjectSetInteger(0, PREFIX + "Info_Val_PnL", OBJPROP_COLOR, g_ColorGreen);
   else         ObjectSetInteger(0, PREFIX + "Info_Val_PnL", OBJPROP_COLOR, g_ColorRed);
   
   ObjectSetString(0, PREFIX + "Info_Val_PerfP", OBJPROP_TEXT, sPerfP);
   if(perfP >= 0) ObjectSetInteger(0, PREFIX + "Info_Val_PerfP", OBJPROP_COLOR, g_ColorGreen);
   else           ObjectSetInteger(0, PREFIX + "Info_Val_PerfP", OBJPROP_COLOR, g_ColorRed);
   
   ObjectSetString(0, PREFIX + "Info_Val_PerfR", OBJPROP_TEXT, sPerfR);
   if(perfR >= 0) ObjectSetInteger(0, PREFIX + "Info_Val_PerfR", OBJPROP_COLOR, g_ColorGreen);
   else           ObjectSetInteger(0, PREFIX + "Info_Val_PerfR", OBJPROP_COLOR, g_ColorRed);
   
   // Ensure colors are consistent if they were changed elsewhere
   ObjectSetInteger(0, PREFIX + "Info_Val_Balance", OBJPROP_COLOR, g_ColorText);
   
   // --- ORDER LIST UPDATES ---
   // First pass: Count total orders and collect tickets
   int total = OrdersTotal();
   int tickets[];
   int orderCount = 0;
   
   for(int i=0; i<total; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         ArrayResize(tickets, orderCount + 1);
         tickets[orderCount] = OrderTicket();
         orderCount++;
      }
   }
   
   g_TotalInfoOrderCount = orderCount;
   
   // Clamp scroll offset
   bool needsScroll = (orderCount > g_InfoOrdersMaxVisible);
   if(needsScroll)
   {
      int maxOffset = orderCount - g_InfoOrdersMaxVisible;
      if(g_InfoOrdersScrollOffset > maxOffset) g_InfoOrdersScrollOffset = maxOffset;
      if(g_InfoOrdersScrollOffset < 0) g_InfoOrdersScrollOffset = 0;
   }
   else
   {
      g_InfoOrdersScrollOffset = 0;
   }
   
   // Calculate visible range
   int visibleStart = g_InfoOrdersScrollOffset;
   int visibleEnd = needsScroll ? (g_InfoOrdersScrollOffset + g_InfoOrdersMaxVisible) : orderCount;
   if(visibleEnd > orderCount) visibleEnd = orderCount;
   
   // Prepare global tickets array for click handling
   int visibleCount = visibleEnd - visibleStart;
   ArrayResize(g_InfoOrdersTickets, visibleCount);
   
   int visualIndex = 0;
   
   for(int j=visibleStart; j<visibleEnd; j++)
   {
      int tck = tickets[j];
      
      // Store ticket in global array for click identification
      if(visualIndex < visibleCount)
         g_InfoOrdersTickets[visualIndex] = tck;
      
      if(OrderSelect(tck, SELECT_BY_TICKET))
      {
         // DATA
         string typeStr = GetOrderTypeStrShort(OrderType());
         string symbol  = OrderSymbol();
         color typeColor = (OrderType() % 2 == 0) ? g_ColorGreen : g_ColorRed;
         
         string suffix = "_" + IntegerToString(visualIndex);
         
         // 1. Background Card (Darker than BG to pop, or lighter? lets use Header Color for card)
         string nameBg = "Info_Ord_Bg" + suffix;
         if(ObjectFind(0, PREFIX + nameBg) < 0) CreateRect(nameBg, 0, 0, 10, 10, g_ColorInput, BORDER_FLAT); 
         ObjectSetInteger(0, PREFIX + nameBg, OBJPROP_BGCOLOR, g_ColorInput); // Use Input color for cards
         ObjectSetInteger(0, PREFIX + nameBg, OBJPROP_BORDER_COLOR, g_ColorInput);
         SetObjVisible(nameBg, true);

         // 2. Symbol Label
         string nameSym = "Info_Ord_Sym" + suffix;
         if(ObjectFind(0, PREFIX + nameSym) < 0) CreateLabel(nameSym, symbol, 0, 0, 9, clrWhite, "Trebuchet MS Bold");
         ObjectSetString(0, PREFIX + nameSym, OBJPROP_TEXT, symbol);
         SetObjVisible(nameSym, true);
         
         // 3. Type Label
         string nameTyp = "Info_Ord_Typ" + suffix;
         if(ObjectFind(0, PREFIX + nameTyp) < 0) CreateLabel(nameTyp, typeStr, 0, 0, 8, typeColor, "Trebuchet MS");
         ObjectSetString(0, PREFIX + nameTyp, OBJPROP_TEXT, typeStr);
         ObjectSetInteger(0, PREFIX + nameTyp, OBJPROP_COLOR, typeColor);
         SetObjVisible(nameTyp, true);
         
         visualIndex++;
      }
   }
   
   // Handle "No active orders" visibility
   if(orderCount == 0)
   {
      SetObjVisible("Info_NoOrd_Msg", true);
   }
   else
   {
      SetObjVisible("Info_NoOrd_Msg", false);
   }
   
   // Clean up stale objects (Bg + Sym + Typ)
   // Only hide items beyond the visible count
   int prevDisplayed = g_LastInfoOrderCount;
   for(int k=visualIndex; k<prevDisplayed; k++)
   {
      string suffix = "_" + IntegerToString(k);
      SetObjVisible("Info_Ord_Bg" + suffix, false);
      SetObjVisible("Info_Ord_Sym" + suffix, false);
      SetObjVisible("Info_Ord_Typ" + suffix, false);
   }
   
   // Delete objects for items way beyond current total to save memory
   int maxKept = MathMax(g_InfoOrdersMaxVisible, prevDisplayed);
   for(int k=maxKept; k<prevDisplayed + 10; k++)
   {
      string suffix = "_" + IntegerToString(k);
      if(ObjectFind(0, PREFIX + "Info_Ord_Bg" + suffix) >= 0)
      {
         ObjectDelete(0, PREFIX + "Info_Ord_Bg" + suffix);
         ObjectDelete(0, PREFIX + "Info_Ord_Sym" + suffix);
         ObjectDelete(0, PREFIX + "Info_Ord_Typ" + suffix);
      }
   }
   
   g_LastInfoOrderCount = visualIndex;
   
   // Recalculate Layout (Height & Positions)
   UpdateInfoLayout();
}

//+------------------------------------------------------------------+
//| VISIBILITY CONTROL                                               |
//+------------------------------------------------------------------+
void ToggleInfoPanel(bool visible)
{
   SetObjVisible("Info_Bg", visible);
   SetObjVisible("Info_Header", visible);
   SetObjVisible("Info_Title", visible);
   
   SetObjVisible("Info_Stats_Bg", visible); // Show Group Box
   SetObjVisible("Info_Lbl_Balance", visible);
   SetObjVisible("Info_Val_Balance", visible);
   SetObjVisible("Info_Lbl_Equity", visible);
   SetObjVisible("Info_Val_Equity", visible);
   SetObjVisible("Info_Lbl_Margin", visible);
   SetObjVisible("Info_Val_Margin", visible);
   SetObjVisible("Info_Lbl_Deposit", visible);
   SetObjVisible("Info_Val_Deposit", visible);
   SetObjVisible("Info_Lbl_Withdraw", visible);
   SetObjVisible("Info_Val_Withdraw", visible);
   
   SetObjVisible("Info_Lbl_PnL", visible);
   SetObjVisible("Info_Val_PnL", visible);
   SetObjVisible("Info_Lbl_PerfP", visible);
   SetObjVisible("Info_Val_PerfP", visible);
   SetObjVisible("Info_Lbl_PerfR", visible);
   SetObjVisible("Info_Val_PerfR", visible);
   
   SetObjVisible("Info_Sep", visible);
   SetObjVisible("Info_SubTitle_Pos", visible);
   
   if(visible && g_TotalInfoOrderCount == 0)
       SetObjVisible("Info_NoOrd_Msg", true);
   else
       SetObjVisible("Info_NoOrd_Msg", false);
   
   // Position Lines
   int visibleCount = (g_TotalInfoOrderCount > g_InfoOrdersMaxVisible) ? g_InfoOrdersMaxVisible : g_TotalInfoOrderCount;
   for(int i=0; i<visibleCount; i++)
   {
      string suffix = "_" + IntegerToString(i);
      SetObjVisible("Info_Ord_Bg" + suffix, visible);
      SetObjVisible("Info_Ord_Sym" + suffix, visible);
      SetObjVisible("Info_Ord_Typ" + suffix, visible);
   }
   
   // Handle scrollbar visibility
   bool needsScroll = (g_TotalInfoOrderCount > g_InfoOrdersMaxVisible);
   if(visible && needsScroll)
   {
      SetObjVisible("Info_Ord_ScrollTrack", true);
      SetObjVisible("Info_Ord_ScrollThumb", true);
   }
   else
   {
      HideInfoOrdersScrollbar();
   }
   
   if(visible) 
   {
      UpdateInfoLayout();
      UpdateInfoPanel();
   }
}
