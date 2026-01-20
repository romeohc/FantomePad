//+------------------------------------------------------------------+
//|                                           Panel_Positions.mqh    |
//|                                                MagicKey Project  |
//+------------------------------------------------------------------+
#property strict

// --- TRACKING GLOBALS ---
int    g_LastPosTicket = -1;
double g_LastPosSL = -1.0;
double g_LastPosTP = -1.0;
bool   g_PosBE_Active = false;

//+------------------------------------------------------------------+
//| MISE A JOUR DU LAYOUT (POSITIONNEMENT)                           |
//+------------------------------------------------------------------+
void UpdatePositionsLayout()
{
   int startX = PositionsPanelX;
   int startY = PositionsPanelY;
   int width  = 280; 
   
   int paddingX = 20;
   int colGap   = 10;
   int colW     = (width - (paddingX * 2) - colGap) / 2; // ~115px
   
   int inputH   = 28;
   int lblH     = 15;
   int sectionGap = 15;
   
   int currentY = startY + 50; 
   
   // 1. Fond & Header
   SetObjPosition("Pos_Bg", startX, startY);
   SetObjPosition("Pos_Header", startX, startY);
   ObjectSetInteger(0, PREFIX + "Pos_Header", OBJPROP_XSIZE, width);
   SetObjPosition("Pos_Title", startX + 15, startY + 12);
   
   // 2. Select Button
   SetObjPosition("Pos_Btn_Select", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_XSIZE, width - (paddingX * 2));
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Select", OBJPROP_YSIZE, 30);
   
   currentY += 30 + sectionGap;

   // 3. Info Grid (2x2)
   // Row 1: Size & Profit
   SetObjPosition("Pos_Lbl_Size", startX + paddingX, currentY);
   SetObjPosition("Pos_Lbl_Profit", startX + paddingX + colW + colGap, currentY);
   
   currentY += lblH;
   
   SetObjPosition("Pos_Val_Size", startX + paddingX, currentY);
   SetObjPosition("Pos_Val_Profit", startX + paddingX + colW + colGap, currentY);
   
   currentY += 20 + 10; 
   
   // Row 2: Fees & Commission
   SetObjPosition("Pos_Lbl_Swap", startX + paddingX, currentY); 
   SetObjPosition("Pos_Lbl_Comm", startX + paddingX + colW + colGap, currentY);
   
   currentY += lblH;
   
   SetObjPosition("Pos_Val_Swap", startX + paddingX, currentY);
   SetObjPosition("Pos_Val_Comm", startX + paddingX + colW + colGap, currentY);
   
   currentY += 20 + 10;
   
   // Row 3: Risk
   SetObjPosition("Pos_Lbl_Risk", startX + paddingX, currentY);
   
   currentY += lblH;
   
   // 3 Value Columns
   int riskColW = (width - (paddingX * 2)) / 3;
   
   SetObjPosition("Pos_Val_Risk", startX + paddingX, currentY);
   SetObjPosition("Pos_Val_RiskR", startX + paddingX + riskColW, currentY);
   SetObjPosition("Pos_Val_RiskMoney", startX + paddingX + (riskColW * 2), currentY);
   
   currentY += 20 + sectionGap;
   
   // 4. SL & BE Section (Swapped TP with BE)
   SetObjPosition("Pos_Lbl_SL", startX + paddingX, currentY);
   // BE Button doesn't need external label, it's a button.
   // But we occupy the space.
   
   currentY += lblH;
   
   // SL Input (Left)
   SetObjPosition("Pos_Edit_SL", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Edit_SL", OBJPROP_XSIZE, colW);
   ObjectSetInteger(0, PREFIX + "Pos_Edit_SL", OBJPROP_YSIZE, inputH);
   
   // BE Button (Right) - Was TP Input
   SetObjPosition("Pos_Btn_BE", startX + paddingX + colW + colGap, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_XSIZE, colW); // Same width as input
   ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_YSIZE, inputH); // Same height
   
   currentY += inputH + sectionGap;
   
   // 5. TP Section (Full Width Below) - Was BE Button
   SetObjPosition("Pos_Lbl_TP", startX + paddingX, currentY);
   currentY += lblH;
   
   SetObjPosition("Pos_Edit_TP", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Edit_TP", OBJPROP_XSIZE, width - (paddingX * 2)); // Full width
   ObjectSetInteger(0, PREFIX + "Pos_Edit_TP", OBJPROP_YSIZE, inputH);
   
   currentY += inputH + sectionGap;

   // 6. Partial Close Section
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
   
   // 7. VALIDATE BUTTON
   SetObjPosition("Pos_Btn_Validate", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Validate", OBJPROP_XSIZE, width - (paddingX * 2));
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Validate", OBJPROP_YSIZE, 45); 
   
   currentY += 45 + 20; 
   
   // Ajustement hauteur fond
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
   CreateRect("Pos_Header", 0, 0, width, 40, g_ColorHeader, BORDER_FLAT);
   CreateLabel("Pos_Title", "Position Manager", 0, 0, 10, clrWhite, "Trebuchet MS Bold");
   
   // 2. Select Button
   CreateButton("Pos_Btn_Select", "Select Position", 0, 0, width - 40, 30, g_ColorInput, g_ColorText);
   ObjectSetString(0, PREFIX + "Pos_Btn_Select", OBJPROP_FONT, "Trebuchet MS Bold");
   
   // 3. Details (Grid) with Correct Casing
   CreateLabel("Pos_Lbl_Size", "Size", 0, 0, 8, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Pos_Val_Size", "-", 0, 0, 11, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Pos_Lbl_Profit", "Profit", 0, 0, 8, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Pos_Val_Profit", "-", 0, 0, 11, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Pos_Lbl_Swap", "Fees", 0, 0, 8, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Pos_Val_Swap", "-", 0, 0, 11, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Pos_Lbl_Comm", "Commission", 0, 0, 8, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Pos_Val_Comm", "-", 0, 0, 11, g_ColorText, "Trebuchet MS Bold");
   
   // Risk Section (Updated)
   CreateLabel("Pos_Lbl_Risk", "Risk", 0, 0, 8, g_ColorLabel, "Trebuchet MS");
   
   // 3 labels corresponding to %, R, Currency
   CreateLabel("Pos_Val_Risk", "-", 0, 0, 10, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Pos_Val_RiskR", "-", 0, 0, 10, g_ColorText, "Trebuchet MS Bold");
   CreateLabel("Pos_Val_RiskMoney", "-", 0, 0, 10, g_ColorText, "Trebuchet MS Bold");
   
   // 4. Protection (SL & BE)
   CreateLabel("Pos_Lbl_SL", "Stop loss", 0, 0, 8, g_ColorLabel, "Trebuchet MS");
   CreateEdit("Pos_Edit_SL", "0", 0, 0, 80, 28);
   
   // BE Button moved to right of SL
   CreateButton("Pos_Btn_BE", "BREAKEVEN", 0, 0, 35, 28, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_FONTSIZE, 8); // Smaller font for smaller button
   ObjectSetString(0, PREFIX + "Pos_Btn_BE", OBJPROP_FONT, "Trebuchet MS Bold");

   // 5. TP (Below)
   CreateLabel("Pos_Lbl_TP", "Take profit", 0, 0, 8, g_ColorLabel, "Trebuchet MS");
   CreateEdit("Pos_Edit_TP", "0", 0, 0, 80, 28);
   
   // 6. Close Section
   CreateLabel("Pos_Lbl_Close", "Partial Close %", 0, 0, 8, g_ColorLabel, "Trebuchet MS");
   
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
   CreateButton("Pos_Btn_Validate", "VALIDATE", 0, 0, width - 40, 45, g_ColorBtnValid, clrWhite);
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
             double sl = OrderStopLoss();
             double tp = OrderTakeProfit();
             
             ObjectSetString(0, PREFIX + "Pos_Val_Size", OBJPROP_TEXT, DoubleToString(lots, 2));
             
             string sProfit = DoubleToString(profit, 2) + " " + AccountCurrency();
             ObjectSetString(0, PREFIX + "Pos_Val_Profit", OBJPROP_TEXT, sProfit);
             ObjectSetInteger(0, PREFIX + "Pos_Val_Profit", OBJPROP_COLOR, (profit >= 0) ? g_ColorGreen : g_ColorRed);
             
             string sComm = DoubleToString(comm, 2) + " " + AccountCurrency();
             ObjectSetString(0, PREFIX + "Pos_Val_Comm", OBJPROP_TEXT, sComm);
             
             string sSwap = DoubleToString(swap, 2) + " " + AccountCurrency();
             ObjectSetString(0, PREFIX + "Pos_Val_Swap", OBJPROP_TEXT, sSwap);
             
             // --- RISK CALCULATION ---
             string sRisk = "-";
             string sRiskR = "-";
             string sRiskMoney = "-";
             
             if(sl > 0)
             {
                 double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
                 double tickVal  = MarketInfo(Symbol(), MODE_TICKVALUE);
                 if(tickSize > 0)
                 {
                     double dist = MathAbs(OrderOpenPrice() - sl);
                     double riskValMoney = (dist / tickSize) * tickVal * lots;
                     
                     sRiskMoney = DoubleToString(riskValMoney, 2) + " " + AccountCurrency();
                     
                     double bal = AccountBalance();
                     if(bal > 0) {
                        double riskPrc = (riskValMoney / bal) * 100.0;
                        sRisk = DoubleToString(riskPrc, 2) + " %";
                        
                        if(g_OneRPercent > 0) {
                           double riskR = riskPrc / g_OneRPercent;
                           sRiskR = DoubleToString(riskR, 2) + " R";
                        }
                     }
                 }
             }
             else 
             {
                sRisk = "No SL";
                sRiskR = "-"; 
                sRiskMoney = "-";
             }
             
             ObjectSetString(0, PREFIX + "Pos_Val_Risk", OBJPROP_TEXT, sRisk);
             ObjectSetString(0, PREFIX + "Pos_Val_RiskR", OBJPROP_TEXT, sRiskR);
             ObjectSetString(0, PREFIX + "Pos_Val_RiskMoney", OBJPROP_TEXT, sRiskMoney);
             
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
             
             if(ticketChanged)
             {
                 g_PosBE_Active = false;
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, g_ColorInput);
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, g_ColorText);
             }
             
             g_LastPosTicket = SelectedPositionTicket;
             
             string type = (OrderType() == OP_BUY) ? "BUY" : "SELL";
             ObjectSetString(0, PREFIX + "Pos_Btn_Select", OBJPROP_TEXT, "#" + IntegerToString(SelectedPositionTicket) + " " + type);
             return; 
         }
      }
      
      SelectedPositionTicket = -1;
      g_LastPosTicket = -1;
   }
   
   ObjectSetString(0, PREFIX + "Pos_Btn_Select", OBJPROP_TEXT, "Select Position...");
   ObjectSetString(0, PREFIX + "Pos_Val_Size", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_Profit", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT, "0");
   ObjectSetString(0, PREFIX + "Pos_Edit_TP", OBJPROP_TEXT, "0");
   ObjectSetString(0, PREFIX + "Pos_Val_Comm", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_Swap", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_Risk", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_RiskR", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_RiskMoney", OBJPROP_TEXT, "-");
   ObjectSetInteger(0, PREFIX + "Pos_Val_Profit", OBJPROP_COLOR, g_ColorText);
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
   
   SetObjVisible("Pos_Lbl_Size", visible);
   SetObjVisible("Pos_Val_Size", visible);
   
   SetObjVisible("Pos_Lbl_Profit", visible);
   SetObjVisible("Pos_Val_Profit", visible);
   
   SetObjVisible("Pos_Lbl_SL", visible);
   SetObjVisible("Pos_Edit_SL", visible);
   
   SetObjVisible("Pos_Lbl_TP", visible);
   SetObjVisible("Pos_Edit_TP", visible);
   
   SetObjVisible("Pos_Btn_BE", visible);
   
   SetObjVisible("Pos_Lbl_Comm", visible);
   SetObjVisible("Pos_Val_Comm", visible);
   
   SetObjVisible("Pos_Lbl_Swap", visible);
   SetObjVisible("Pos_Val_Swap", visible);
   
   SetObjVisible("Pos_Lbl_Risk", visible);
   SetObjVisible("Pos_Val_Risk", visible);
   SetObjVisible("Pos_Val_RiskR", visible);
   SetObjVisible("Pos_Val_RiskMoney", visible);
   
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
         if(OrderSymbol() == Symbol() && (OrderType() == OP_BUY || OrderType() == OP_SELL))
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
      ObjectSetInteger(0, PREFIX + "PosListContainer", OBJPROP_BORDER_COLOR, g_ColorHeader);
      
      CreateButton("PosListItem_None", "No Positions", (int)x + 2, startY, (int)w - 4, itemHeight, g_ColorInput, g_ColorLabel);
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
   ObjectSetInteger(0, PREFIX + "PosListContainer", OBJPROP_BORDER_COLOR, g_ColorHeader);
   
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
         string type = (OrderType() == OP_BUY) ? "BUY" : "SELL";
         string txt = "#" + IntegerToString(tck) + " " + type + " " + DoubleToString(OrderLots(), 2);
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
       
       CreateRect("PosListScrollTrack", trackX, trackY, scrollBarWidth, trackH, g_ColorHeader, BORDER_FLAT);
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
