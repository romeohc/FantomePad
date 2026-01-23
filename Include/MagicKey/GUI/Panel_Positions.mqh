//+------------------------------------------------------------------+
//|                                           Panel_Positions.mqh    |
//|                                                MagicKey Project  |
//+------------------------------------------------------------------+
#property strict

// --- TRACKING GLOBALS ---
int    g_LastPosTicket = -1;
double g_LastPosSL = -1.0;
double g_LastPosTP = -1.0;
double g_LastPosEntry = -1.0;
bool   g_PosBE_Active = false;
int    g_PosPartialMode = 0; // 0, 25, 50, 100

//+------------------------------------------------------------------+
//| HELPER: VISUAL UPDATE FOR PARTIAL BUTTONS                        |
//+------------------------------------------------------------------+
void UpdatePartialButtonsVisuals()
{
   color activeCol = g_ColorBtnValid; // Fallback
   if(SelectedPositionTicket != -1 && OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
   {
      int type = OrderType();
      activeCol = (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP) ? g_ColorGreen : g_ColorRed;
   }

   // Button 25
   bool is25 = (g_PosPartialMode == 25);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_25", OBJPROP_BGCOLOR, is25 ? activeCol : g_ColorInput);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_25", OBJPROP_COLOR, is25 ? clrWhite : g_ColorText);
   
   // Button 50
   bool is50 = (g_PosPartialMode == 50);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_50", OBJPROP_BGCOLOR, is50 ? activeCol : g_ColorInput);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_50", OBJPROP_COLOR, is50 ? clrWhite : g_ColorText);

   // Button 100
   bool is100 = (g_PosPartialMode == 100);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_100", OBJPROP_BGCOLOR, is100 ? activeCol : g_ColorInput);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_100", OBJPROP_COLOR, is100 ? clrWhite : g_ColorText);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| MISE A JOUR DU LAYOUT (POSITIONNEMENT)                           |
