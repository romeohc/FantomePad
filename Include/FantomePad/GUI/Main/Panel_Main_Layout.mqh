//+------------------------------------------------------------------+
//|                                         Panel_Main_Layout.mqh    |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _PANEL_MAIN_LAYOUT_MQH_
#define _PANEL_MAIN_LAYOUT_MQH_
#property strict

#include "Panel_Main_Shared.mqh"

// Implementation of UI Layout and Visibility

//+------------------------------------------------------------------+
//| MOTEUR DE LAYOUT DYNAMIQUE                                       |
//+------------------------------------------------------------------+
void UpdateUIMode()
{
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   int startX = (g_PanelMain.X == -1) ? (chartW / 2) - (g_PanelMain.Width / 2) : g_PanelMain.X;
   int startY = (g_PanelMain.Y == -1) ? (chartH / 2) - (200) : g_PanelMain.Y;
   
   int paddingX = 20;
   int inputH   = 28;
   int gapY     = 8;
   int sectionGap = 20;
   
   int currentY = startY + 50; 
   
   SetObjPosition("Bg", startX, startY);
   SetObjPosition("Header", startX, startY);
   SetObjPosition("Title", startX + 15, startY + 12);
   
   SetObjPosition("Btn_Type", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Btn_Type", OBJPROP_XSIZE, g_PanelMain.Width - (paddingX*2));
   ObjectSetInteger(0, PREFIX + "Btn_Type", OBJPROP_YSIZE, inputH);
   
   string typeText = "";
   color  typeBgColor = g_ColorInput;
   color  typeBorderColor = g_ColorInput;
   
   if(CurrentTypeIndex == 0)
   {
      if(CurrentDirection == 0) 
      {
         typeText = "BUY MARKET";
         typeBgColor = g_ColorGreen;
         typeBorderColor = typeBgColor;
      }
      else 
      {
         typeText = "SELL MARKET";
         typeBgColor = g_ColorRed;
         typeBorderColor = typeBgColor;
      }
   }
   else if(CurrentTypeIndex == 1 || CurrentTypeIndex == 3)
   {
      typeText = OrderTypes[CurrentTypeIndex];
      typeBgColor = g_ColorGreen; 
      typeBorderColor = g_ColorGreen;
   }
   else
   {
      typeText = OrderTypes[CurrentTypeIndex];
      typeBgColor = g_ColorRed;
      typeBorderColor = g_ColorRed;
   }
   
   ObjectSetString(0, PREFIX + "Btn_Type", OBJPROP_TEXT, typeText);
   ObjectSetInteger(0, PREFIX + "Btn_Type", OBJPROP_BGCOLOR, typeBgColor);
   ObjectSetInteger(0, PREFIX + "Btn_Type", OBJPROP_BORDER_COLOR, typeBorderColor);
   ObjectSetInteger(0, PREFIX + "Btn_Type", OBJPROP_COLOR, g_ColorText);
   
   currentY += inputH + sectionGap;
   
   if(CurrentTypeIndex == 0)
   {
      SetObjVisible("Label_Price", false);
      SetObjVisible("Edit_Price", false);
   }
   else
   {
      SetObjVisible("Label_Price", true);
      SetObjVisible("Edit_Price", true);
      
      SetObjPosition("Label_Price", startX + paddingX, currentY);
      currentY += 15;
      
      SetObjPosition("Edit_Price", startX + paddingX, currentY);
      ObjectSetInteger(0, PREFIX + "Edit_Price", OBJPROP_XSIZE, g_PanelMain.Width - (paddingX*2));
      ObjectSetInteger(0, PREFIX + "Edit_Price", OBJPROP_YSIZE, inputH);
      
      currentY += inputH + sectionGap; 
   }
   
   int halfWidth = (g_PanelMain.Width - (paddingX*2) - 10) / 2;
   
   SetObjPosition("Label_SL", startX + paddingX, currentY);
   SetObjVisible("Label_SL", true);
   
   SetObjPosition("Label_TP", startX + paddingX + halfWidth + 10, currentY);
   SetObjVisible("Label_TP", true);
   
   currentY += 15;
   
   SetObjPosition("Edit_SL", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Edit_SL", OBJPROP_XSIZE, halfWidth);
   ObjectSetInteger(0, PREFIX + "Edit_SL", OBJPROP_YSIZE, inputH);
   
   SetObjPosition("Edit_TP", startX + paddingX + halfWidth + 10, currentY);
   ObjectSetInteger(0, PREFIX + "Edit_TP", OBJPROP_XSIZE, halfWidth);
   ObjectSetInteger(0, PREFIX + "Edit_TP", OBJPROP_YSIZE, inputH);
   
   currentY += inputH + sectionGap;
   
   SetObjPosition("Label_Risk", startX + paddingX, currentY);
   SetObjPosition("Label_Lot", startX + paddingX + halfWidth + 10, currentY);
   
   currentY += 15;
   
   SetObjPosition("Edit_Risk", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Edit_Risk", OBJPROP_XSIZE, halfWidth);
   ObjectSetInteger(0, PREFIX + "Edit_Risk", OBJPROP_YSIZE, inputH);
   
   string riskUnit = "%";
   if(RiskMode == 1) riskUnit = AccountCurrency();
   else if(RiskMode == 2) riskUnit = "R";
   ObjectSetString(0, PREFIX + "Label_RiskPerc", OBJPROP_TEXT, riskUnit);
   
   int unitWidth = 35; 
   SetObjPosition("Label_RiskPerc", startX + paddingX + halfWidth - unitWidth - 2, currentY + 4);
   ObjectSetInteger(0, PREFIX + "Label_RiskPerc", OBJPROP_XSIZE, unitWidth);
   ObjectSetInteger(0, PREFIX + "Label_RiskPerc", OBJPROP_YSIZE, 20);
   ObjectSetInteger(0, PREFIX + "Label_RiskPerc", OBJPROP_ZORDER, 10);
   
   SetObjPosition("Edit_Lot", startX + paddingX + halfWidth + 10, currentY);
   ObjectSetInteger(0, PREFIX + "Edit_Lot", OBJPROP_XSIZE, halfWidth);
   ObjectSetInteger(0, PREFIX + "Edit_Lot", OBJPROP_YSIZE, inputH);
   
   currentY += inputH + sectionGap;
   
   if(CurrentTypeIndex == 0)
   {
      SetObjVisible("Btn_Action", false);
      if(CurrentDirection == 0)
      {
         SetObjVisible("Btn_Buy", true);
         SetObjVisible("Btn_Sell", false);
         SetObjPosition("Btn_Buy", startX + paddingX, currentY);
         ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_XSIZE, g_PanelMain.Width - (paddingX*2));
         ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_YSIZE, 45);
      }
      else
      {
         SetObjVisible("Btn_Buy", false);
         SetObjVisible("Btn_Sell", true);
         SetObjPosition("Btn_Sell", startX + paddingX, currentY);
         ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_XSIZE, g_PanelMain.Width - (paddingX*2));
         ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_YSIZE, 45); 
      }
   }
   else
   {
      SetObjVisible("Btn_Action", true);
      SetObjVisible("Btn_Buy", false);
      SetObjVisible("Btn_Sell", false);
      SetObjPosition("Btn_Action", startX + paddingX, currentY);
      ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_XSIZE, g_PanelMain.Width - (paddingX*2));
      ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_YSIZE, 45);
   }
   
   currentY += 60; 
   
   int totalHeight = currentY - startY + 10; 
   ObjectSetInteger(0, PREFIX + "Bg", OBJPROP_YSIZE, totalHeight);
   
   UpdateChartLines();
   UpdateCalculatedLot();
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| VISIBILITY CONTROL                                               |
//+------------------------------------------------------------------+
void ToggleMainPanel(bool visible)
{
   SetObjVisible("Bg", visible);
   SetObjVisible("Header", visible);
   SetObjVisible("Title", visible);
   SetObjVisible("Btn_Type", visible);
   
   if(visible)
   {
      UpdateUIMode(); 
      ApplyDefaultTradeValues();
   }
   else
   {
      SetObjVisible("Label_Price", false);
      SetObjVisible("Edit_Price", false);
      SetObjVisible("Btn_Buy", false);
      SetObjVisible("Btn_Sell", false);
      SetObjVisible("Btn_Action", false);
      
      HideValidationError();
      
      ObjectDelete(0, PREFIX + "Line_SL");
      ObjectDelete(0, PREFIX + "Line_TP");
      ObjectDelete(0, PREFIX + "Line_Price");
      
      ObjectDelete(0, PREFIX + "Line_SL_Txt");
      ObjectDelete(0, PREFIX + "Line_TP_Txt");
      ObjectDelete(0, PREFIX + "Line_Price_Txt");
   }
   
   SetObjVisible("Label_SL", visible);
   SetObjVisible("Edit_SL", visible);
   SetObjVisible("Label_TP", visible);
   SetObjVisible("Edit_TP", visible);
   SetObjVisible("Label_Risk", visible);
   SetObjVisible("Edit_Risk", visible);
   SetObjVisible("Label_RiskPerc", visible);
   SetObjVisible("Label_Lot", visible);
   SetObjVisible("Edit_Lot", visible);
}
#endif
