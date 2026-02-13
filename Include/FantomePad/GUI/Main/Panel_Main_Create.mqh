//+------------------------------------------------------------------+
//|                                         Panel_Main_Create.mqh    |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _PANEL_MAIN_CREATE_MQH_
#define _PANEL_MAIN_CREATE_MQH_
#property strict

#include "Panel_Main_Shared.mqh"

// Implementation of UI Creation

//+------------------------------------------------------------------+
//| Création graphique (Initialisation des objets)                   |
//+------------------------------------------------------------------+
void CreatePanel()
{
   CreateRect("Bg", 0, 0, g_PanelMain.Width, 100, g_ColorBg, BORDER_FLAT); 
   
   CreateButton("Btn_Type", OrderTypes[CurrentTypeIndex], 0, 0, g_PanelMain.Width - 40, 28, g_ColorInput, g_ColorText);
   ObjectSetString(0, PREFIX + "Btn_Type", OBJPROP_FONT, "Trebuchet MS Bold");
   
   CreateLabel("Label_Price", "Entry price", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Edit_Price", DoubleToString(Ask, Digits), 0, 0, g_PanelMain.Width - 40, 28);
   
   CreateLabel("Label_SL", "Stop loss", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Edit_SL", "0.00000", 0, 0, g_PanelMain.Width - 40, 28);
   
   CreateLabel("Label_TP", "Take profit", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Edit_TP", "0.00000", 0, 0, g_PanelMain.Width - 40, 28);
   
   CreateLabel("Label_Risk", "Risk", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Edit_Risk", "0", 0, 0, g_PanelMain.Width - 40, 28);
   
   CreateButton("Label_RiskPerc", "%", 0, 0, 40, 20, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Label_RiskPerc", OBJPROP_BORDER_COLOR, g_ColorInput);
   ObjectSetInteger(0, PREFIX + "Label_RiskPerc", OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, PREFIX + "Label_RiskPerc", OBJPROP_FONT, "Trebuchet MS Bold");
   ObjectSetInteger(0, PREFIX + "Label_RiskPerc", OBJPROP_ZORDER, 10);
   
   CreateLabel("Label_Lot", "Lot (Auto)", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Edit_Lot", "0.00", 0, 0, g_PanelMain.Width - 40, 28, true);
   
   CreateButton("Btn_Sell", "VALIDATE", 0, 0, g_PanelMain.Width - 40, 45, g_ColorBtnActive, g_ColorText); 
   ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_FONTSIZE, 11);
   ObjectSetString(0, PREFIX + "Btn_Sell", OBJPROP_FONT, "Trebuchet MS Bold");
   
   CreateButton("Btn_Buy", "VALIDATE", 0, 0, g_PanelMain.Width - 40, 45, g_ColorBtnActive, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_FONTSIZE, 11);
   ObjectSetString(0, PREFIX + "Btn_Buy", OBJPROP_FONT, "Trebuchet MS Bold");
 
   CreateButton("Btn_Action", "VALIDATE", 0, 0, g_PanelMain.Width - 40, 45, g_ColorBtnActive, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_FONTSIZE, 11);
   ObjectSetString(0, PREFIX + "Btn_Action", OBJPROP_FONT, "Trebuchet MS Bold");
}
#endif