//+------------------------------------------------------------------+
void UpdatePositionsLayout()
{
   int startX = PositionsPanelX;
   int startY = PositionsPanelY;
   int width  = 280; 
   int paddingX = 20;
   
   // --- Header ---
   SetObjPosition("Pos_Bg", startX, startY);
   SetObjPosition("Pos_Header", startX, startY);
   ObjectSetInteger(0, PREFIX + "Pos_Header", OBJPROP_XSIZE, width);
   SetObjPosition("Pos_Title", startX + 15, startY + 12);
   
   int currentY = startY + 50; 
   
   // --- Select Key ---
   SetObjPosition("Pos_Btn_Select", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_XSIZE, width - (paddingX * 2));
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_YSIZE, 30);
   currentY += 30 + 15;
   
   // --- STATS GRID (Modern Look) ---
   // Calculs de géométrie
   int statsBgH = 175; // Increased from 135 to 175 for extra row
   int statsY = currentY;
   
   // Background Stats
   SetObjPosition("Pos_Stats_Bg", startX + paddingX, statsY);
   ObjectSetInteger(0, PREFIX + "Pos_Stats_Bg", OBJPROP_XSIZE, width - (paddingX * 2));
   ObjectSetInteger(0, PREFIX + "Pos_Stats_Bg", OBJPROP_YSIZE, statsBgH);
   
   // Internal Grid Padding
   int gridPadX = 15;
   int gridPadY = 10;
   int colW = (width - (paddingX*2) - (gridPadX*2)) / 2; // ~100px
   int startGridX = startX + paddingX + gridPadX;
   int startGridY = statsY + gridPadY;
   
   // ROW 1: SIZE | PROFIT
   // Size
   SetObjPosition("Pos_Lbl_Size", startGridX, startGridY);
   SetObjPosition("Pos_Val_Size", startGridX, startGridY + 15);
   
   // Profit (Right Aligned visually or 2nd Col)
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
   
   // --- Protection Section ---
   int inputH   = 28;
   int lblH     = 15;
   int sectionGap = 15;
   
   // --- Entry Price ---
   SetObjPosition("Pos_Lbl_Entry", startX + paddingX, currentY);
   currentY += lblH;
   
   SetObjPosition("Pos_Edit_Entry", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_XSIZE, width - (paddingX * 2));
   ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_YSIZE, inputH);
   
   currentY += inputH + sectionGap;

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
   ObjectSetInteger(0, PREFIX + "Pos_Edit_Close", OBJPROP_XSIZE, pcBtnW);
   ObjectSetInteger(0, PREFIX + "Pos_Edit_Close", OBJPROP_YSIZE, inputH);
   
   currentY += inputH + (sectionGap * 1.5); 
   
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
   
   // 1. Fond & Header
   CreateRect("Pos_Bg", 0, 0, width, 100, g_ColorBg, BORDER_FLAT); 
   CreateRect("Pos_Header", 0, 0, width, 40, g_ColorBg, BORDER_FLAT);
   CreateLabel("Pos_Title", "Position Manager", 0, 0, 10, g_ColorText, "Trebuchet MS Bold");
   
   // 2. Select Button
   CreateButton("Pos_Btn_Select", "Select Position", 0, 0, width - 40, 30, g_ColorInput, g_ColorText);
   ObjectSetString(0, PREFIX + "Pos_Btn_Select", OBJPROP_FONT, "Trebuchet MS Bold");
   
   // 3. STATS CARD (Grouped)
   CreateRect("Pos_Stats_Bg", 0, 0, width - 40, 175, g_ColorInput, BORDER_FLAT); // Background for stats (Increased height)
   ObjectSetInteger(0, PREFIX + "Pos_Stats_Bg", OBJPROP_BORDER_COLOR, g_ColorInput);
   
   // Labels: uniform size (7 or 8), Muted Color
   // Values: uniform size (10 or 11), Bold, Bright Color
   
   CreateLabel("Pos_Lbl_Size", "SIZE", 0, 0, 7, g_ColorText, "Trebuchet MS");
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
   
   // Risk Section (Split Columns)
   CreateLabel("Pos_Lbl_RiskR", "RISK R", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Pos_Val_RiskR", "-", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Pos_Lbl_RiskPrc", "RISK %", 0, 0, 7, g_ColorText, "Trebuchet MS");
   CreateLabel("Pos_Val_RiskPrc", "-", 0, 0, 9, g_ColorText, "Trebuchet MS Bold");
   
   // Cleanup Old Objects (Risk single line)
   if(ObjectFind(0, PREFIX + "Pos_Lbl_Risk") >= 0) ObjectDelete(0, PREFIX + "Pos_Lbl_Risk");
   if(ObjectFind(0, PREFIX + "Pos_Val_Risk") >= 0) ObjectDelete(0, PREFIX + "Pos_Val_Risk");
   // Cleanup pre-previous objects just in case
   if(ObjectFind(0, PREFIX + "Pos_Val_RiskMoney") >= 0) ObjectDelete(0, PREFIX + "Pos_Val_RiskMoney");
   
   // 4. Entry Price
   CreateLabel("Pos_Lbl_Entry", "Entry Price", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Pos_Edit_Entry", "0", 0, 0, width - 40, 28);

   // 5. Protection (SL & BE)
   CreateLabel("Pos_Lbl_SL", "Stop loss", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Pos_Edit_SL", "0", 0, 0, 80, 28);
   
   // BE Button moved to right of SL
   CreateButton("Pos_Btn_BE", "BREAKEVEN", 0, 0, 35, 28, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_FONTSIZE, 8); // Smaller font for smaller button
   ObjectSetString(0, PREFIX + "Pos_Btn_BE", OBJPROP_FONT, "Trebuchet MS Bold");

   // 5. TP (Below)
   CreateLabel("Pos_Lbl_TP", "Take profit", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Pos_Edit_TP", "0", 0, 0, 80, 28);
   
   // 6. Close Section
   CreateLabel("Pos_Lbl_Close", "Partial Close %", 0, 0, 8, g_ColorText, "Trebuchet MS");
   
   CreateButton("Pos_Btn_25", "25", 0, 0, 35, 28, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_25", OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, PREFIX + "Pos_Btn_25", OBJPROP_FONT, "Trebuchet MS");
   
   CreateButton("Pos_Btn_50", "50", 0, 0, 35, 28, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_50", OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, PREFIX + "Pos_Btn_50", OBJPROP_FONT, "Trebuchet MS");
   
   CreateButton("Pos_Btn_100", "100", 0, 0, 35, 28, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_100", OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, PREFIX + "Pos_Btn_100", OBJPROP_FONT, "Trebuchet MS");
   
   CreateEdit("Pos_Edit_Close", "0", 0, 0, 45, 28);
   
   // 7. Validate
   CreateButton("Pos_Btn_Validate", "VALIDATE", 0, 0, width - 40, 45, g_ColorBtnValid, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Validate", OBJPROP_FONTSIZE, 11);
   ObjectSetString(0, PREFIX + "Pos_Btn_Validate", OBJPROP_FONT, "Trebuchet MS Bold");

   if(IsPositionsPanelVisible)
   {
      UpdatePositionsLayout();
      UpdatePositionsValues();
   }
   else
   {
      TogglePositionsPanel(false);
   }
}

//+------------------------------------------------------------------+
//| MISE A JOUR DES VALEURS (TICK)                                   |
//+------------------------------------------------------------------+
void UpdatePositionsValues()
{
   if(!IsPositionsPanelVisible) return;
   
   if(SelectedPositionTicket != -1)
   {
      if(OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
      {
         if(OrderCloseTime() == 0 && OrderSymbol() == Symbol())
         {
             double lots = OrderLots();
             double profit = OrderProfit();
             double comm = OrderCommission();
             double swap = OrderSwap();
             double open = OrderOpenPrice();
             double sl = OrderStopLoss();
             double tp = OrderTakeProfit();
             
             ObjectSetString(0, PREFIX + "Pos_Val_Size", OBJPROP_TEXT, DoubleToString(lots, 2));
             
             string sProfit = DoubleToString(profit, 2) + " " + AccountCurrency();
             ObjectSetString(0, PREFIX + "Pos_Val_Profit", OBJPROP_TEXT, sProfit);
             ObjectSetInteger(0, PREFIX + "Pos_Val_Profit", OBJPROP_COLOR, (profit >= 0) ? g_ColorGreen : g_ColorRed);

             double bal = AccountBalance();
             double profitPrc = 0.0;
             double profitR = 0.0;
             if(bal > 0) profitPrc = (profit / bal) * 100.0;
             if(g_OneRPercent > 0) profitR = profitPrc / g_OneRPercent;
             
             string sProfitR = DoubleToString(profitR, 2) + " R";
             ObjectSetString(0, PREFIX + "Pos_Val_ProfitR", OBJPROP_TEXT, sProfitR);
             ObjectSetInteger(0, PREFIX + "Pos_Val_ProfitR", OBJPROP_COLOR, (profit >= 0) ? g_ColorGreen : g_ColorRed);

             string sProfitPrc = DoubleToString(profitPrc, 2) + "%";
             ObjectSetString(0, PREFIX + "Pos_Val_ProfitPrc", OBJPROP_TEXT, sProfitPrc);
             ObjectSetInteger(0, PREFIX + "Pos_Val_ProfitPrc", OBJPROP_COLOR, (profit >= 0) ? g_ColorGreen : g_ColorRed);
             
             string sComm = DoubleToString(comm, 2) + " " + AccountCurrency();
             ObjectSetString(0, PREFIX + "Pos_Val_Comm", OBJPROP_TEXT, sComm);
             
             string sSwap = DoubleToString(swap, 2) + " " + AccountCurrency();
             ObjectSetString(0, PREFIX + "Pos_Val_Swap", OBJPROP_TEXT, sSwap);
             
             // --- RISK CALCULATION ---
             string sRiskR = "-";
             string sRiskPrc = "-";
             
             if(sl > 0)
             {
                 double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
                 double tickVal  = MarketInfo(Symbol(), MODE_TICKVALUE);
                 if(tickSize > 0)
                 {
                     double dist = MathAbs(OrderOpenPrice() - sl);
                     double riskValMoney = (dist / tickSize) * tickVal * lots;
                     
                     bal = AccountBalance();
                     if(bal > 0) {
                        double riskPrc = (riskValMoney / bal) * 100.0;
                        sRiskPrc = DoubleToString(riskPrc, 2) + "%";
                        
                        if(g_OneRPercent > 0) {
                           double riskRVal = riskPrc / g_OneRPercent;
                           sRiskR = DoubleToString(riskRVal, 2) + " R";
                        }
                     }
                 }
             }
             else 
             {
                sRiskR = "-";
                sRiskPrc = "No SL";
             }
             
             ObjectSetString(0, PREFIX + "Pos_Val_RiskR", OBJPROP_TEXT, sRiskR);
             ObjectSetString(0, PREFIX + "Pos_Val_RiskPrc", OBJPROP_TEXT, sRiskPrc);
             // Removed Pos_Val_RiskR and Money separate updates

             
             bool ticketChanged = (SelectedPositionTicket != g_LastPosTicket);
             
             if(ticketChanged || MathAbs(sl - g_LastPosSL) > Point)
             {
                 ObjectSetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT, DoubleToString(sl, Digits));
                 g_LastPosSL = sl;
             }
             
             if(ticketChanged || MathAbs(tp - g_LastPosTP) > Point)
             {
                 ObjectSetString(0, PREFIX + "Pos_Edit_TP", OBJPROP_TEXT, DoubleToString(tp, Digits));
                 g_LastPosTP = tp;
             }
             
             if(ticketChanged || MathAbs(open - g_LastPosEntry) > Point)
             {
                 ObjectSetString(0, PREFIX + "Pos_Edit_Entry", OBJPROP_TEXT, DoubleToString(open, Digits));
                 g_LastPosEntry = open;
             }
             
             if(ticketChanged)
             {
                 g_PosBE_Active = false;
                 g_PosPartialMode = 0; // Reset Partial Mode
                 UpdatePartialButtonsVisuals(); // Visually reset
                 
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, g_ColorInput);
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, g_ColorText);
             }
             
             string typeStr = "";
             color typeBg = g_ColorInput;
             int type = OrderType();
             
             if(type == OP_BUY) { typeStr = "BUY MARKET"; typeBg = g_ColorGreen; }
             else if(type == OP_SELL) { typeStr = "SELL MARKET"; typeBg = g_ColorRed; }
             else if(type == OP_BUYLIMIT) { typeStr = "BUY LIMIT"; typeBg = g_ColorGreen; }
             else if(type == OP_SELLLIMIT) { typeStr = "SELL LIMIT"; typeBg = g_ColorRed; }
             else if(type == OP_BUYSTOP) { typeStr = "BUY STOP"; typeBg = g_ColorGreen; }
             else if(type == OP_SELLSTOP) { typeStr = "SELL STOP"; typeBg = g_ColorRed; }
             
             ObjectSetString(0, PREFIX + "Pos_Btn_Select", OBJPROP_TEXT, typeStr + " " + DoubleToString(lots, 2));
             ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_BGCOLOR, typeBg);
             ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_BORDER_COLOR, typeBg);
             ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_COLOR, clrWhite);
             
             // Enable/Disable Entry Price Edit based on Type
             if(type <= 1) // Market Order (OP_BUY=0, OP_SELL=1)
             {
                 ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_READONLY, true);
                 ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_BGCOLOR, g_ColorBtnInvalid); // INACTIVE COLOR
                 ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_COLOR, g_ColorText); 
             }
             else // Pending Order
             {
                 ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_READONLY, false);
                 ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_BGCOLOR, g_ColorInput);
                 ObjectSetInteger(0, PREFIX + "Pos_Edit_Entry", OBJPROP_COLOR, g_ColorText);
             }
             
             // BE BUTTON STATE (IN LOSS CHECKS)
             double current = (type == OP_BUY) ? MarketInfo(OrderSymbol(), MODE_BID) : MarketInfo(OrderSymbol(), MODE_ASK);
             bool inLoss = (type == OP_BUY && current < open) || (type == OP_SELL && current > open);
             
             if(inLoss)
             {
                 g_PosBE_Active = false; // Force Disable
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, g_ColorBtnInvalid); // INACTIVE COLOR
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, g_ColorText); 
             }
             else if(!g_PosBE_Active)
             {
                 // If eligible but not active, ensure inputs color (normal state)
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, g_ColorInput);
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, g_ColorText);
             }
             // If Active, color is handled by toggle logic (Green/Red) and preserved here implicitly
             
             // Update Validate Button State
             double userSL = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT));
             double userTP = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_TP", OBJPROP_TEXT));
             double userEntry = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_Entry", OBJPROP_TEXT));
             double userClose = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT));
             
             bool isModified = false;
             
             if(MathAbs(userSL - sl) > Point) isModified = true;
             if(MathAbs(userTP - tp) > Point) isModified = true;
             
             // Check Entry (Only for Pending Orders)
             if(type > 1) 
             {
                 if(MathAbs(userEntry - open) > Point) isModified = true;
             }
             
             // Check Partial Close
             if(userClose > 0.001) isModified = true;
             if(g_PosPartialMode > 0) isModified = true; // Button Active = Modified
             if(g_PosBE_Active) isModified = true; // BE Active = Modified
             
             color valCol = g_ColorBtnInvalid;
             if(isModified)
             {
                 valCol = (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP) ? g_ColorGreen : g_ColorRed;
             }
             
             ObjectSetInteger(0, PREFIX + "Pos_Btn_Validate", OBJPROP_BGCOLOR, valCol);
             ObjectSetInteger(0, PREFIX + "Pos_Btn_Validate", OBJPROP_BORDER_COLOR, valCol);
             
             g_LastPosTicket = SelectedPositionTicket;
             return; 
         }
      }
      
      SelectedPositionTicket = -1;
      g_LastPosTicket = -1;
   }
   
   ObjectSetString(0, PREFIX + "Pos_Btn_Select", OBJPROP_TEXT, "Select Position...");
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_BGCOLOR, g_ColorInput);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_BORDER_COLOR, g_ColorInput);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_COLOR, g_ColorText);
   
   ObjectSetString(0, PREFIX + "Pos_Val_Size", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_Profit", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_ProfitR", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_ProfitPrc", OBJPROP_TEXT, "-");
   ObjectSetInteger(0, PREFIX + "Pos_Val_ProfitR", OBJPROP_COLOR, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Val_ProfitPrc", OBJPROP_COLOR, g_ColorText);
   ObjectSetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT, "0");
   ObjectSetString(0, PREFIX + "Pos_Edit_Entry", OBJPROP_TEXT, "0");
   ObjectSetString(0, PREFIX + "Pos_Edit_TP", OBJPROP_TEXT, "0");
   ObjectSetString(0, PREFIX + "Pos_Val_Comm", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_Swap", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_RiskR", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_RiskPrc", OBJPROP_TEXT, "-");
   ObjectSetInteger(0, PREFIX + "Pos_Val_Profit", OBJPROP_COLOR, g_ColorText);
   
   // Update Validate Button to Inactive
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Validate", OBJPROP_BGCOLOR, g_ColorBtnInvalid);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Validate", OBJPROP_BORDER_COLOR, g_ColorBtnInvalid);
}


