//+------------------------------------------------------------------+
//|                                              GUI_Event_Click.mqh |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| EVENT: CLICK (CHART)                                             |
//+------------------------------------------------------------------+
void OnEvent_Click()
{
   // On n'exécute la fermeture que si le dernier clic sur un objet date de plus de 100ms
   // car MT4 envoie parfois les deux événements presque en même temps.
   if(IsListOpen && (GetTickCount() - LastClickTime) > 100) 
   {
      CloseSymbolList();
   }
   
   // Close Color Picker on Chart Click
   if(g_IsColorPickerOpen && (GetTickCount() - LastClickTime) > 100)
   {
      CloseColorPicker();
   }

   // Close Symbol Manager on Chart Click
   if(g_PanelSymbolManager.IsVisible && (GetTickCount() - LastClickTime) > 100)
   {
      ToggleSymbolManager(false);
   }
}
