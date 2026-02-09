//+------------------------------------------------------------------+
//|                                     Panel_Positions_Control.mqh  |
//|                                           FantomePad Project     |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| VISIBILITY CONTROL                                               |
//+------------------------------------------------------------------+
void TogglePositionsPanel(bool visible)
{
   g_PanelPositions.IsVisible = visible;
   SetObjVisible("Pos_Bg", visible);
   SetObjVisible("Pos_Header", visible);
   SetObjVisible("Pos_Title", visible);
   SetObjVisible("Pos_Btn_Select", visible);
   SetObjVisible("Pos_Stats_Bg", visible);
   
   SetObjVisible("Pos_Lbl_Size", visible);
   SetObjVisible("Pos_Val_Size", visible);
   SetObjVisible("Pos_Lbl_Profit", visible);
   SetObjVisible("Pos_Val_Profit", visible);
   SetObjVisible("Pos_Lbl_ProfitR", visible);
   SetObjVisible("Pos_Val_ProfitR", visible);
   SetObjVisible("Pos_Lbl_ProfitPrc", visible);
   SetObjVisible("Pos_Val_ProfitPrc", visible);
   SetObjVisible("Pos_Lbl_Entry", visible);
   SetObjVisible("Pos_Edit_Entry", visible);
   SetObjVisible("Pos_Lbl_SL", visible);
   SetObjVisible("Pos_Edit_SL", visible);
   SetObjVisible("Pos_Lbl_TP", visible);
   SetObjVisible("Pos_Edit_TP", visible);
   SetObjVisible("Pos_Btn_BE", visible);
   SetObjVisible("Pos_Lbl_Comm", visible);
   SetObjVisible("Pos_Val_Comm", visible);
   SetObjVisible("Pos_Lbl_Swap", visible);
   SetObjVisible("Pos_Val_Swap", visible);
   SetObjVisible("Pos_Lbl_RiskR", visible);
   SetObjVisible("Pos_Val_RiskR", visible);
   SetObjVisible("Pos_Lbl_RiskPrc", visible);
   SetObjVisible("Pos_Val_RiskPrc", visible);
   SetObjVisible("Pos_Lbl_Close", visible);
   SetObjVisible("Pos_Btn_25", visible);
   SetObjVisible("Pos_Btn_50", visible);
   SetObjVisible("Pos_Btn_100", visible);
   SetObjVisible("Pos_Edit_Close", visible);
   SetObjVisible("Pos_Btn_Validate", visible);
   
   if(visible)
   {
      UpdatePositionsLayout();
      UpdatePositionsValues();
   }
   else
   {
      if(IsPosListOpen) ClosePositionList();
      HidePosValidationError(); 
   }
}
