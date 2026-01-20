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
   int width  = 220; 
   
   int paddingX = 20;
   int sectionGap = 15;
   int currentY = startY + 50; 
   
   // 1. Fond & Header
   SetObjPosition("Pos_Bg", startX, startY);
   SetObjPosition("Pos_Header", startX, startY);
   SetObjPosition("Pos_Title", startX + 15, startY + 12);
   
   ObjectSetInteger(0, PREFIX + "Pos_Bg", OBJPROP_XSIZE, width);
   ObjectSetInteger(0, PREFIX + "Pos_Header", OBJPROP_XSIZE, width);
   
   // 2. Select Button
   SetObjPosition("Pos_Btn_Select", startX + paddingX, currentY);
   currentY += 25 + sectionGap;

   // 3. Info Labels
   // Size
   SetObjPosition("Pos_Lbl_Size", startX + paddingX, currentY);
   currentY += 12;
   SetObjPosition("Pos_Val_Size", startX + paddingX, currentY);
   currentY += 20 + 5;

   // Profit
   SetObjPosition("Pos_Lbl_Profit", startX + paddingX, currentY);
   currentY += 12;
   SetObjPosition("Pos_Val_Profit", startX + paddingX, currentY);
   currentY += 20 + sectionGap; // Extra gap before inputs
   
   // SL / TP Inputs
   int inputW = (width - (paddingX * 2) - 10) / 2;
   
   // SL
   SetObjPosition("Pos_Lbl_SL", startX + paddingX, currentY);
   SetObjPosition("Pos_Btn_BE", startX + paddingX + 65, currentY); // BE Button
   SetObjPosition("Pos_Edit_SL", startX + paddingX, currentY + 12);
   ObjectSetInteger(0, PREFIX + "Pos_Edit_SL", OBJPROP_XSIZE, inputW);
   
   // TP
    SetObjPosition("Pos_Lbl_TP", startX + paddingX + inputW + 10, currentY);
   SetObjPosition("Pos_Edit_TP", startX + paddingX + inputW + 10, currentY + 12);
   ObjectSetInteger(0, PREFIX + "Pos_Edit_TP", OBJPROP_XSIZE, inputW);
   
   currentY += 12 + 25 + sectionGap;
   
   // Commission
   SetObjPosition("Pos_Lbl_Comm", startX + paddingX, currentY);
   currentY += 12;
   SetObjPosition("Pos_Val_Comm", startX + paddingX, currentY);
   currentY += 20 + 5;
   
   // Swap
   SetObjPosition("Pos_Lbl_Swap", startX + paddingX, currentY);
   currentY += 12;
   SetObjPosition("Pos_Val_Swap", startX + paddingX, currentY);
   currentY += 20 + sectionGap;

   // --- CLOSE SECTION ---
   SetObjPosition("Pos_Lbl_Close", startX + paddingX, currentY);
   currentY += 15;
   
   // 25% 50% 100% Buttons and Custom Edit
   int btnW = 35;
   int gap = 5;
   int rowX = startX + paddingX;
   
   SetObjPosition("Pos_Btn_25", rowX, currentY);
   rowX += btnW + gap;
   SetObjPosition("Pos_Btn_50", rowX, currentY);
   rowX += btnW + gap;
   SetObjPosition("Pos_Btn_100", rowX, currentY);
   rowX += btnW + gap + 5;
   SetObjPosition("Pos_Edit_Close", rowX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Edit_Close", OBJPROP_XSIZE, 45); 
   
   currentY += 25 + sectionGap;
   
   // VALIDATE BUTTON
   SetObjPosition("Pos_Btn_Validate", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_Validate", OBJPROP_XSIZE, width - (paddingX * 2));
   
   currentY += 30 + 5;
   
   // Ajustement hauteur fond
   int totalHeight = currentY - startY + 10;
   ObjectSetInteger(0, PREFIX + "Pos_Bg", OBJPROP_YSIZE, totalHeight);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| CRÉATION DES OBJETS                                              |
//+------------------------------------------------------------------+
void CreatePositionsPanel()
{
   int width = 220;
   
   // 1. Fond & Header
   CreateRect("Pos_Bg", 0, 0, width, 100, g_ColorBg, BORDER_FLAT); 
   CreateRect("Pos_Header", 0, 0, width, 40, g_ColorHeader, BORDER_FLAT);
   CreateLabel("Pos_Title", "Position Manager", 0, 0, 10, clrWhite, "Trebuchet MS Bold");
   
   // 2. Select Button
   CreateButton("Pos_Btn_Select", "Select Position", 0, 0, width - 40, 25, g_ColorInput, g_ColorText);
   
   // 3. Details
   CreateLabel("Pos_Lbl_Size", "SIZE", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Pos_Val_Size", "-", 0, 0, 10, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Pos_Lbl_Profit", "PROFIT", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Pos_Val_Profit", "-", 0, 0, 10, g_ColorText, "Trebuchet MS Bold");
   
   // SL/TP Edits (using width=80 placeholder, resized in layout)
   CreateLabel("Pos_Lbl_SL", "STOP LOSS", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateButton("Pos_Btn_BE", "BE", 0, 0, 20, 12, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_FONTSIZE, 7);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BORDER_COLOR, g_ColorInput); // Remove border visual if needed or match input
   CreateEdit("Pos_Edit_SL", "0", 0, 0, 80, 25);
   
   CreateLabel("Pos_Lbl_TP", "TAKE PROFIT", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateEdit("Pos_Edit_TP", "0", 0, 0, 80, 25);
   
   CreateLabel("Pos_Lbl_Comm", "COMMISSION", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Pos_Val_Comm", "-", 0, 0, 10, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Pos_Lbl_Swap", "FEES", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Pos_Val_Swap", "-", 0, 0, 10, g_ColorText, "Trebuchet MS Bold");
   
   // Close Section
   CreateLabel("Pos_Lbl_Close", "PARTIAL CLOSE (%)", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateButton("Pos_Btn_25", "25", 0, 0, 35, 22, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_25", OBJPROP_FONTSIZE, 8);
   
   CreateButton("Pos_Btn_50", "50", 0, 0, 35, 22, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_50", OBJPROP_FONTSIZE, 8);
   
   CreateButton("Pos_Btn_100", "100", 0, 0, 35, 22, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Pos_Btn_100", OBJPROP_FONTSIZE, 8);
   
   CreateEdit("Pos_Edit_Close", "0", 0, 0, 45, 22);
   
   // Validate
   CreateButton("Pos_Btn_Validate", "VALIDATE", 0, 0, width - 40, 30, g_ColorBtnValid, clrWhite);

   
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
   
   // Check if ticket is still valid and matches symbol
   if(SelectedPositionTicket != -1)
   {
      if(OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
      {
         // Verify it's still open and matches symbol (optional, but good practice)
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
             
             // UPDATE SL/TP INPUTS ONLY IF CHANGED (PREVENTS TYPING INTERRUPT)
             bool ticketChanged = (SelectedPositionTicket != g_LastPosTicket);
             
             // Check SL
             if(ticketChanged || MathAbs(sl - g_LastPosSL) > Point)
             {
                 ObjectSetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT, DoubleToString(sl, Digits));
                 g_LastPosSL = sl;
             }
             
             // Check TP
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
             
             // Button Label
             string type = (OrderType() == OP_BUY) ? "BUY" : "SELL";
             ObjectSetString(0, PREFIX + "Pos_Btn_Select", OBJPROP_TEXT, "#" + IntegerToString(SelectedPositionTicket) + " " + type);
             return; 
         }
      }
      
      // If we reach here, position is invalid/closed
      SelectedPositionTicket = -1;
      g_LastPosTicket = -1;
   }
   
   // Default State
   ObjectSetString(0, PREFIX + "Pos_Btn_Select", OBJPROP_TEXT, "Select Position...");
   ObjectSetString(0, PREFIX + "Pos_Val_Size", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_Profit", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT, "0");
   ObjectSetString(0, PREFIX + "Pos_Edit_TP", OBJPROP_TEXT, "0");
   ObjectSetString(0, PREFIX + "Pos_Val_Comm", OBJPROP_TEXT, "-");
   ObjectSetString(0, PREFIX + "Pos_Val_Swap", OBJPROP_TEXT, "-");
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
   SetObjVisible("Pos_Btn_BE", visible);
   SetObjVisible("Pos_Edit_SL", visible);
   
   SetObjVisible("Pos_Lbl_TP", visible);
   SetObjVisible("Pos_Edit_TP", visible);
   
   SetObjVisible("Pos_Lbl_Comm", visible);
   SetObjVisible("Pos_Val_Comm", visible);
   
   SetObjVisible("Pos_Lbl_Swap", visible);
   SetObjVisible("Pos_Val_Swap", visible);
   
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
   
   // 1. Collect Tickets for Current Symbol
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
      // Show "No Positions" item? Or just don't open?
      // Let's show a single disabled item "No Positions"
      ClosePositionList(); // Clear old
      
      int itemHeight = 25;
      int startY = (int)y + (int)h + 2; 
      CreateRect("PosListContainer", (int)x, startY - 2, (int)w, itemHeight + 4, g_ColorBg, BORDER_FLAT);
      ObjectSetInteger(0, PREFIX + "PosListContainer", OBJPROP_ZORDER, 15);
      ObjectSetInteger(0, PREFIX + "PosListContainer", OBJPROP_BORDER_COLOR, g_ColorHeader);
      
      CreateButton("PosListItem_None", "No Positions", (int)x + 2, startY, (int)w - 4, itemHeight, g_ColorInput, g_ColorLabel);
      ObjectSetInteger(0, PREFIX + "PosListItem_None", OBJPROP_ZORDER, 16);
      ObjectSetInteger(0, PREFIX + "PosListItem_None", OBJPROP_STATE, false); // Not clickable really
      IsPosListOpen = true;
      return; 
   }
   
   int itemHeight = 25;
   int scrollBarWidth = 10;
   
   // Determine visible count
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
   
   // SCROLLBAR (Simplified, non-interactive for now or copy generic logic if critical)
   // For now, if > 10 positions, just showing first 10 is acceptable mostly, 
   // but I will add visual scrollbar if dragged in Master.
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
