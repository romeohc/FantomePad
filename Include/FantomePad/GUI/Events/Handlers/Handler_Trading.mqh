//+------------------------------------------------------------------+
//|                                              Handler_Trading.mqh |
//+------------------------------------------------------------------+
#property strict

bool Handle_Trading_Events(string sparam)
{
   // Cycle Type d'Ordre
   if(sparam == PREFIX + "Btn_Type")
   {
      if(CurrentTypeIndex == 0 && CurrentDirection == 0) // Market Buy -> Market Sell
      {
         CurrentDirection = 1;
      }
      else if(CurrentTypeIndex == 0 && CurrentDirection == 1) // Market Sell -> Buy Limit
      {
         CurrentTypeIndex = 1;
         CurrentDirection = 0;
      }
      else if(CurrentTypeIndex == 4) // Sell Stop -> Market Buy
      {
         CurrentTypeIndex = 0;
         CurrentDirection = 0;
      }
      else // Buy Limit(1) -> Sell Limit(2) -> Buy Stop(3) -> Sell Stop(4)
      {
         CurrentTypeIndex++;
      }

      UpdateUIMode(); 
      UpdateCalculatedLot(); // Mise à jour immédiate des états de boutons
      ChartRedraw();
      return true;
   }

   // Actions de Trading
   if(sparam == PREFIX + "Btn_Buy" && CurrentTypeIndex == 0)
   {
      EffectButton(sparam);
      UpdateCalculatedLot(); // Ensure Lot is recalculated before execution
      
      // Sécurité : Vérifier si le SL et Risk sont définis
      double sl = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
      double risk = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));
      
      if(sl <= 0 || risk <= 0) 
      {
         // Build specific error message
         string errMsg = "";
         if(sl <= 0 && risk <= 0) errMsg = "Stop Loss & Risk required!";
         else if(sl <= 0) errMsg = "Stop Loss required!";
         else errMsg = "Risk required!";
         
         ShowValidationError(errMsg);
         return true;
      }
      
      HideValidationError(); // Clear any previous error on success
      ExecuteOrder(OP_BUY);
      return true;
   }
   
   if(sparam == PREFIX + "Btn_Sell" && CurrentTypeIndex == 0)
   {
      EffectButton(sparam);
      UpdateCalculatedLot(); // Ensure Lot is recalculated before execution
      
      // Sécurité : Vérifier si le SL et Risk sont définis
      double sl = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
      double risk = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));

      if(sl <= 0 || risk <= 0) 
      {
         // Build specific error message
         string errMsg = "";
         if(sl <= 0 && risk <= 0) errMsg = "Stop Loss & Risk required!";
         else if(sl <= 0) errMsg = "Stop Loss required!";
         else errMsg = "Risk required!";
         
         ShowValidationError(errMsg);
         return true;
      }

      HideValidationError(); // Clear any previous error on success
      ExecuteOrder(OP_SELL);
      return true;
   }

   if(sparam == PREFIX + "Btn_Action" && CurrentTypeIndex > 0)
   {
      EffectButton(sparam);
      UpdateCalculatedLot(); // Ensure Lot is recalculated before execution
      
      // Sécurité : Validation complète pour Ordres Pending
      double sl = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
      double risk = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));
      double price = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT));
      
      if(sl <= 0 || risk <= 0 || price <= 0)
      {
          // Build specific error message for pending orders
          string missing = "";
          if(price <= 0) missing = "Entry Price";
          if(sl <= 0) missing = (missing == "") ? "Stop Loss" : missing + ", SL";
          if(risk <= 0) missing = (missing == "") ? "Risk" : missing + ", Risk";
          
          ShowValidationError(missing + " required!");
          return true;
      }
   
      HideValidationError(); // Clear any previous error on success
      int opCmd = -1;
      if(CurrentTypeIndex == 1) opCmd = OP_BUYLIMIT;
      if(CurrentTypeIndex == 2) opCmd = OP_SELLLIMIT;
      if(CurrentTypeIndex == 3) opCmd = OP_BUYSTOP;
      if(CurrentTypeIndex == 4) opCmd = OP_SELLSTOP;
      
      if(opCmd != -1) ExecuteOrder(opCmd);
      return true;
   }
   
   return false;
}
