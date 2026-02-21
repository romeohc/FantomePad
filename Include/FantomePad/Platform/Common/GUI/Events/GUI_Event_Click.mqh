//+------------------------------------------------------------------+
//|                                              GUI_Event_Click.mqh |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| EVENT: CLICK (CHART)                                             |
//+------------------------------------------------------------------+
void OnEvent_Click()
{
   if(g_BlockClick || IsScrollDragging || g_ScrollSymbolManager.IsDragging)
   {
      g_BlockClick = false;
      return;
   }

   // On n'exécute la fermeture que si le dernier clic sur un objet date de plus de 200ms
   // car MT4/MT5 envoie parfois les deux événements presque en même temps ou avec un slight delay.
   if(IsListOpen && (GetTickCount() - LastClickTime) > 200) 
   {
      CloseSymbolList();
   }
   
   // Close Color Picker on Chart Click
   if(g_IsColorPickerOpen && (GetTickCount() - LastClickTime) > 200)
   {
      CloseColorPicker();
   }

   // Close Symbol Manager on Chart Click
   if(g_PanelSymbolManager.IsVisible && (GetTickCount() - LastClickTime) > 200)
   {
      ToggleSymbolManager(false);
   }
}
