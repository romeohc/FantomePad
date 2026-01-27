//+------------------------------------------------------------------+
//|                                               GUI_Event_Key.mqh  |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| EVENT: KEY DOWN                                                  |
//+------------------------------------------------------------------+
void OnEvent_Key(long lparam)
{
   bool changed = false;
   
   // Touche 7 (Buy / Market) - Code ASCII 55
   if(lparam == 55)
   {
      CurrentTypeIndex = 0;
      CurrentDirection = 0; // Buy
      changed = true;
   }
   
   // Touche 8 (Sell / Market) - Code ASCII 56
   if(lparam == 56)
   {
      CurrentTypeIndex = 0;
      CurrentDirection = 1; // Sell
      changed = true;
   }
   
   // Touche 9 (Toggle Mode) - Code ASCII 57
   if(lparam == 57)
   {
      if(CurrentDirection == 0) // Direction Buy
      {
         if(CurrentTypeIndex == 0)      CurrentTypeIndex = 1; // Market -> Buy Limit
         else if(CurrentTypeIndex == 1) CurrentTypeIndex = 3; // Buy Limit -> Buy Stop
         else                           CurrentTypeIndex = 0; // Buy Stop -> Market
      }
      else // Direction Sell
      {
         if(CurrentTypeIndex == 0)      CurrentTypeIndex = 2; // Market -> Sell Limit
         else if(CurrentTypeIndex == 2) CurrentTypeIndex = 4; // Sell Limit -> Sell Stop
         else                           CurrentTypeIndex = 0; // Sell Stop -> Market
      }
      changed = true;
   }
   
   if(changed)
   {
      UpdateUIMode();
      UpdateCalculatedLot(); // Recalcul des lots et mise à jour boutons
      ChartRedraw();
   }
}
