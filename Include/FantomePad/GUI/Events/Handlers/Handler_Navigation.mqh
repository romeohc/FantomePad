//|                                              Handler_Navigation.mqh |
//+------------------------------------------------------------------+
#property strict

bool Handle_Navigation_Events(string sparam)
{
   // --- NAVIGATION PANEL EVENTS ---
   
   // 1. Toggle Trading Panel
   if(sparam == PREFIX + "Nav_Btn_Main")
   {
      g_PanelMain.IsVisible = !g_PanelMain.IsVisible;
      ToggleMainPanel(g_PanelMain.IsVisible);
      UpdateNavigationPanel(); 
      EffectButton(sparam);
      SaveConfigToFile();
      return true;
   }
   
   // 2. Button Positions Panel (Toggle Positions)
   if(sparam == PREFIX + "Nav_Btn_Pos")
   {
      g_PanelPositions.IsVisible = !g_PanelPositions.IsVisible;
      TogglePositionsPanel(g_PanelPositions.IsVisible);
      UpdateNavigationPanel(); 
      EffectButton(sparam);
      SaveConfigToFile();
      return true;
   }

   // 3. Toggle Account Panel
   if(sparam == PREFIX + "Nav_Btn_Account")
   {
      g_PanelAccount.IsVisible = !g_PanelAccount.IsVisible;
      ToggleAccountPanel(g_PanelAccount.IsVisible);
      UpdateNavigationPanel(); 
      EffectButton(sparam);
      SaveConfigToFile();
      return true;
   }
   
   // 3.5 History Panel
   if(sparam == PREFIX + "Nav_Btn_History")
    {
       g_PanelHistory.IsVisible = !g_PanelHistory.IsVisible;
       ToggleHistoryPanel(g_PanelHistory.IsVisible);
       UpdateNavigationPanel(); 
       EffectButton(sparam);
       SaveConfigToFile();
       return true;
    }
   
   // 3. Toggle Settings (Shortcut)
   if(sparam == PREFIX + "Nav_Btn_Settings")
   {
      ToggleSettings();
      UpdateNavigationPanel(); // Refresh button state
      EffectButton(sparam);
      SaveConfigToFile();
      return true;
   }
 
   // --- CLICK ON ACTIVE ORDER (ACCOUNT PANEL) ---
   if(StringFind(sparam, PREFIX + "Account_Ord_") >= 0)
   {
       // Extract visual index from object name
       // Pattern: PTP_Account_Ord_Bg_X or PTP_Account_Ord_Sym_X or PTP_Account_Ord_Typ_X
       int visualIdx = -1;
       
       // Find the underscore before the index
       int lastUnder = -1;
       for(int c = StringLen(sparam) - 1; c >= 0; c--)
       {
          if(StringGetCharacter(sparam, c) == '_')
          {
             lastUnder = c;
             break;
          }
       }
       
       if(lastUnder > 0)
       {
          string idxStr = StringSubstr(sparam, lastUnder + 1);
          visualIdx = (int)StringToInteger(idxStr);
       }
       
       // Get ticket from global array
       int ticket = -1;
       if(visualIdx >= 0 && visualIdx < ArraySize(g_AccountOrdersTickets))
       {
          ticket = g_AccountOrdersTickets[visualIdx];
       }
       
       if(ticket > 0 && OrderSelect(ticket, SELECT_BY_TICKET))
       {
          string symbol = OrderSymbol();
          
          // 1. Select this order in Position Navigation
          SelectedPositionTicket = ticket;
          
          // 2. Open Position Navigation if not already visible
          if(!g_PanelPositions.IsVisible)
          {
             g_PanelPositions.IsVisible = true;
             TogglePositionsPanel(true);
             UpdateNavigationPanel(); // Update Navigation Panel button states
             SaveConfigToFile();
          }
          else
          {
             // Just update the values since we changed the selected ticket
             UpdatePositionsValues();
          }
          
          // 3. Switch Chart if different symbol
          if(symbol != "" && symbol != Symbol())
          {
             // Save ticket to global variable so it persists after EA reload
             GlobalVariableSet("FantomePad_LastSelectedTicket", (double)ticket);
             ChartSetSymbolPeriod(0, symbol, Period());
             // Note: Changing symbol triggers EA reload
          }
           else
           {
              // Same symbol: Update lines immediately (INSTANT UX)
              UpdateOpenOrderLines();
              ChartRedraw();
           }
       }
       
       return true;
   }

   return false;
}
