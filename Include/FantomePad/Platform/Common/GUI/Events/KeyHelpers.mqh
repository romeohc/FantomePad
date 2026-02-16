//+------------------------------------------------------------------+
//|                                                   KeyHelpers.mqh |
//|                                              FantomePad Project  |
//|                                    Keyboard Event Helper Functions|
//+------------------------------------------------------------------+
#ifndef _KEY_HELPERS_MQH_
#define _KEY_HELPERS_MQH_
#property strict

// --- HELPER FUNCTIONS FOR KEYBOARD EVENTS ---

//+------------------------------------------------------------------+
//| HELPER: Ensure Trade Panel is open and Position is closed        |
//+------------------------------------------------------------------+
void EnsureTradePanel()
{
   if(g_LicenseState == LICENSE_REVOKED) return; // Guard: Block opening Trade panel via PAD
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
   if(g_LicenseState == LICENSE_REVOKED) return; // Guard
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
   if(g_LicenseState == LICENSE_REVOKED) return; // Guard
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
   ObjectSetString(0, PREFIX + "Nav_Btn_SymbolSelect", OBJPROP_TEXT, sym);
   ChartSetSymbolPeriod(0, sym, Period());
   
   CloseSymbolList();
   UpdateCalculatedLot();
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| HELPER: SELECT NEXT POSITION                                    |
//+------------------------------------------------------------------+
void SelectNextPosition()
{
   long tickets[];
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
   // --- LICENSE REVOKED GUARD ---
   // Force validation to stick to Positions panel if revoked
   if(g_LicenseState == LICENSE_REVOKED)
   {
       if(g_PanelPositions.IsVisible && SelectedPositionTicket != -1)
          Handle_PositionActions_Events(PREFIX + "Pos_Btn_Validate");
       return;
   }

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
   // --- LICENSE REVOKED GUARD ---
   if(g_LicenseState == LICENSE_REVOKED) return; // Don't allow closing things or clearing selection

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

#endif
