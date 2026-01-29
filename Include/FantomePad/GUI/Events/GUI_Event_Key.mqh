//+------------------------------------------------------------------+
//|                                               GUI_Event_Key.mqh  |
//+------------------------------------------------------------------+
#property strict

// --- Sequence Config ---
#define SEQ_COUNT 5        // 5 keys sequence for maximum security
#define SEQ_TIMEOUT_MS 200 // Total sequence must be sent under 200ms (Impossible for humans)

//+------------------------------------------------------------------+
//| HELPER: Ensure Trade Panel is open and Position is closed        |
//+------------------------------------------------------------------+
void EnsureTradePanel()
{
   if(!g_PanelMain.IsVisible) { g_PanelMain.IsVisible = true; ToggleMainPanel(true); }
   if(g_PanelPositions.IsVisible) { g_PanelPositions.IsVisible = false; TogglePositionsPanel(false); }
}

//+------------------------------------------------------------------+
//| HELPER: Ensure Position Panel is open and Trade is closed        |
//+------------------------------------------------------------------+
void EnsurePositionPanel()
{
   if(!g_PanelPositions.IsVisible) { g_PanelPositions.IsVisible = true; TogglePositionsPanel(true); }
   if(g_PanelMain.IsVisible) { g_PanelMain.IsVisible = false; ToggleMainPanel(false); }
}

