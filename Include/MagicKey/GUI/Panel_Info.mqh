//+------------------------------------------------------------------+
//|                                              Panel_Info.mqh      |
//|                                                MagicKey Project  |
//+------------------------------------------------------------------+
#property strict

// GLOBAL pour suivre le nombre d'ordres affichés
int g_LastInfoOrderCount = 0;

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
//| MISE A JOUR DU LAYOUT (POSITIONNEMENT)                           |
//+------------------------------------------------------------------+
void UpdateInfoLayout()
{
   int startX = InfoPanelX;
   int startY = InfoPanelY;
   int width  = 260; // Wider Panel for better spacing
   
   int paddingX = 20;
   int rowH     = 28; // Height of an order row
   int gapY     = 4;  // Gap between rows
   
   int currentY = startY + 50; 
   
   // --- HEAD & BG ---
   SetObjPosition("Info_Bg", startX, startY);
   SetObjPosition("Info_Header", startX, startY);
   SetObjPosition("Info_Title", startX + 15, startY + 12);
   
   ObjectSetInteger(0, PREFIX + "Info_Bg", OBJPROP_XSIZE, width);
   ObjectSetInteger(0, PREFIX + "Info_Header", OBJPROP_XSIZE, width);
   
   // --- ACCOUNT SECTION (GROUPED) ---
   int statsBgH = 245; // Height increased to fit 5 rows (Balance, Eq/Ma, Dep/Wit, P&L/Perf%, PerfR)
   
   SetObjPosition("Info_Stats_Bg", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Info_Stats_Bg", OBJPROP_XSIZE, width - (paddingX*2));
   ObjectSetInteger(0, PREFIX + "Info_Stats_Bg", OBJPROP_YSIZE, statsBgH);
   
   int statsDescX = startX + paddingX + 15;
   int statsTopY  = currentY + 10;
   
   // Balance (Row 1)
   SetObjPosition("Info_Lbl_Balance", statsDescX, statsTopY);
   SetObjPosition("Info_Val_Balance", statsDescX, statsTopY + 15);
   
   int row2Y = statsTopY + 45;
   int colW  = (width - (paddingX*2) - 30) / 2;
   
   // Equity (Left)
   SetObjPosition("Info_Lbl_Equity", statsDescX, row2Y);
   SetObjPosition("Info_Val_Equity", statsDescX, row2Y + 15);
   
   // Margin (Right)
   SetObjPosition("Info_Lbl_Margin", statsDescX + colW, row2Y);
   SetObjPosition("Info_Val_Margin", statsDescX + colW, row2Y + 15);
   
   // Deposit / Withdraw (Row 3)
   int row3Y = row2Y + 45;
   
   // Deposit (Left)
   SetObjPosition("Info_Lbl_Deposit", statsDescX, row3Y);
   SetObjPosition("Info_Val_Deposit", statsDescX, row3Y + 15);
   
   // Withdraw (Right)
   SetObjPosition("Info_Lbl_Withdraw", statsDescX + colW, row3Y);
   SetObjPosition("Info_Val_Withdraw", statsDescX + colW, row3Y + 15);
   
   currentY += statsBgH + 15;
   
   // --- SEPARATOR ---
   SetObjPosition("Info_Sep", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Info_Sep", OBJPROP_XSIZE, width - (paddingX*2));
   
   SetObjPosition("Info_Lbl_Withdraw", statsDescX + colW, row3Y);
   SetObjPosition("Info_Val_Withdraw", statsDescX + colW, row3Y + 15);
   
   // P&L & Perf % (Row 4)
   int row4Y = row3Y + 45;
   
   SetObjPosition("Info_Lbl_PnL", statsDescX, row4Y);
   SetObjPosition("Info_Val_PnL", statsDescX, row4Y + 15);
   
   SetObjPosition("Info_Lbl_PerfP", statsDescX + colW, row4Y);
   SetObjPosition("Info_Val_PerfP", statsDescX + colW, row4Y + 15);
   
   // Perf R (Row 5)
   int row5Y = row4Y + 45;
   SetObjPosition("Info_Lbl_PerfR", statsDescX, row5Y);
   SetObjPosition("Info_Val_PerfR", statsDescX, row5Y + 15);
   
   currentY += statsBgH + 15;
   
   // --- POSITIONS HEADER ---
   SetObjPosition("Info_SubTitle_Pos", startX + paddingX, currentY);
   currentY += 20;
   
   // --- POSITIONS LIST ---
   for(int i=0; i<g_LastInfoOrderCount; i++)
   {
      string suffix = "_" + IntegerToString(i);
      
      // Background Card
      SetObjPosition("Info_Ord_Bg" + suffix, startX + paddingX, currentY);
      ObjectSetInteger(0, PREFIX + "Info_Ord_Bg" + suffix, OBJPROP_XSIZE, width - (paddingX*2));
      ObjectSetInteger(0, PREFIX + "Info_Ord_Bg" + suffix, OBJPROP_YSIZE, rowH);
      
      // Symbol (Left)
      SetObjPosition("Info_Ord_Sym" + suffix, startX + paddingX + 8, currentY + 6);
      
      // Type (Right)
      // Note: Alignment is tricky without width calculation, so we manually position far right
      // Ideally we would right align, but simple positioning:
      SetObjPosition("Info_Ord_Typ" + suffix, startX + width - paddingX - 70, currentY + 7);
      
      currentY += rowH + gapY;
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
   CreateRect("Info_Header", 0, 0, width, 45, g_ColorHeader, BORDER_FLAT);
   CreateLabel("Info_Title", "Account Overview", 0, 0, 10, clrWhite, "Trebuchet MS Bold");
   
   // 2. Account Data
   CreateRect("Info_Stats_Bg", 0, 0, width - 40, 110, g_ColorInput, BORDER_FLAT); // Grouping Box
   ObjectSetInteger(0, PREFIX + "Info_Stats_Bg", OBJPROP_BORDER_COLOR, g_ColorInput);

   CreateLabel("Info_Lbl_Balance", "BALANCE", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Info_Val_Balance", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold"); // Reduced to 9
   
   CreateLabel("Info_Lbl_Equity", "EQUITY", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Info_Val_Equity", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Info_Lbl_Margin", "MARGIN", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Info_Val_Margin", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Info_Lbl_Deposit", "DEPOSIT", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Info_Val_Deposit", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Info_Lbl_Withdraw", "WITHDRAW", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Info_Val_Withdraw", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Info_Lbl_Withdraw", "WITHDRAW", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Info_Val_Withdraw", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Info_Lbl_PnL", "PROFIT & LOSS", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Info_Val_PnL", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Info_Lbl_PerfP", "PERFORMANCE (%)", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Info_Val_PerfP", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Info_Lbl_PerfR", "PERFORMANCE (R)", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Info_Val_PerfR", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   // 3. Separator Line
   CreateRect("Info_Sep", 0, 0, 100, 1, g_ColorHeader, BORDER_FLAT);
   
   // 4. SubHeader
   CreateLabel("Info_SubTitle_Pos", "Active Orders", 0, 0, 8, g_ColorLabel, "Trebuchet MS");
   
   UpdateInfoLayout();
   UpdateInfoPanel();
}

//+------------------------------------------------------------------+
//| MISE A JOUR DES VALEURS (TICK)                                   |
//+------------------------------------------------------------------+
void UpdateInfoPanel()
{
   if(!IsInfoPanelVisible) return;

   string currency = AccountCurrency();
   
   double bal = AccountBalance();
   double equ = AccountEquity();
   double marg = AccountFreeMargin();
   
   string sBal = DoubleToString(bal, 2) + " " + currency;
   string sEqu = DoubleToString(equ, 2) + " " + currency;
   string sMarg = DoubleToString(marg, 2) + " " + currency;
   
   ObjectSetString(0, PREFIX + "Info_Val_Balance", OBJPROP_TEXT, sBal);
   ObjectSetString(0, PREFIX + "Info_Val_Equity", OBJPROP_TEXT, sEqu);
   ObjectSetString(0, PREFIX + "Info_Val_Margin", OBJPROP_TEXT, sMarg);
   
   // --- DEPOSIT / WITHDRAW UPDATE ---
   double deps = 0, wits = 0;
   GetAccountHistoryStats(deps, wits);
   
   string sDeps = DoubleToString(deps, 2) + " " + currency;
   string sWits = DoubleToString(wits, 2) + " " + currency;
   
   ObjectSetString(0, PREFIX + "Info_Val_Deposit", OBJPROP_TEXT, sDeps);
   ObjectSetString(0, PREFIX + "Info_Val_Withdraw", OBJPROP_TEXT, sWits);
   
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
   
   string sPnL   = DoubleToString(pnl, 2) + " " + currency;
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
   int total = OrdersTotal();
   int visualIndex = 0;
   
   for(int i=0; i<total; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
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
   
   // Clean up stale objects (Bg + Sym + Typ)
   if(visualIndex < g_LastInfoOrderCount)
   {
      for(int k=visualIndex; k<g_LastInfoOrderCount; k++)
      {
         string suffix = "_" + IntegerToString(k);
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
   
   // Position Lines
   for(int i=0; i<g_LastInfoOrderCount; i++)
   {
      string suffix = "_" + IntegerToString(i);
      SetObjVisible("Info_Ord_Bg" + suffix, visible);
      SetObjVisible("Info_Ord_Sym" + suffix, visible);
      SetObjVisible("Info_Ord_Typ" + suffix, visible);
   }
   
   if(visible) UpdateInfoLayout();
}