//+------------------------------------------------------------------+
//| VISIBILITY CONTROL                                               |
//+------------------------------------------------------------------+
void TogglePositionsPanel(bool visible)
{
   SetObjVisible("Pos_Bg", visible);
   SetObjVisible("Pos_Header", visible);
   SetObjVisible("Pos_Title", visible);
   SetObjVisible("Pos_Btn_Select", visible);
   SetObjVisible("Pos_Stats_Bg", visible); // New Stats Bg
   
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
   }
}

//+------------------------------------------------------------------+
//| GESTION LISTE POSITIONS                                         |
//+------------------------------------------------------------------+
void ClosePositionList()
{
   for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, PREFIX + "PosListItem_") >= 0 || 
         name == PREFIX + "PosListContainer" ||
         name == PREFIX + "PosListScrollTrack" || 
         name == PREFIX + "PosListScrollThumb") 
      {
         ObjectDelete(0, name);
      }
   }
   
   IsPosListOpen = false;
   g_PosListOffset = 0; 
   ChartRedraw();
}

void DrawPositionList()
{
   long x = ObjectGetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_XDISTANCE);
   long y = ObjectGetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_YDISTANCE);
   long w = ObjectGetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_XSIZE);
   long h = ObjectGetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_YSIZE);
   
   int tickets[];
   int count = 0;
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
          int type = OrderType();
          if(OrderSymbol() == Symbol() && (type == OP_BUY || type == OP_SELL || type == OP_BUYLIMIT || type == OP_SELLLIMIT || type == OP_BUYSTOP || type == OP_SELLSTOP))
          {
             ArrayResize(tickets, count+1);
             tickets[count] = OrderTicket();
             count++;
          }
      }
   }
   
   if(count == 0)
   {
      ClosePositionList();
      
      int itemHeight = 25;
      int startY = (int)y + (int)h + 2; 
      CreateRect("PosListContainer", (int)x, startY - 2, (int)w, itemHeight + 4, g_ColorBg, BORDER_FLAT);
      ObjectSetInteger(0, PREFIX + "PosListContainer", OBJPROP_ZORDER, 15);
      ObjectSetInteger(0, PREFIX + "PosListContainer", OBJPROP_BORDER_COLOR, g_ColorBg);
      
      CreateButton("PosListItem_None", "No Positions", (int)x + 2, startY, (int)w - 4, itemHeight, g_ColorInput, g_ColorText);
      ObjectSetInteger(0, PREFIX + "PosListItem_None", OBJPROP_ZORDER, 16);
      ObjectSetInteger(0, PREFIX + "PosListItem_None", OBJPROP_STATE, false);
      IsPosListOpen = true;
      return; 
   }
   
   int itemHeight = 25;
   int scrollBarWidth = 10;
   
   int maxVis = g_PosListMaxVisible;
   int visibleCount = (count > maxVis) ? maxVis : count;
   
   if(g_PosListOffset > count - visibleCount) g_PosListOffset = count - visibleCount;
   if(g_PosListOffset < 0) g_PosListOffset = 0;
   
   bool showScroll = (count > maxVis);
   
   int startY = (int)y + (int)h + 2; 
   int contentHeight = visibleCount * itemHeight;
   int containerWidth = (int)w;
   
   CreateRect("PosListContainer", (int)x, startY - 2, containerWidth, contentHeight + 4, g_ColorBg, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "PosListContainer", OBJPROP_ZORDER, 15);
   ObjectSetInteger(0, PREFIX + "PosListContainer", OBJPROP_BORDER_COLOR, g_ColorBg);
   
   int itemWidth = showScroll ? containerWidth - scrollBarWidth - 2 : containerWidth - 4;
   int itemX = (int)x + 2;
   int currentY = startY;
      for(int i = 0; i < visibleCount; i++)
    {
      int dataIdx = g_PosListOffset + i;
      if(dataIdx >= count) break;
      
      int tck = tickets[dataIdx];
      if(OrderSelect(tck, SELECT_BY_TICKET))
      {
         string typeStr = "";
         int type = OrderType();
         if(type == OP_BUY) typeStr = "BUY MARKET";
         else if(type == OP_SELL) typeStr = "SELL MARKET";
         else if(type == OP_BUYLIMIT) typeStr = "BUY LIMIT";
         else if(type == OP_SELLLIMIT) typeStr = "SELL LIMIT";
         else if(type == OP_BUYSTOP) typeStr = "BUY STOP";
         else if(type == OP_SELLSTOP) typeStr = "SELL STOP";

         string txt = typeStr + " " + DoubleToString(OrderLots(), 2);
         string btnName = "PosListItem_" + IntegerToString(tck);
         
         CreateButton(btnName, txt, itemX, currentY, itemWidth, itemHeight, g_ColorInput, g_ColorText);
         ObjectSetInteger(0, PREFIX + btnName, OBJPROP_ZORDER, 16);
         ObjectSetInteger(0, PREFIX + btnName, OBJPROP_BORDER_COLOR, g_ColorInput);
         
         currentY += itemHeight;
      }
   }
   
   if(showScroll)
   {
       int trackX = (int)x + containerWidth - scrollBarWidth - 2;
       int trackH = contentHeight;
       int trackY = startY;
       
       CreateRect("PosListScrollTrack", trackX, trackY, scrollBarWidth, trackH, g_ColorBg, BORDER_FLAT);
       ObjectSetInteger(0, PREFIX + "PosListScrollTrack", OBJPROP_ZORDER, 16);
       
       double ratio = (double)visibleCount / (double)count;
       int thumbH = (int)(trackH * ratio);
       if(thumbH < 20) thumbH = 20; 
       
       int maxOffset = count - visibleCount;
       double scrollPrc = (maxOffset > 0) ? (double)g_PosListOffset / (double)maxOffset : 0;
       int relativeY = (int)(scrollPrc * (trackH - thumbH));
       
       CreateRect("PosListScrollThumb", trackX + 1, trackY + relativeY, scrollBarWidth - 2, thumbH, g_ColorBtnValid, BORDER_FLAT);
       ObjectSetInteger(0, PREFIX + "PosListScrollThumb", OBJPROP_ZORDER, 17);
   }
   
   ChartRedraw();
}

void TogglePositionList()
{
   if(IsPosListOpen) ClosePositionList();
   else 
   {
      IsPosListOpen = true;
      DrawPositionList();
   }
}
