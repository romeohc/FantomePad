//+------------------------------------------------------------------+
//|                                         Panel_Positions_UI.mqh   |
//|                                           FantomePad Project     |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| MISE A JOUR DU LAYOUT (POSITIONNEMENT)                           |
//+------------------------------------------------------------------+
void UpdatePositionsLayout()
{
   if(!g_PanelPositions.IsVisible) return;
   
   int startX = (int)g_PanelPositions.X;
   int startY = (int)g_PanelPositions.Y;
   int width  = 280; 
   int paddingX = 20;
   
   int currentY = startY + 20; 
   
   UpdatePosValidationErrorPosition();
   
   SetObjPosition("Pos_Bg", startX, startY);
   
   // --- Select Key ---
   SetObjPosition("Pos_Btn_Select", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_XSIZE, width - (paddingX * 2));
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_YSIZE, 30);
   currentY += 30 + 15;
   
   // --- STATS GRID (Modern Look) ---
   int statsBgH = 175; 
   int statsY = currentY;
   
   SetObjPosition("Pos_Stats_Bg", startX + paddingX, statsY);
   ObjectSetInteger(0, PREFIX + "Pos_Stats_Bg", OBJPROP_XSIZE, width - (paddingX * 2));
   ObjectSetInteger(0, PREFIX + "Pos_Stats_Bg", OBJPROP_YSIZE, statsBgH);
   
   int gridPadX = 15;
   int gridPadY = 10;
   int colW = (width - (paddingX*2) - (gridPadX*2)) / 2; // ~100px
   int startGridX = startX + paddingX + gridPadX;
   int startGridY = statsY + gridPadY;
   
   // ROW 1: SIZE | PROFIT
   SetObjPosition("Pos_Lbl_Size", startGridX, startGridY);
   SetObjPosition("Pos_Val_Size", startGridX, startGridY + 15);
   
   SetObjPosition("Pos_Lbl_Profit", startGridX + colW, startGridY);
   SetObjPosition("Pos_Val_Profit", startGridX + colW, startGridY + 15);
   
   // ROW 2: PROFIT R | PROFIT %
   int row2Y = startGridY + 40;
   SetObjPosition("Pos_Lbl_ProfitR", startGridX, row2Y);
   SetObjPosition("Pos_Val_ProfitR", startGridX, row2Y + 15);
   
   SetObjPosition("Pos_Lbl_ProfitPrc", startGridX + colW, row2Y);
   SetObjPosition("Pos_Val_ProfitPrc", startGridX + colW, row2Y + 15);
   
   // ROW 3: FEES | COMM
   int row3Y = row2Y + 40;
   SetObjPosition("Pos_Lbl_Swap", startGridX, row3Y);
   SetObjPosition("Pos_Val_Swap", startGridX, row3Y + 15);
   
   SetObjPosition("Pos_Lbl_Comm", startGridX + colW, row3Y);
   SetObjPosition("Pos_Val_Comm", startGridX + colW, row3Y + 15);
   
   // ROW 4: RISK R | RISK %
   int row4Y = row3Y + 40;
   SetObjPosition("Pos_Lbl_RiskR", startGridX, row4Y);
   SetObjPosition("Pos_Val_RiskR", startGridX, row4Y + 15);
   
   SetObjPosition("Pos_Lbl_RiskPrc", startGridX + colW, row4Y);
   SetObjPosition("Pos_Val_RiskPrc", startGridX + colW, row4Y + 15);
   
   currentY += statsBgH + 15;
   
   int inputH   = 28;
   int lblH     = 15;
   int sectionGap = 15;
   
   bool showEntry = false;
   if(SelectedPositionTicket != -1 && OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
   {
      if(OrderType() > 1) showEntry = true;
   }
   
   SetObjVisible("Pos_Lbl_Entry", showEntry);
   SetObjVisible("Pos_Edit_Entry", showEntry);
   
   if(showEntry)
   {
      SetObjPosition("Pos_Lbl_Entry", startX + paddingX, currentY);
      currentY += lblH;
      
      SetObjPosition("Pos_Edit_Entry", startX + paddingX, currentY);
      ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_XSIZE, width - (paddingX * 2));
      ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_YSIZE, inputH);
      
      currentY += inputH + sectionGap;
   }
 
   // SL & BE
   SetObjPosition("Pos_Lbl_SL", startX + paddingX, currentY);
   currentY += lblH;
   
   int halfW = (width - (paddingX * 2) - 10) / 2;
   
   SetObjPosition("Pos_Edit_SL", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Edit_SL", OBJPROP_XSIZE, halfW);
   ObjectSetInteger(0, PREFIX + "Pos_Edit_SL", OBJPROP_YSIZE, inputH);
   
   SetObjPosition("Pos_Btn_BE", startX + paddingX + halfW + 10, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_XSIZE, halfW); 
   ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_YSIZE, inputH); 
   
   currentY += inputH + sectionGap;
   
   // TP
   SetObjPosition("Pos_Lbl_TP", startX + paddingX, currentY);
   currentY += lblH;
   
   SetObjPosition("Pos_Edit_TP", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Edit_TP", OBJPROP_XSIZE, width - (paddingX * 2)); 
   ObjectSetInteger(0, PREFIX + "Pos_Edit_TP", OBJPROP_YSIZE, inputH);
   
   currentY += inputH + sectionGap;
 
   // Partial Close Section
   SetObjPosition("Pos_Lbl_Close", startX + paddingX, currentY);
   currentY += lblH;
   
   int pcBtnW = (width - (paddingX*2) - 15) / 4;
   int pcX = startX + paddingX;
   
   SetObjPosition("Pos_Btn_25", pcX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_25", OBJPROP_XSIZE, pcBtnW);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_25", OBJPROP_YSIZE, inputH);
   
   pcX += pcBtnW + 5;
   SetObjPosition("Pos_Btn_50", pcX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_50", OBJPROP_XSIZE, pcBtnW);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_50", OBJPROP_YSIZE, inputH);
   
   pcX += pcBtnW + 5;
   SetObjPosition("Pos_Btn_100", pcX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_100", OBJPROP_XSIZE, pcBtnW);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_100", OBJPROP_YSIZE, inputH);
   
   pcX += pcBtnW + 5;
   SetObjPosition("Pos_Edit_Close", pcX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Edit_Close", OBJPROP_XSIZE, (long)pcBtnW);
   ObjectSetInteger(0, PREFIX + "Pos_Edit_Close", OBJPROP_YSIZE, (long)inputH);
   
   currentY += (int)(inputH + (sectionGap * 1.5)); 
   
   // Validate
   SetObjPosition("Pos_Btn_Validate", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Validate", OBJPROP_XSIZE, width - (paddingX * 2));
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Validate", OBJPROP_YSIZE, 45); 
   
   currentY += 45 + 20; 
   
   // Adjust Main Bg
   int totalHeight = currentY - startY;
   ObjectSetInteger(0, PREFIX + "Pos_Bg", OBJPROP_XSIZE, width);
   ObjectSetInteger(0, PREFIX + "Pos_Bg", OBJPROP_YSIZE, totalHeight);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| CRÉATION DES OBJETS                                              |
//+------------------------------------------------------------------+
void CreatePositionsPanel()
{
   int width = 280; 
   
   // --- PRE-FETCH DATA FOR UI INIT (Fixes 'Ghost 0' Bug) ---
   string initEntry = "0";
   string initSL    = "0";
   string initTP    = "0";
   
   if(SelectedPositionTicket != -1)
   {
      if(OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
      {
         int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
         initEntry  = DoubleToString(OrderOpenPrice(), digits);
         initSL     = DoubleToString(OrderStopLoss(), digits);
         initTP     = DoubleToString(OrderTakeProfit(), digits);
         
         // Sync trackers immediately so UpdatePositionsValues doesn't think they changed
         g_LastPosEntry = OrderOpenPrice();
         g_LastPosSL    = OrderStopLoss();
         g_LastPosTP    = OrderTakeProfit();
         g_LastPosTicket = SelectedPositionTicket;
      }
   }
   
   // 1. Fond
   CreateRect("Pos_Bg", 0, 0, width, 100, g_ColorBg, BORDER_FLAT); 
   ObjectSetInteger(0, PREFIX + "Pos_Bg", OBJPROP_ZORDER, 0);
   
   // 2. Select Button
   CreateButton("Pos_Btn_Select", "Select Position", 0, 0, width - 40, 30, g_ColorInput, g_ColorText);
   ObjectSetString(0, PREFIX + "Pos_Btn_Select", OBJPROP_FONT, "Trebuchet MS Bold");
   
   // 3. STATS CARD (Grouped)
   CreateRect("Pos_Stats_Bg", 0, 0, width - 40, 175, g_ColorInput, BORDER_FLAT); 
   ObjectSetInteger(0, PREFIX + "Pos_Stats_Bg", OBJPROP_BORDER_COLOR, g_ColorInput);
   
   CreateLabel("Pos_Lbl_Size", "LOTS", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Pos_Val_Size", "-", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Pos_Lbl_Profit", "PROFIT", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Pos_Val_Profit", "-", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
 
   CreateLabel("Pos_Lbl_ProfitR", "PROFIT R", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Pos_Val_ProfitR", "-", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Pos_Lbl_ProfitPrc", "PROFIT %", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Pos_Val_ProfitPrc", "-", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Pos_Lbl_Swap", "FEES", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Pos_Val_Swap", "-", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Pos_Lbl_Comm", "COMMISSION", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Pos_Val_Comm", "-", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Pos_Lbl_RiskR", "RISK R", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Pos_Val_RiskR", "-", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Pos_Lbl_RiskPrc", "RISK %", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Pos_Val_RiskPrc", "-", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   // Cleanup Old Objects
   if(ObjectFind(0, PREFIX + "Pos_Lbl_Risk") >= 0) ObjectDelete(0, PREFIX + "Pos_Lbl_Risk");
   if(ObjectFind(0, PREFIX + "Pos_Val_Risk") >= 0) ObjectDelete(0, PREFIX + "Pos_Val_Risk");
   if(ObjectFind(0, PREFIX + "Pos_Val_RiskMoney") >= 0) ObjectDelete(0, PREFIX + "Pos_Val_RiskMoney");
   
   // 4. Entry Price (Use initEntry)
   CreateLabel("Pos_Lbl_Entry", "Entry Price", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Pos_Edit_Entry", initEntry, 0, 0, width - 40, 28);
 
   // 5. Protection (SL & BE) (Use initSL)
   CreateLabel("Pos_Lbl_SL", "Stop loss", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Pos_Edit_SL", initSL, 0, 0, 80, 28);
   
   CreateButton("Pos_Btn_BE", "BE", 0, 0, 35, 28, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_FONTSIZE, 8); 
   ObjectSetString(0, PREFIX + "Pos_Btn_BE", OBJPROP_FONT, "Trebuchet MS Bold");
 
   // 5. TP (Below) (Use initTP)
   CreateLabel("Pos_Lbl_TP", "Take profit", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Pos_Edit_TP", initTP, 0, 0, 80, 28);
   
   // 6. Close Section
   CreateLabel("Pos_Lbl_Close", "Partial Close", 0, 0, 8, g_ColorText, "Trebuchet MS");
   
   CreateButton("Pos_Btn_25", "25%", 0, 0, 35, 28, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_25", OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, PREFIX + "Pos_Btn_25", OBJPROP_FONT, "Trebuchet MS");
   
   CreateButton("Pos_Btn_50", "50%", 0, 0, 35, 28, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_50", OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, PREFIX + "Pos_Btn_50", OBJPROP_FONT, "Trebuchet MS");
   
   CreateButton("Pos_Btn_100", "100%", 0, 0, 35, 28, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_100", OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, PREFIX + "Pos_Btn_100", OBJPROP_FONT, "Trebuchet MS");
   
   CreateEdit("Pos_Edit_Close", "0", 0, 0, 45, 28);
   
   // 7. Validate
   CreateButton("Pos_Btn_Validate", "VALIDATE", 0, 0, width - 40, 45, g_ColorBtnInvalid, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Validate", OBJPROP_FONTSIZE, 11);
   ObjectSetString(0, PREFIX + "Pos_Btn_Validate", OBJPROP_FONT, "Trebuchet MS Bold");
 
   if(g_PanelPositions.IsVisible)
   {
      UpdatePositionsLayout();
      UpdatePositionsValues();
   }
}
