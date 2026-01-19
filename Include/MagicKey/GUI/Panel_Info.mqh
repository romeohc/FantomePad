//+------------------------------------------------------------------+
//|                                              Panel_Info.mqh      |
//|                                                MagicKey Project  |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| MISE A JOUR DU LAYOUT (POSITIONNEMENT)                           |
//+------------------------------------------------------------------+
void UpdateInfoLayout()
{
   int startX = InfoPanelX;
   int startY = InfoPanelY;
   int width  = 220; // Slightly wider
   
   int paddingX = 20;
   int gapY     = 2; // Tight gap between label and value
   int sectionGap = 15;
   
   int currentY = startY + 50; 
   
   // 1. Fond & Header
   SetObjPosition("Info_Bg", startX, startY);
   SetObjPosition("Info_Header", startX, startY);
   SetObjPosition("Info_Title", startX + 15, startY + 12);
   
   ObjectSetInteger(0, PREFIX + "Info_Bg", OBJPROP_XSIZE, width);
   ObjectSetInteger(0, PREFIX + "Info_Header", OBJPROP_XSIZE, width);
   
   // 2. Balance
   SetObjPosition("Info_Lbl_Balance", startX + paddingX, currentY);
   currentY += 12; // Label height
   SetObjPosition("Info_Val_Balance", startX + paddingX, currentY);
   currentY += 20 + sectionGap; // Value height + gap
   
   // 3. Equity
   SetObjPosition("Info_Lbl_Equity", startX + paddingX, currentY);
   currentY += 12;
   SetObjPosition("Info_Val_Equity", startX + paddingX, currentY);
   currentY += 20 + sectionGap;
   
   // 4. Free Margin
   SetObjPosition("Info_Lbl_Margin", startX + paddingX, currentY);
   currentY += 12;
   SetObjPosition("Info_Val_Margin", startX + paddingX, currentY);
   currentY += 20 + sectionGap;
   
   // Ajustement hauteur fond
   int totalHeight = currentY - startY + 10;
   ObjectSetInteger(0, PREFIX + "Info_Bg", OBJPROP_YSIZE, totalHeight);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| CRÉATION DES OBJETS                                              |
//+------------------------------------------------------------------+
void CreateInfoPanel()
{
   int width = 220;
   
   // 1. Fond & Header
   CreateRect("Info_Bg", 0, 0, width, 100, g_ColorBg, BORDER_FLAT); 
   CreateRect("Info_Header", 0, 0, width, 40, g_ColorHeader, BORDER_FLAT);
   CreateLabel("Info_Title", "Account Overview", 0, 0, 10, clrWhite, "Trebuchet MS Bold");
   
   // 2. Balance
   CreateLabel("Info_Lbl_Balance", "BALANCE", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Info_Val_Balance", "...", 0, 0, 12, g_ColorText, "Trebuchet MS Bold");
   
   // 3. Equity
   CreateLabel("Info_Lbl_Equity", "EQUITY", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Info_Val_Equity", "...", 0, 0, 12, g_ColorText, "Trebuchet MS Bold");
   
   // 4. Free Margin
   CreateLabel("Info_Lbl_Margin", "FREE MARGIN", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Info_Val_Margin", "...", 0, 0, 12, g_ColorText, "Trebuchet MS Bold");
   
   UpdateInfoLayout();
   UpdateInfoPanel();
}

//+------------------------------------------------------------------+
//| MISE A JOUR DES VALEURS (TICK)                                   |
//+------------------------------------------------------------------+
void UpdateInfoPanel()
{
   string currency = AccountCurrency();
   
   double bal = AccountBalance();
   double equ = AccountEquity();
   double marg = AccountFreeMargin();
   
   string sBal = DoubleToString(bal, 2) + " " + currency;
   string sEqu = DoubleToString(equ, 2) + " " + currency;
   string sMarg = DoubleToString(marg, 2) + " " + currency;
   
   ObjectSetString(0, PREFIX + "Info_Val_Balance", OBJPROP_TEXT, sBal);
   ObjectSetString(0, PREFIX + "Info_Val_Equity", OBJPROP_TEXT, sEqu);
   ObjectSetString(0, PREFIX + "Info_Val_Margin", OBJPROP_TEXT, sMarg);
}

//+------------------------------------------------------------------+
//| VISIBILITY CONTROL                                               |
//+------------------------------------------------------------------+
void ToggleInfoPanel(bool visible)
{
   SetObjVisible("Info_Bg", visible);
   SetObjVisible("Info_Header", visible);
   SetObjVisible("Info_Title", visible);
   SetObjVisible("Info_Lbl_Balance", visible);
   SetObjVisible("Info_Val_Balance", visible);
   SetObjVisible("Info_Lbl_Equity", visible);
   SetObjVisible("Info_Val_Equity", visible);
   SetObjVisible("Info_Lbl_Margin", visible);
   SetObjVisible("Info_Val_Margin", visible);
   
   if(visible) UpdateInfoLayout();
}
