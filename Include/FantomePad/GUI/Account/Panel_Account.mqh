//+------------------------------------------------------------------+
//|                                              Panel_Account.mqh      |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

// Modular Includes
#include "Account_Globals.mqh"
#include "Account_Helpers.mqh"
#include "Account_Layout.mqh"

//+------------------------------------------------------------------+
//| CRÉATION DES OBJETS                                              |
//+------------------------------------------------------------------+
void CreateAccountPanel()
{
   int width = 260;
   
   // 1. Fond & Header
   CreateRect("Account_Bg", 0, 0, width, 100, g_ColorBg, BORDER_FLAT); 
   CreateRect("Account_Header", 0, 0, width, 45, g_ColorBg, BORDER_FLAT);
   string accountName = AccountInfoString(ACCOUNT_NAME);
   if(accountName == "") accountName = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   
   // Truncate if too long (max ~25 chars for header)
   string displayTitle = TruncateString(accountName, 25);
   CreateLabel("Account_Title", displayTitle, 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   // 2. Account Data
   CreateRect("Account_Stats_Bg", 0, 0, width - 40, 110, g_ColorInput, BORDER_FLAT); // Grouping Box
   ObjectSetInteger(0, PREFIX + "Account_Stats_Bg", OBJPROP_BORDER_COLOR, g_ColorInput);
 
   CreateLabel("Account_Lbl_Balance", "BALANCE", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Account_Val_Balance", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold"); // Reduced to 9
   
   CreateLabel("Account_Lbl_Equity", "EQUITY", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Account_Val_Equity", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Account_Lbl_Margin", "MARGIN", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Account_Val_Margin", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Account_Lbl_Deposit", "DEPOSIT", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Account_Val_Deposit", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Account_Lbl_Withdraw", "WITHDRAW", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Account_Val_Withdraw", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Account_Lbl_PnL", "PNL", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Account_Val_PnL", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Account_Lbl_PerfP", "ROI", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Account_Val_PerfP", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Account_Lbl_PerfR", "ROI", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Account_Val_PerfR", "...", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   // 3. Separator Line
   CreateRect("Account_Sep", 0, 0, 100, 1, C'50,50,50', BORDER_FLAT);
   
   // 4. SubHeader
   CreateLabel("Account_SubTitle_Pos", "Active Orders", 0, 0, 8, g_ColorText, "Trebuchet MS Bold");
   
   // 5. No Orders Message
   CreateLabel("Account_NoOrd_Msg", "No active orders", 0, 0, 8, g_ColorText, "Trebuchet MS");
   
   UpdateAccountLayout();
   UpdateAccountPanel();
}

//+------------------------------------------------------------------+
//| MISE A JOUR DES VALEURS (TICK)                                   |
//+------------------------------------------------------------------+
void UpdateAccountPanel()
{
   if(!g_PanelAccount.IsVisible) return;
 
   string currency = AccountCurrency();
   
   double bal = AccountBalance();
   double equ = AccountEquity();
   double marg = AccountFreeMargin();
   
   string sBal = DoubleToString(bal, 2);
   string sEqu = DoubleToString(equ, 2);
   string sMarg = DoubleToString(marg, 2);
   
   ObjectSetString(0, PREFIX + "Account_Val_Balance", OBJPROP_TEXT, sBal);
   ObjectSetString(0, PREFIX + "Account_Val_Equity", OBJPROP_TEXT, sEqu);
   ObjectSetString(0, PREFIX + "Account_Val_Margin", OBJPROP_TEXT, sMarg);
   
   // --- DEPOSIT / WITHDRAW UPDATE ---
   double deps = 0, wits = 0, netProfitFromHistory = 0;
   
   // NOTE: Effective MT4 history is limited by the "Account History" tab settings in the terminal.
   // If "All History" is not selected, the calculations below will only reflect the VISIBLE history.
   GetAccountHistoryStats(deps, wits, netProfitFromHistory);
   
   // If no deposit record (OP_BALANCE) is found in the visible history, 
   // we estimate the starting point based on closed trades.
   if(deps <= 0) deps = (bal - netProfitFromHistory + wits); 
   
   string sDeps = DoubleToString(deps, 2);
   string sWits = DoubleToString(wits, 2);
   
   ObjectSetString(0, PREFIX + "Account_Val_Deposit", OBJPROP_TEXT, sDeps);
   ObjectSetString(0, PREFIX + "Account_Val_Withdraw", OBJPROP_TEXT, sWits);
   
   // --- CALCUL P&L et PERF ---
   // P&L is simply the sum of all visible trades in history
   double pnl = netProfitFromHistory;
   
   // If we found OP_BALANCE records, use the official P&L formula
   if(deps > 0 && deps != (bal - netProfitFromHistory + wits)) 
      pnl = bal - (deps - wits);
   
   // Perf % = (P&L / Starting balance) * 100 
   double perfP = (deps > 0) ? (pnl / deps) * 100.0 : 0.0;
   
   // Perf R = Total % / 1R_Value
   double perfR = (g_OneRPercent > 0) ? perfP / g_OneRPercent : 0.0;
   
   string sPnL   = (pnl >= 0 ? "+" : "") + DoubleToString(pnl, 2) + " " + currency;
   string sPerfP = (perfP >= 0 ? "+" : "") + DoubleToString(perfP, 2) + " %";
   string sPerfR = (perfR >= 0 ? "+" : "") + DoubleToString(perfR, 2) + " R";
   
   ObjectSetString(0, PREFIX + "Account_Val_PnL", OBJPROP_TEXT, sPnL);
   ObjectSetInteger(0, PREFIX + "Account_Val_PnL", OBJPROP_COLOR, (pnl >= 0) ? g_ColorPositive : g_ColorNegative);
   
   ObjectSetString(0, PREFIX + "Account_Val_PerfP", OBJPROP_TEXT, sPerfP);
   ObjectSetInteger(0, PREFIX + "Account_Val_PerfP", OBJPROP_COLOR, (perfP >= 0) ? g_ColorPositive : g_ColorNegative);
   
   ObjectSetString(0, PREFIX + "Account_Val_PerfR", OBJPROP_TEXT, sPerfR);
   ObjectSetInteger(0, PREFIX + "Account_Val_PerfR", OBJPROP_COLOR, (perfR >= 0) ? g_ColorPositive : g_ColorNegative);
   
   // Ensure colors are consistent if they were changed elsewhere
   ObjectSetInteger(0, PREFIX + "Account_Val_Balance", OBJPROP_COLOR, g_ColorText);
   
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
   
   g_TotalAccountOrderCount = orderCount;
   
   // Clamp scroll offset
   bool needsScroll = (orderCount > g_AccountOrdersMaxVisible);
   if(needsScroll)
   {
      int maxOffset = orderCount - g_AccountOrdersMaxVisible;
      if(g_AccountOrdersScrollOffset > maxOffset) g_AccountOrdersScrollOffset = maxOffset;
      if(g_AccountOrdersScrollOffset < 0) g_AccountOrdersScrollOffset = 0;
   }
   else
   {
      g_AccountOrdersScrollOffset = 0;
   }
   
   // Calculate visible range
   int visibleStart = g_AccountOrdersScrollOffset;
   int visibleEnd = needsScroll ? (g_AccountOrdersScrollOffset + g_AccountOrdersMaxVisible) : orderCount;
   if(visibleEnd > orderCount) visibleEnd = orderCount;
   
   // Prepare global tickets array for click handling
   int visibleCount = visibleEnd - visibleStart;
   ArrayResize(g_AccountOrdersTickets, visibleCount);
   
   int visualIndex = 0;
   
   for(int j=visibleStart; j<visibleEnd; j++)
   {
      int tck = tickets[j];
      
      // Store ticket in global array for click identification
      if(visualIndex < visibleCount)
         g_AccountOrdersTickets[visualIndex] = tck;
      
      if(OrderSelect(tck, SELECT_BY_TICKET))
      {
         // DATA
         string typeStr = GetOrderTypeStrShort(OrderType());
         string symbol  = OrderSymbol();
         color typeColor = (OrderType() % 2 == 0) ? g_ColorPositive : g_ColorNegative;
         
         string suffix = "_" + IntegerToString(visualIndex);
         
         // 1. Background Card
         string nameBg = "Account_Ord_Bg" + suffix;
         if(ObjectFind(0, PREFIX + nameBg) < 0) CreateRect(nameBg, 0, 0, 10, 10, g_ColorInput, BORDER_FLAT); 
         SetObjVisible(nameBg, true);
 
         // 2. Symbol Label
         string nameSym = "Account_Ord_Sym" + suffix;
         if(ObjectFind(0, PREFIX + nameSym) < 0) CreateLabel(nameSym, symbol, 0, 0, 9, clrWhite, "Trebuchet MS Bold");
         ObjectSetString(0, PREFIX + nameSym, OBJPROP_TEXT, symbol);
         SetObjVisible(nameSym, true);
         
         // 3. Type Label
         string nameTyp = "Account_Ord_Typ" + suffix;
         if(ObjectFind(0, PREFIX + nameTyp) < 0) CreateLabel(nameTyp, typeStr, 0, 0, 8, typeColor, "Trebuchet MS");
         ObjectSetString(0, PREFIX + nameTyp, OBJPROP_TEXT, typeStr);
         ObjectSetInteger(0, PREFIX + nameTyp, OBJPROP_COLOR, typeColor);
         SetObjVisible(nameTyp, true);
         
         visualIndex++;
      }
   }
   
   // Handle "No active orders" visibility
   if(orderCount == 0) SetObjVisible("Account_NoOrd_Msg", true);
   else                SetObjVisible("Account_NoOrd_Msg", false);
   
   // Clean up stale objects
   int prevDisplayed = g_LastAccountOrderCount;
   for(int k=visualIndex; k<prevDisplayed; k++)
   {
      string suffix = "_" + IntegerToString(k);
      SetObjVisible("Account_Ord_Bg" + suffix, false);
      SetObjVisible("Account_Ord_Sym" + suffix, false);
      SetObjVisible("Account_Ord_Typ" + suffix, false);
   }
   
   // Delete objects for items way beyond current total
   int maxKept = MathMax(g_AccountOrdersMaxVisible, prevDisplayed);
   for(int k=maxKept; k<prevDisplayed + 10; k++)
   {
      string suffix = "_" + IntegerToString(k);
      if(ObjectFind(0, PREFIX + "Account_Ord_Bg" + suffix) >= 0)
      {
         ObjectDelete(0, PREFIX + "Account_Ord_Bg" + suffix);
         ObjectDelete(0, PREFIX + "Account_Ord_Sym" + suffix);
         ObjectDelete(0, PREFIX + "Account_Ord_Typ" + suffix);
      }
   }
   
   g_LastAccountOrderCount = visualIndex;
   UpdateAccountLayout();
}

//+------------------------------------------------------------------+
//| VISIBILITY CONTROL                                               |
//+------------------------------------------------------------------+
void ToggleAccountPanel(bool visible)
{
   g_PanelAccount.IsVisible = visible;
   SetObjVisible("Account_Bg", visible);
   SetObjVisible("Account_Header", visible);
   SetObjVisible("Account_Title", visible);
   
   SetObjVisible("Account_Stats_Bg", visible); 
   SetObjVisible("Account_Lbl_Balance", visible);
   SetObjVisible("Account_Val_Balance", visible);
   SetObjVisible("Account_Lbl_Equity", visible);
   SetObjVisible("Account_Val_Equity", visible);
   SetObjVisible("Account_Lbl_Margin", visible);
   SetObjVisible("Account_Val_Margin", visible);
   SetObjVisible("Account_Lbl_Deposit", visible);
   SetObjVisible("Account_Val_Deposit", visible);
   SetObjVisible("Account_Lbl_Withdraw", visible);
   SetObjVisible("Account_Val_Withdraw", visible);
   
   SetObjVisible("Account_Lbl_PnL", visible);
   SetObjVisible("Account_Val_PnL", visible);
   SetObjVisible("Account_Lbl_PerfP", visible);
   SetObjVisible("Account_Val_PerfP", visible);
   SetObjVisible("Account_Lbl_PerfR", visible);
   SetObjVisible("Account_Val_PerfR", visible);
   
   SetObjVisible("Account_Sep", visible);
   SetObjVisible("Account_SubTitle_Pos", visible);
   
   if(visible && g_TotalAccountOrderCount == 0) SetObjVisible("Account_NoOrd_Msg", true);
   else                                         SetObjVisible("Account_NoOrd_Msg", false);
   
   int visibleCount = (g_TotalAccountOrderCount > g_AccountOrdersMaxVisible) ? g_AccountOrdersMaxVisible : g_TotalAccountOrderCount;
   for(int i=0; i<visibleCount; i++)
   {
      string suffix = "_" + IntegerToString(i);
      SetObjVisible("Account_Ord_Bg" + suffix, visible);
      SetObjVisible("Account_Ord_Sym" + suffix, visible);
      SetObjVisible("Account_Ord_Typ" + suffix, visible);
   }
   
   bool needsScroll = (g_TotalAccountOrderCount > g_AccountOrdersMaxVisible);
   if(visible && needsScroll)
   {
      SetObjVisible("Account_Ord_ScrollTrack", true);
      SetObjVisible("Account_Ord_ScrollThumb", true);
   }
   else
   {
      HideAccountOrdersScrollbar();
   }
   
   if(visible) 
   {
      UpdateAccountLayout();
      UpdateAccountPanel();
   }
}

