//+------------------------------------------------------------------+
//|                                      Handler_PositionActions.mqh |
//+------------------------------------------------------------------+
#property strict

// New Engine System Includes
#include "../../../Core/Engine/TradeOrchestrator.mqh"
#include "../../../Core/Engine/TradeErrorHandler.mqh"

//+------------------------------------------------------------------+
//| HELPER: Execute Partial Close on selected position               |
//+------------------------------------------------------------------+
TradeResult ExecutePartialClose(FantomeTrade &trade, double pct)
{
    double currentLots = trade.Lots;
    double toClose = 0.0;

    // ALWAYS calc based on ORIGINAL lots (User Request)
    double originLots = GetOriginalLotSize(SelectedPositionTicket);
    if(originLots <= 0) originLots = currentLots;

    toClose = originLots * (pct / 100.0);

    // Normalize Lots
    double step = MarketInfo(trade.Symbol, MODE_LOTSTEP);
    if(step <= 0) step = 0.01; // Safety fallback
    double min = MarketInfo(trade.Symbol, MODE_MINLOT);

    toClose = MathFloor(toClose / step) * step;
    if(toClose < min) toClose = min;
    if(toClose > currentLots) toClose = currentLots;
    if(pct >= 99.9) toClose = currentLots;

    // Execute
    int cmd = trade.Type;
    if(cmd > 1) // Pending
       return TradeOrchestrator::DeleteOrder(SelectedPositionTicket);
    else
       return TradeOrchestrator::ClosePosition(SelectedPositionTicket, toClose, "Partial Close");
}

//+------------------------------------------------------------------+
//| HELPER: Execute SL/TP Modification on selected position          |
//+------------------------------------------------------------------+
TradeResult ExecuteModifySLTP(FantomeTrade &trade)
{
    double inputSL = StringToDouble(FP_ObjectGetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT));
    double inputTP = StringToDouble(FP_ObjectGetString(0, PREFIX + "Pos_Edit_TP", OBJPROP_TEXT));
    double inputOpen = trade.OpenPrice;

    if(trade.Type > 1)
       inputOpen = StringToDouble(FP_ObjectGetString(0, PREFIX + "Pos_Edit_Entry", OBJPROP_TEXT));

    if(g_PosBE_Active)
       inputSL = trade.OpenPrice;

    if(MathAbs(inputSL - trade.StopLoss) > Point ||
       MathAbs(inputTP - trade.TakeProfit) > Point ||
       MathAbs(inputOpen - trade.OpenPrice) > Point)
    {
       return TradeOrchestrator::ModifyPosition(SelectedPositionTicket, inputSL, inputTP);
    }

    return MakeSuccessResult(0, "No changes"); // Nothing to modify
}

