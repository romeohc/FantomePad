//+------------------------------------------------------------------+
//|                                           Handler_SymbolList.mqh |
//+------------------------------------------------------------------+
#property strict

bool Handle_SymbolList_Events(string sparam)
{
   // 1. Clic sur le bouton principal de l'actif
   if(sparam == PREFIX + "Nav_Btn_SymbolSelect")
   {
      FP_ObjectSetInteger(0, sparam, OBJPROP_STATE, false); // Désactiver l'état "enfoncé" pour garder la couleur d'origine
      ToggleSymbolList();
      ChartRedraw();
      return true; // On arrête là pour éviter les conflits
   }

   // 2. Clic sur un élément de la liste (Actif spécifique)
   if(StringFind(sparam, PREFIX + "ListItem_") >= 0)
   {
      // Check if account is connected before processing symbol change
      if(AccountInfoInteger(ACCOUNT_LOGIN) == 0)
      {
         CloseSymbolList();
         MessageBox("Please connect a MetaTrader account (File -> Login to Trade Account) to use FantomePad fully.", "No Account Connected", MB_OK | MB_ICONWARNING);
         ChartRedraw();
         return true;
      }
      
      // Récupérer le nom du symbole depuis le texte du bouton cliqué
      string selectedSymbol = FP_ObjectGetString(0, sparam, OBJPROP_TEXT);
      
      // Mettre à jour le bouton principal
      FP_ObjectSetString(0, PREFIX + "Nav_Btn_SymbolSelect", OBJPROP_TEXT, selectedSymbol);
      
      // Changer le symbole du graphique en arrière-plan
      ChartSetSymbolPeriod(0, selectedSymbol, Period());
      
      // Fermer la liste
      CloseSymbolList();
      UpdateCalculatedLot(); // Recalculate for new symbol
      ChartRedraw();
      return true;
   }
   
   // Si on clique ailleurs et que la liste est ouverte, on la ferme
   if(IsListOpen && 
      StringFind(sparam, PREFIX + "ListItem_") < 0 && 
      sparam != PREFIX + "Nav_Btn_SymbolSelect" &&
      sparam != PREFIX + "ScrollTrack" &&
      sparam != PREFIX + "ScrollThumb")
   {
      CloseSymbolList();
      return false; // Continue processing
   }
   
   return false;
}