//+------------------------------------------------------------------+
//| HELPER: Adjust Risk (Used by Wheel)                             |
//+------------------------------------------------------------------+
void AdjustRisk(double direction) // direction: 1 for right, -1 for left
{
   EnsureTradePanel();
   string editName = PREFIX + "Edit_Risk";
   double currentRisk = StringToDouble(ObjectGetString(0, editName, OBJPROP_TEXT));
   
   double step = 0.1;
   if(RiskMode == 1) step = 100.0; // Monetary mode increment by 100
   
   double delta = direction * step;
   double newRisk = currentRisk + delta;
   if(newRisk < 0) newRisk = 0;
   
   // Formattage intelligent : pas de décimale si monétaire (>0)
   string riskStr = (RiskMode == 1) ? DoubleToString(newRisk, 0) : DoubleToString(newRisk, 1);
   
   ObjectSetString(0, editName, OBJPROP_TEXT, riskStr);
   UpdateCalculatedLot();
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| HELPER: Reset Risk (Used by Wheel Click)                        |
//+------------------------------------------------------------------+
void ResetRisk()
{
   EnsureTradePanel();
   ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, "0.0");
   UpdateCalculatedLot();
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| HELPER: Navigate Symbol List (Second Wheel)                     |
//+------------------------------------------------------------------+
void NavigateSymbols(int direction)
{
   if(!IsListOpen) 
   {
      IsListOpen = true;
      g_SymbolHoverIndex = 0;
   }
   else
   {
      int total = SymbolsTotal(true);
      g_SymbolHoverIndex += direction;
      
      if(g_SymbolHoverIndex >= total) g_SymbolHoverIndex = 0;
      if(g_SymbolHoverIndex < 0) g_SymbolHoverIndex = total - 1;
   }
   
   // Adjust offset to keep hover visible
   if(g_SymbolHoverIndex < g_SymbolListOffset) 
      g_SymbolListOffset = g_SymbolHoverIndex;
   if(g_SymbolHoverIndex >= g_SymbolListOffset + g_SymbolListMaxVisible)
      g_SymbolListOffset = g_SymbolHoverIndex - g_SymbolListMaxVisible + 1;
      
   DrawSymbolList();
}

//+------------------------------------------------------------------+
//| HELPER: Select Hovered Symbol (Second Wheel Click)              |
//+------------------------------------------------------------------+
void SelectSymbol()
{
   if(!IsListOpen || g_SymbolHoverIndex < 0) return;
   
   string sym = SymbolName(g_SymbolHoverIndex, true);
   
   // Execute selection logic
   ObjectSetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT, sym);
   ChartSetSymbolPeriod(0, sym, Period());
   
   CloseSymbolList();
   UpdateCalculatedLot();
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| EVENT: KEY DOWN                                                  |
//+------------------------------------------------------------------+
void OnEvent_Key(long lparam)
{
   static int seq[SEQ_COUNT] = {-1, -1, -1, -1, -1};
   static uint lastKeyTime = 0;
   
   // 1. Filter Numpad Digits Only (0-9)
   int digit = -1;
   if(lparam >= 96 && lparam <= 105) digit = (int)lparam - 96;
   // Fallback System codes (NumLock Off)
   else if(lparam == 45) digit = 0;
   else if(lparam == 35) digit = 1;
   else if(lparam == 40) digit = 2;
   else if(lparam == 34) digit = 3;
   else if(lparam == 37) digit = 4;
   else if(lparam == 12) digit = 5;
   else if(lparam == 39) digit = 6;
   else if(lparam == 36) digit = 7;
   else if(lparam == 38) digit = 8;
   else if(lparam == 33) digit = 9;
   
   if(digit == -1) return; // Not a numpad digit
   
   // 2. Manage Sequence Timing
   uint currentTime = GetTickCount();
   
   // If the gap between ANY two keys is too large (> 150ms per key) 
   // or if the whole sequence is too slow, we reset.
   if(currentTime - lastKeyTime > 150)
   {
      for(int i=0; i<SEQ_COUNT; i++) seq[i] = -1;
   }
   
   // 3. Update Sequence (Shift Left)
   for(int i=0; i<SEQ_COUNT-1; i++) seq[i] = seq[i+1];
   seq[SEQ_COUNT-1] = digit;
   lastKeyTime = currentTime;
   
   // 4. Match Sequence to Command
   if(seq[0] == -1) return;
   
   // Convert to long code: 91911
   long cmdCode = 0;
   long multiplier = 1;
   for(int i=SEQ_COUNT-1; i>=0; i--)
   {
      cmdCode += seq[i] * multiplier;
      multiplier *= 10;
   }
   
   bool changed = false;
   bool forceUIRefresh = false;
   bool executed = false;

   // --- SECURITY COMMAND MAPPING (9191X & 8282X) ---
   
   if(cmdCode == 91911) // BUY
   {
      EnsureTradePanel();
      CurrentTypeIndex = 0; CurrentDirection = 0;
      changed = true; executed = true;
   }
   else if(cmdCode == 91912) // SELL
   {
      EnsureTradePanel();
      CurrentTypeIndex = 0; CurrentDirection = 1;
      changed = true; executed = true;
   }
   else if(cmdCode == 91913) // LIMIT
   {
      EnsureTradePanel();
      if(CurrentDirection == 0) CurrentTypeIndex = 1; else CurrentTypeIndex = 2;
      changed = true; executed = true;
   }
   else if(cmdCode == 91914) // STOP
   {
      EnsureTradePanel();
      if(CurrentDirection == 0) CurrentTypeIndex = 3; else CurrentTypeIndex = 4;
      changed = true; executed = true;
   }
   else if(cmdCode == 91915) // RISK BUTTON (Toggle Mode)
   {
      EnsureTradePanel();
      RiskMode++; if(RiskMode > 2) RiskMode = 0;
      
      // Reset risk value on switch to avoid carrying over large numbers (e.g. 500$ -> 500%)
      string resetVal = (RiskMode == 1) ? "0" : "0.0";
      ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, resetVal);
      
      changed = true; executed = true;
   }
   else if(cmdCode == 91916) // BE
   {
      EnsurePositionPanel();
      Handle_PositionActions_Events(PREFIX + "Pos_Btn_BE");
      forceUIRefresh = true; executed = true;
   }
   else if(cmdCode == 91917) // 25%
   {
      EnsurePositionPanel();
      Handle_PositionActions_Events(PREFIX + "Pos_Btn_25");
      forceUIRefresh = true; executed = true;
   }
   else if(cmdCode == 91918) // 50%
   {
      EnsurePositionPanel();
      Handle_PositionActions_Events(PREFIX + "Pos_Btn_50");
      forceUIRefresh = true; executed = true;
   }
   else if(cmdCode == 91919) // 100%
   {
      EnsurePositionPanel();
      Handle_PositionActions_Events(PREFIX + "Pos_Btn_100");
      forceUIRefresh = true; executed = true;
   }
   else if(cmdCode == 82821) // NEXT
   {
      EnsurePositionPanel();
      SelectNextPosition();
      forceUIRefresh = true; executed = true;
   }
   else if(cmdCode == 82822) // VALIDATE
   {
      ExecuteGlobalValidate();
      executed = true;
   }
   else if(cmdCode == 82820) // CANCEL
   {
      ExecuteGlobalCancel();
      forceUIRefresh = true; executed = true;
   }
   
   // --- WHEEL COMMANDS ---
   else if(cmdCode == 77771) // WHEEL RIGHT (Increase Risk)
   {
      AdjustRisk(1.0);
      executed = true;
   }
   else if(cmdCode == 77772) // WHEEL LEFT (Decrease Risk)
   {
      AdjustRisk(-1.0);
      executed = true;
   }
   else if(cmdCode == 77770) // WHEEL CLICK (Reset Risk)
   {
      ResetRisk();
      executed = true;
   }
   
   // --- SECOND WHEEL COMMANDS (Symbols) ---
   else if(cmdCode == 66661) // WHEEL RIGHT (Next Symbol)
   {
      NavigateSymbols(1);
      executed = true;
   }
   else if(cmdCode == 66662) // WHEEL LEFT (Prev Symbol)
   {
      NavigateSymbols(-1);
      executed = true;
   }
   else if(cmdCode == 66660) // WHEEL CLICK (Select Symbol)
   {
      SelectSymbol();
      executed = true;
   }

   if(executed)
   {
      for(int i=0; i<SEQ_COUNT; i++) seq[i] = -1;
      
      if(changed) 
      {
         UpdateUIMode();
         UpdateCalculatedLot();
      }
      UpdateNavigationPanel();
      ChartRedraw();
   }
}

