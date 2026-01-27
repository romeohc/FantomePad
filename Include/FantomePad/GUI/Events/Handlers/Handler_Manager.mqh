//+------------------------------------------------------------------+
//|                                              Handler_Manager.mqh |
//+------------------------------------------------------------------+
#property strict

bool Handle_Manager_Events(string sparam)
{
   // --- MANAGER PANEL EVENTS ---
   
   // 1. Toggle Trading Panel
   if(sparam == PREFIX + "Mgr_Btn_Main")
   {
      g_PanelMain.IsVisible = !g_PanelMain.IsVisible;
      ToggleMainPanel(g_PanelMain.IsVisible);
      UpdateManagerPanel(); 
      EffectButton(sparam);
      SaveConfigToFile();
      return true;
   }
   
   // 2. Button Positions Panel (Toggle Positions)
   if(sparam == PREFIX + "Mgr_Btn_Pos")
   {
      g_PanelPositions.IsVisible = !g_PanelPositions.IsVisible;
      TogglePositionsPanel(g_PanelPositions.IsVisible);
      UpdateManagerPanel(); 
      EffectButton(sparam);
      SaveConfigToFile();
      return true;
   }

   // 3. Toggle Info Panel
   if(sparam == PREFIX + "Mgr_Btn_Info")
   {
      g_PanelInfo.IsVisible = !g_PanelInfo.IsVisible;
      ToggleInfoPanel(g_PanelInfo.IsVisible);
      UpdateManagerPanel(); 
      EffectButton(sparam);
      SaveConfigToFile();
      return true;
   }
   
   // 3.5 History Panel
   if(sparam == PREFIX + "Mgr_Btn_History")
    {
       g_PanelHistory.IsVisible = !g_PanelHistory.IsVisible;
       ToggleHistoryPanel(g_PanelHistory.IsVisible);
       UpdateManagerPanel(); 
       EffectButton(sparam);
       SaveConfigToFile();
       return true;
    }
   
   // 3. Toggle Settings (Shortcut)
   if(sparam == PREFIX + "Mgr_Btn_Settings")
   {
      ToggleSettings();
      UpdateManagerPanel(); // Refresh button state
      EffectButton(sparam);
      SaveConfigToFile();
      return true;
   }

   // --- CLICK ON ACTIVE ORDER (INFO PANEL) ---
   if(StringFind(sparam, PREFIX + "Info_Ord_") >= 0)
   {
       // Extract visual index from object name
       // Pattern: PTP_Info_Ord_Bg_X or PTP_Info_Ord_Sym_X or PTP_Info_Ord_Typ_X
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
       if(visualIdx >= 0 && visualIdx < ArraySize(g_InfoOrdersTickets))
       {
          ticket = g_InfoOrdersTickets[visualIdx];
       }
       
       if(ticket > 0 && OrderSelect(ticket, SELECT_BY_TICKET))
       {
          string symbol = OrderSymbol();
          
          // 1. Select this order in Position Manager
          SelectedPositionTicket = ticket;
          
          // 2. Open Position Manager if not already visible
          if(!g_PanelPositions.IsVisible)
          {
             g_PanelPositions.IsVisible = true;
             TogglePositionsPanel(true);
             UpdateManagerPanel(); // Update Manager Panel button states
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
