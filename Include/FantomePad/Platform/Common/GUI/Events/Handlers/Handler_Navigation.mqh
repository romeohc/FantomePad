//|                                              Handler_Navigation.mqh |
//+------------------------------------------------------------------+
#property strict

bool Handle_Navigation_Events(string sparam)
{
   // --- LICENSE REVOKED GUARD ---
   if(g_LicenseState == LICENSE_REVOKED)
   {
      // Block opening Main, Account, History or Settings
      if(sparam == PREFIX + "Nav_Btn_Main" || 
         sparam == PREFIX + "Nav_Btn_Account" || 
         sparam == PREFIX + "Nav_Btn_History" || 
         sparam == PREFIX + "Nav_Btn_Settings")
      {
         return true; // Ignore and block
      }
   }

   // --- NAVIGATION PANEL EVENTS ---
   
   // 1. Toggle Trade Panel
   if(sparam == PREFIX + "Nav_Btn_Main")
   {
      g_PanelMain.IsVisible = !g_PanelMain.IsVisible;
      ToggleMainPanel(g_PanelMain.IsVisible);
      UpdateNavigationPanel(); 
      return true;
   }
   
   // 2. Button Positions Panel (Toggle Positions)
   if(sparam == PREFIX + "Nav_Btn_Pos")
   {
      g_PanelPositions.IsVisible = !g_PanelPositions.IsVisible;
      TogglePositionsPanel(g_PanelPositions.IsVisible);
      UpdateNavigationPanel(); 
      return true;
   }

   // 3. Toggle Account Panel
   if(sparam == PREFIX + "Nav_Btn_Account")
   {
      g_PanelAccount.IsVisible = !g_PanelAccount.IsVisible;
      ToggleAccountPanel(g_PanelAccount.IsVisible);
      UpdateNavigationPanel(); 
      return true;
   }
   
   // 3.5 History Panel
   if(sparam == PREFIX + "Nav_Btn_History")
    {
       g_PanelHistory.IsVisible = !g_PanelHistory.IsVisible;
       ToggleHistoryPanel(g_PanelHistory.IsVisible);
       UpdateNavigationPanel(); 
       return true;
    }
   
   // 3. Toggle Settings (Shortcut)
   if(sparam == PREFIX + "Nav_Btn_Settings")
   {
      ToggleSettings();
      UpdateNavigationPanel(); 
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
       long ticket = -1;
       if(visualIdx >= 0 && visualIdx < ArraySize(g_AccountOrdersTickets))
       {
          ticket = g_AccountOrdersTickets[visualIdx];
       }
       
       if(ticket > 0 && OrderSelect(ticket, SELECT_BY_TICKET))
       {
          string symbol = OrderSymbol();
          
          // 1. Select this order in Position Panel
          SelectedPositionTicket = ticket;
          
          // 2. Open Position Panel if not already visible
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
             // Save ticket to global variable (Splitting 64-bit long into 2 doubles to avoid precision loss on large tickets)
             // Also using ChartID to prevent conflicts between multiple charts
             string gvName = "FantomePad_Selected_" + IntegerToString(ChartID());
             
             uint lo = (uint)(ticket & 0xFFFFFFFF);
             uint hi = (uint)(ticket >> 32);
             
             GlobalVariableSet(gvName + "_Hi", (double)hi);
             GlobalVariableSet(gvName + "_Lo", (double)lo);
             GlobalVariableSet(gvName + "_Flag", 1.0); // Flag to indicate valid save
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