//+------------------------------------------------------------------+
//| HELPER: SELECT NEXT POSITION                                    |
//+------------------------------------------------------------------+
void SelectNextPosition()
{
   int tickets[];
   int count = 0;
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         int type = OrderType();
         if(type <= 5) // All trade types
         {
            ArrayResize(tickets, count+1);
            tickets[count] = OrderTicket();
            count++;
         }
      }
   }
   
   if(count == 0)
   {
      SelectedPositionTicket = -1;
      if(g_PanelPositions.IsVisible) UpdatePositionsValues();
      return;
   }
   
   int currentIdx = -1;
   for(int i=0; i<count; i++)
   {
      if(tickets[i] == SelectedPositionTicket) { currentIdx = i; break; }
   }
   
   // Move to next (or first if none selected)
   int nextIdx = (currentIdx + 1) % count;
   SelectedPositionTicket = tickets[nextIdx];
   
   // Ensure Position Panel is visible if we are navigating
   if(!g_PanelPositions.IsVisible) 
   {
      g_PanelPositions.IsVisible = true;
      TogglePositionsPanel(true);
      UpdateNavigationPanel();
   }
   
   // Auto-switch chart if needed
   if(OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
   {
      if(OrderSymbol() != Symbol())
      {
         GlobalVariableSet("FantomePad_LastSelectedTicket", (double)SelectedPositionTicket);
         ChartSetSymbolPeriod(0, OrderSymbol(), Period());
      }
      else
      {
         UpdateOpenOrderLines();
         UpdatePositionsValues();
      }
   }
}

//+------------------------------------------------------------------+
//| HELPER: EXECUTE GLOBAL VALIDATE                                 |
//+------------------------------------------------------------------+
void ExecuteGlobalValidate()
{
   // Priority 1: Trade Panel (if Market and focused/visible)
   if(g_PanelMain.IsVisible)
   {
      if(CurrentTypeIndex == 0) // Market
      {
         if(CurrentDirection == 0) Handle_Trading_Events(PREFIX + "Btn_Buy");
         else                      Handle_Trading_Events(PREFIX + "Btn_Sell");
      }
      else // Pending
      {
         Handle_Trading_Events(PREFIX + "Btn_Action");
      }
      return;
   }
   
   // Priority 2: Position Panel
   if(g_PanelPositions.IsVisible && SelectedPositionTicket != -1)
   {
      Handle_PositionActions_Events(PREFIX + "Pos_Btn_Validate");
      return;
   }
}

//+------------------------------------------------------------------+
//| HELPER: EXECUTE GLOBAL CANCEL / CLOSE                           |
//+------------------------------------------------------------------+
void ExecuteGlobalCancel()
{
   // Close Settings if open
   if(g_PanelSettings.IsVisible)
   {
      ToggleSettings();
      return;
   }
   
   // Close Trade Panel if visible
   if(g_PanelMain.IsVisible)
   {
      g_PanelMain.IsVisible = false;
      ToggleMainPanel(false);
      return;
   }
   
   // Close Positions Panel if visible
   if(g_PanelPositions.IsVisible)
   {
      g_PanelPositions.IsVisible = false;
      TogglePositionsPanel(false);
      return;
   }
   
   // Close History Panel
   if(g_PanelHistory.IsVisible)
   {
      g_PanelHistory.IsVisible = false;
      ToggleHistoryPanel(false);
      return;
   }

   // Reset selection if nothing else to close
   SelectedPositionTicket = -1;
   UpdatePositionsValues();
}

