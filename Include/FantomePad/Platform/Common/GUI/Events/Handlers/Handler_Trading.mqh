//+------------------------------------------------------------------+
//|                                              Handler_Trading.mqh |
//+------------------------------------------------------------------+
#property strict

// New Engine System Includes
#include "../../../Core/Engine/TradeOrchestrator.mqh"
#include "../../../Core/Engine/TradeErrorHandler.mqh"

// Helper to reset UI fields after successful trade
void ResetTradeUI()
{
   FP_ObjectSetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT, "0");
   FP_ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, "0");
   FP_ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, "0");
   FP_ObjectSetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT, "0"); 
   
   // Refresh UI logic
   UpdateCalculatedLot();
   
   // Audio Feedback
   PlaySound("ok.wav");
}

bool Handle_Trading_Events(string sparam)
{
   // --- LICENSE GUARD (FAST MEMORY CHECK) ---
   if(g_LicenseState != LICENSE_OK)
   {
       // Blocage immédiat des prises de positions
       // Les actions de clôture/modif sont gérées ailleurs (Handler_PositionActions)
       // Ici on gère le panel principal Buy/Sell/Pending
       Print("FantomePad: Trade Blocked. LicenseState=" + IntegerToString(g_LicenseState));
       return false;
   }

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

   // Actions de Trading : MARKET BUY
   if(sparam == PREFIX + "Btn_Buy" && CurrentTypeIndex == 0)
   {
      EffectButton(sparam);
      HideValidationError();
      
      // UX Validation Only (Empty Fields)
      double sl = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
      double risk = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));
      
      if(sl <= 0 || risk <= 0) 
      {
         string errMsg = "";
         if(sl <= 0 && risk <= 0) errMsg = "Stop Loss & Risk required!";
         else if(sl <= 0) errMsg = "Stop Loss required!";
         else errMsg = "Risk required!";
         
         ShowValidationError(errMsg);
         return true;
      }
      
      // Build Request
      TradeRequest req;
      req.Symbol = FP_ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
      if(req.Symbol == "") req.Symbol = Symbol();
      req.Type = OP_BUY;
      req.Price = MarketInfo(req.Symbol, MODE_ASK);
      req.SL = sl;
      req.TP = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT));
      req.Lots = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_Lot", OBJPROP_TEXT));
      req.Comment = "FantomePad";
      req.Magic = MagicNumber; // Assumes MagicNumber is global
      req.Expiration = 0;
      
      // Execute via Orchestrator
      TradeResult result = TradeOrchestrator::Execute(req);
      
      if(result.Success) {
         ResetTradeUI();  
         UpdateChartLines();
         UpdateOpenOrderLines();
         UpdateCalculatedLot();
      } else {
         TradeErrorHandler::ShowTradeToast(result);
      }
      return true;
   }
   
   // Actions de Trading : MARKET SELL
   if(sparam == PREFIX + "Btn_Sell" && CurrentTypeIndex == 0)
   {
      EffectButton(sparam);
      HideValidationError();
      
      // UX Validation Only
      double sl = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
      double risk = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));

      if(sl <= 0 || risk <= 0) 
      {
         string errMsg = "";
         if(sl <= 0 && risk <= 0) errMsg = "Stop Loss & Risk required!";
         else if(sl <= 0) errMsg = "Stop Loss required!";
         else errMsg = "Risk required!";
         
         ShowValidationError(errMsg);
         return true;
      }

      // Build Request
      TradeRequest req;
      req.Symbol = FP_ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
      if(req.Symbol == "") req.Symbol = Symbol();
      req.Type = OP_SELL;
      req.Price = MarketInfo(req.Symbol, MODE_BID);
      req.SL = sl;
      req.TP = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT));
      req.Lots = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_Lot", OBJPROP_TEXT));
      req.Comment = "FantomePad";
      req.Magic = MagicNumber;
      req.Expiration = 0;

      // Execute via Orchestrator
      TradeResult result = TradeOrchestrator::Execute(req);

      if(result.Success) {
         ResetTradeUI();
         UpdateChartLines();
         UpdateOpenOrderLines();
         UpdateCalculatedLot();
      } else {
         TradeErrorHandler::ShowTradeToast(result);
      }
      return true;
   }

   // Actions de Trading : PENDING ORDERS
   if(sparam == PREFIX + "Btn_Action" && CurrentTypeIndex > 0)
   {
      EffectButton(sparam);
      HideValidationError();
      
      // UX Validation
      double sl = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
      double risk = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));
      double price = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT));
      
      if(sl <= 0 || risk <= 0 || price <= 0)
      {
          string missing = "";
          if(price <= 0) missing = "Entry Price";
          if(sl <= 0) missing = (missing == "") ? "Stop Loss" : missing + ", SL";
          if(risk <= 0) missing = (missing == "") ? "Risk" : missing + ", Risk";
          
          ShowValidationError(missing + " required!");
          return true;
      }
      
      // Map UI Type to OP Type
      int opCmd = -1;
      if(CurrentTypeIndex == 1) opCmd = OP_BUYLIMIT;
      if(CurrentTypeIndex == 2) opCmd = OP_SELLLIMIT;
      if(CurrentTypeIndex == 3) opCmd = OP_BUYSTOP;
      if(CurrentTypeIndex == 4) opCmd = OP_SELLSTOP;
      
      if(opCmd != -1) 
      {
         TradeRequest req;
         req.Symbol = FP_ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
         if(req.Symbol == "") req.Symbol = Symbol();
         req.Type = opCmd;
         req.Price = price;
         req.SL = sl;
         req.TP = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT));
         req.Lots = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_Lot", OBJPROP_TEXT));
         req.Comment = "FantomePad";
         req.Magic = MagicNumber; // Global
         req.Expiration = 0;
         
         TradeResult result = TradeOrchestrator::Execute(req);
         
         if(result.Success) {
            ResetTradeUI();
            UpdateChartLines();
            UpdateOpenOrderLines();
            UpdateCalculatedLot();
         } else {
            TradeErrorHandler::ShowTradeToast(result);
         }
      }
      return true;
   }
   
   return false;
}