//+------------------------------------------------------------------+
//| Main Event Handler for Position Actions Panel                    |
//+------------------------------------------------------------------+
bool Handle_PositionActions_Events(string sparam)
{
    // --- PARTIAL CLOSE SHORTCUTS ---
   if(sparam == PREFIX + "Pos_Btn_25") 
   {
      CheckAndSelectFirstPosition(25);
      if(SelectedPositionTicket == -1) return true;
      if(g_PosPartialMode == 25) g_PosPartialMode = 0; // Toggle Off
      else g_PosPartialMode = 25;
      
      FP_ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "0"); // Reset custom text
      UpdatePartialButtonsVisuals();
      UpdatePositionsValues(); // For Validate Button
      EffectButton(sparam);
      return true;
   }
   
   if(sparam == PREFIX + "Pos_Btn_50") 
   {
      CheckAndSelectFirstPosition(50);
      if(SelectedPositionTicket == -1) return true;
      if(g_PosPartialMode == 50) g_PosPartialMode = 0; // Toggle Off
      else g_PosPartialMode = 50;
      
      FP_ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "0");
      UpdatePartialButtonsVisuals();
      UpdatePositionsValues(); 
      EffectButton(sparam);
      return true;
   }
   
   if(sparam == PREFIX + "Pos_Btn_100") 
   {
      CheckAndSelectFirstPosition(100);
      if(SelectedPositionTicket == -1) return true;
      if(g_PosPartialMode == 100) g_PosPartialMode = 0; // Toggle Off
      else g_PosPartialMode = 100;
      
      FP_ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "0");
      UpdatePartialButtonsVisuals();
      UpdatePositionsValues(); 
      EffectButton(sparam);
      return true;
   }
   
   // --- BE BUTTON LOGIC ---
   if(sparam == PREFIX + "Pos_Btn_BE")
   {
      CheckAndSelectFirstPosition(0, true);
      if(SelectedPositionTicket != -1 && OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
      {
          FantomeTrade trade;
          FP_GetTrade(trade);
          
          int type = trade.Type;
          double open = trade.OpenPrice;
          double current = (type == OP_BUY) ? MarketInfo(trade.Symbol, MODE_BID) : MarketInfo(trade.Symbol, MODE_ASK);
          
          bool inLoss = (type == OP_BUY && current < open) || (type == OP_SELL && current > open);
          if(inLoss) return true; // Cannot activate if in loss
          
          g_PosBE_Active = !g_PosBE_Active;
          
          if(g_PosBE_Active)
          {
              color bg = (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP) ? g_ColorGreen : g_ColorRed;
              FP_ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, bg);
              FP_ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, clrWhite);
              FP_ObjectSetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT, DoubleToString(open, _Digits));
          }
          else
          {
              FP_ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, g_ColorInput);
              FP_ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, g_ColorText);
              FP_ObjectSetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT, DoubleToString(trade.StopLoss, _Digits));
          }
          
          UpdatePositionsValues();
          EffectButton(sparam);
      }
      return true;
   }
   
   // --- VALIDATE ACTION ---
   if(sparam == PREFIX + "Pos_Btn_Validate")
   {
      EffectButton(sparam);
      
      if(!IsExpertEnabled()) { ShowPosValidationError("Auto-Trading is OFF!"); return true; }
      if(!IsTradeAllowed()) { ShowPosValidationError("Live Trading disabled!"); return true; }

      if(SelectedPositionTicket == -1) { ShowPosValidationError("No position selected!"); ChartRedraw(); return true; }
      if(!OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET)) { ShowPosValidationError("Position not found!"); ChartRedraw(); return true; }
      if(OrderCloseTime() != 0)
      {
          ShowPosValidationError("Position is already closed!");
          SelectedPositionTicket = -1;
          UpdatePositionsValues();
          ChartRedraw();
          return true;
      }
      
      FantomeTrade trade;
      FP_GetTrade(trade);
      
      double userSL = StringToDouble(FP_ObjectGetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT));
      double userTP = StringToDouble(FP_ObjectGetString(0, PREFIX + "Pos_Edit_TP", OBJPROP_TEXT));
      double userEntry = StringToDouble(FP_ObjectGetString(0, PREFIX + "Pos_Edit_Entry", OBJPROP_TEXT));
      double userClose = StringToDouble(FP_ObjectGetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT));
      double pctFromText = userClose;
      
      if(pctFromText <= 0.001 && g_PosPartialMode > 0) pctFromText = (double)g_PosPartialMode;
      
      bool isModified = false;
      if(MathAbs(userSL - trade.StopLoss) > Point) isModified = true;
      if(MathAbs(userTP - trade.TakeProfit) > Point) isModified = true;
      if(trade.Type > 1 && MathAbs(userEntry - trade.OpenPrice) > Point) isModified = true;
      if(pctFromText > 0.001) isModified = true;
      if(g_PosBE_Active) isModified = true;
      
      if(!isModified) { ShowPosValidationError("No modifications to apply!"); ChartRedraw(); return true; }
      
      HidePosValidationError();
      if(SelectedPositionTicket != -1 && OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
      {
          FP_GetTrade(trade);
          if(trade.CloseTime == 0)
          {
              // 1. Handle Close
              double pct = StringToDouble(FP_ObjectGetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT));
              if(pct <= 0.001 && g_PosPartialMode > 0) pct = (double)g_PosPartialMode;

              if(pct > 0)
              {
                  TradeResult closeRes = ExecutePartialClose(trade, pct);
                  if(closeRes.Success)
                  {
                      FP_ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "0");
                      g_PosPartialMode = 0; 
                      UpdatePartialButtonsVisuals();
                      UpdateOpenOrderLines();
                      UpdateCalculatedLot();
                      
                      if(g_PanelAccount.IsVisible) CreateAccountPanel();
                      if(g_PanelHistory.IsVisible) CreateHistoryPanel();
                      
                      if(pct >= 99.9) 
                      {
                          SelectedPositionTicket = -1;
                          UpdatePositionsValues();
                          ChartRedraw();
                          return true;
                      }
                      
                      // For MT4: Partial Close often creates a new ticket. Find it to maintain selection.
                      #ifdef __MQL4__
                      if(!OrderSelect((int)SelectedPositionTicket, SELECT_BY_TICKET) || OrderCloseTime() != 0)
                      {
                          long nextTicket = FindMT4SuccessorTicket(SelectedPositionTicket);
                          if(nextTicket != -1)
                          {
                              SelectedPositionTicket = nextTicket;
                              OrderSelect((int)SelectedPositionTicket, SELECT_BY_TICKET);
                          }
                      }
                      #endif
                  }
                  else ShowPosValidationError(closeRes.Message);
              }

              // 2. Handle Modify
              if(SelectedPositionTicket != -1 && OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
              {
                  FP_GetTrade(trade);
                  TradeResult modRes = ExecuteModifySLTP(trade);
                  if(modRes.Success && modRes.Message != "No changes")
                  {
                      g_LastPosSL = StringToDouble(FP_ObjectGetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT));
                      g_LastPosTP = StringToDouble(FP_ObjectGetString(0, PREFIX + "Pos_Edit_TP", OBJPROP_TEXT));
                      g_LastPosEntry = (trade.Type > 1) ? StringToDouble(FP_ObjectGetString(0, PREFIX + "Pos_Edit_Entry", OBJPROP_TEXT)) : trade.OpenPrice;
                      if(g_PosBE_Active) g_LastPosSL = trade.OpenPrice;

                      UpdateOpenOrderLines();
                      
                      if(g_PosBE_Active)
                      {
                          g_PosBE_Active = false;
                          FP_ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, g_ColorInput);
                          FP_ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, g_ColorText);
                      }
                  }
                  else if(!modRes.Success) ShowPosValidationError(modRes.Message);
              }
          }
      }
      
      UpdatePositionsValues();
      ChartRedraw();
      return true;
   }
   
   return false;
}
