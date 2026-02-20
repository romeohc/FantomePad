#ifndef ACCOUNT_LAYOUT_MQH
#define ACCOUNT_LAYOUT_MQH

#property strict

#include "Account_Globals.mqh"

//+------------------------------------------------------------------+
//| HELPER: DRAW ORDERS SCROLLBAR                                    |
//+------------------------------------------------------------------+
void DrawAccountOrdersScrollbar(int trackX, int trackY, int trackH, int totalOrders, int maxVisible)
{
   int scrollBarWidth = 8;
   
   // 1. Track Background
   if(ObjectFind(0, PREFIX + "Account_Ord_ScrollTrack") < 0)
   {
      CreateRect("Account_Ord_ScrollTrack", trackX, trackY, scrollBarWidth, trackH, g_ColorBg, BORDER_FLAT);
   }
   SetObjPosition("Account_Ord_ScrollTrack", trackX, trackY);
   ObjectSetInteger(0, PREFIX + "Account_Ord_ScrollTrack", OBJPROP_XSIZE, scrollBarWidth);
   ObjectSetInteger(0, PREFIX + "Account_Ord_ScrollTrack", OBJPROP_YSIZE, trackH);
   ObjectSetInteger(0, PREFIX + "Account_Ord_ScrollTrack", OBJPROP_BGCOLOR, g_ColorBg);
   ObjectSetInteger(0, PREFIX + "Account_Ord_ScrollTrack", OBJPROP_BORDER_COLOR, g_ColorBg);
   ObjectSetInteger(0, PREFIX + "Account_Ord_ScrollTrack", OBJPROP_ZORDER, 16);
   
   // 2. Thumb
   double ratio = (double)maxVisible / (double)totalOrders;
   if(ratio > 1.0) ratio = 1.0;
   
   int thumbH = (int)(trackH * ratio);
   if(thumbH < 20) thumbH = 20; // Min size
   
   // Position
   int maxScroll = totalOrders - maxVisible;
   if(maxScroll <= 0) maxScroll = 1;
   
   double p = (double)g_AccountOrdersScrollOffset / (double)maxScroll;
   if(p < 0) p = 0;
   if(p > 1) p = 1;
   
   int thumbY = trackY + (int)(p * (trackH - thumbH));
   
   if(ObjectFind(0, PREFIX + "Account_Ord_ScrollThumb") < 0)
   {
      CreateButton("Account_Ord_ScrollThumb", "", trackX + 1, thumbY, scrollBarWidth - 2, thumbH, g_ColorText, clrNONE);
   }
   SetObjPosition("Account_Ord_ScrollThumb", trackX + 1, thumbY);
   ObjectSetInteger(0, PREFIX + "Account_Ord_ScrollThumb", OBJPROP_XSIZE, scrollBarWidth - 2);
   ObjectSetInteger(0, PREFIX + "Account_Ord_ScrollThumb", OBJPROP_YSIZE, thumbH);
   ObjectSetInteger(0, PREFIX + "Account_Ord_ScrollThumb", OBJPROP_BGCOLOR, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Account_Ord_ScrollThumb", OBJPROP_BORDER_COLOR, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Account_Ord_ScrollThumb", OBJPROP_ZORDER, 17);
}

//+------------------------------------------------------------------+
//| HELPER: HIDE ORDERS SCROLLBAR                                    |
//+------------------------------------------------------------------+
void HideAccountOrdersScrollbar()
{
   SetObjVisible("Account_Ord_ScrollTrack", false);
   SetObjVisible("Account_Ord_ScrollThumb", false);
}

//+------------------------------------------------------------------+
//| MISE A JOUR DU LAYOUT (POSITIONNEMENT)                           |
//+------------------------------------------------------------------+
void UpdateAccountLayout()
{
   if(!g_PanelAccount.IsVisible) return;
   
   int startX = g_PanelAccount.X;
   int startY = g_PanelAccount.Y;
   int width  = 260; // Wider Panel for better spacing
   
   int paddingX = 20;
   int rowH     = 28; // Height of an order row
   int gapY     = 4;  // Gap between rows
   int scrollBarWidth = 8;
   
   int currentY = startY + 50; 
   
   // --- HEAD & BG ---
   SetObjPosition("Account_Bg", startX, startY);
   SetObjPosition("Account_Header", startX, startY);
   SetObjPosition("Account_Title", startX + (width / 2), startY + 12);
   ObjectSetInteger(0, PREFIX + "Account_Title", OBJPROP_ANCHOR, ANCHOR_UPPER);
   
   ObjectSetInteger(0, PREFIX + "Account_Bg", OBJPROP_XSIZE, width);
   ObjectSetInteger(0, PREFIX + "Account_Header", OBJPROP_XSIZE, width);
   
   // --- ACCOUNT SECTION (GROUPED) ---
   int statsBgH = 200; // Reduced height to remove extra space (was 245)
   
   SetObjPosition("Account_Stats_Bg", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Account_Stats_Bg", OBJPROP_XSIZE, width - (paddingX*2));
   ObjectSetInteger(0, PREFIX + "Account_Stats_Bg", OBJPROP_YSIZE, statsBgH);
   
   int statsDescX = startX + paddingX + 15;
   int statsTopY  = currentY + 10;
   int colW  = (width - (paddingX*2) - 30) / 2;
   
   // Balance (Row 1 Left)
   SetObjPosition("Account_Lbl_Balance", statsDescX, statsTopY);
   SetObjPosition("Account_Val_Balance", statsDescX, statsTopY + 15);
   
   // PNL (Row 1 Right)
   SetObjPosition("Account_Lbl_PnL", statsDescX + colW, statsTopY);
   SetObjPosition("Account_Val_PnL", statsDescX + colW, statsTopY + 15);
   
   // --- ROW 2: ROI % & ROI R ---
   int row2Y = statsTopY + 45;
   
   // ROI % (Row 2 Left)
   SetObjPosition("Account_Lbl_PerfP", statsDescX, row2Y);
   SetObjPosition("Account_Val_PerfP", statsDescX, row2Y + 15);
   
   // ROI R (Row 2 Right)
   SetObjPosition("Account_Lbl_PerfR", statsDescX + colW, row2Y);
   SetObjPosition("Account_Val_PerfR", statsDescX + colW, row2Y + 15);
   
   // --- ROW 3: EQUITY & MARGIN ---
   int row3Y = row2Y + 45;
   
   // Equity (Left)
   SetObjPosition("Account_Lbl_Equity", statsDescX, row3Y);
   SetObjPosition("Account_Val_Equity", statsDescX, row3Y + 15);
   
   // Margin (Right)
   SetObjPosition("Account_Lbl_Margin", statsDescX + colW, row3Y);
   SetObjPosition("Account_Val_Margin", statsDescX + colW, row3Y + 15);
   
   // --- ROW 4: DEPOSIT & WITHDRAW ---
   int row4Y = row3Y + 45;
   
   // Deposit (Left)
   SetObjPosition("Account_Lbl_Deposit", statsDescX, row4Y);
   SetObjPosition("Account_Val_Deposit", statsDescX, row4Y + 15);
   
   // Withdraw (Right)
   SetObjPosition("Account_Lbl_Withdraw", statsDescX + colW, row4Y);
   SetObjPosition("Account_Val_Withdraw", statsDescX + colW, row4Y + 15);
   
   // Adjust height if needed or keep standard
   int row5Y = row4Y + 45; // Just for consistency logic if we added more
   
   currentY += statsBgH + 15;
   
   // --- SEPARATOR ---
   SetObjPosition("Account_Sep", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Account_Sep", OBJPROP_XSIZE, width - (paddingX*2));
   
   currentY += 15;
   
   // --- POSITIONS HEADER ---
   SetObjPosition("Account_SubTitle_Pos", startX + paddingX, currentY);
   currentY += 20;
   
   // --- ORDERS LIST CONTAINER (Fixed Size when scrolling) ---
   int ordersListY = currentY;
   bool needsScroll = (g_TotalAccountOrderCount > g_AccountOrdersMaxVisible);
   int visibleCount = needsScroll ? g_AccountOrdersMaxVisible : g_TotalAccountOrderCount;
   int itemWidth = needsScroll ? (width - (paddingX*2) - scrollBarWidth - 4) : (width - (paddingX*2));
   
   // Clamp scroll offset
   if(needsScroll)
   {
      int maxOffset = g_TotalAccountOrderCount - g_AccountOrdersMaxVisible;
      if(g_AccountOrdersScrollOffset > maxOffset) g_AccountOrdersScrollOffset = maxOffset;
      if(g_AccountOrdersScrollOffset < 0) g_AccountOrdersScrollOffset = 0;
   }
   else
   {
      g_AccountOrdersScrollOffset = 0;
   }
   
   // --- POSITIONS LIST ---
   // We iterate through visible items only (based on scroll offset)
   for(int i=0; i<visibleCount; i++)
   {
      string suffix = "_" + IntegerToString(i);
      
      // Background Card
      SetObjPosition("Account_Ord_Bg" + suffix, startX + paddingX, currentY);
      ObjectSetInteger(0, PREFIX + "Account_Ord_Bg" + suffix, OBJPROP_XSIZE, itemWidth);
      ObjectSetInteger(0, PREFIX + "Account_Ord_Bg" + suffix, OBJPROP_YSIZE, rowH);
      
      // Symbol (Left)
      SetObjPosition("Account_Ord_Sym" + suffix, startX + paddingX + 8, currentY + 6);
      
      // Type (Right) - Adjust position based on scroll area
      int typeX = needsScroll ? (startX + width - paddingX - scrollBarWidth - 75) : (startX + width - paddingX - 70);
      SetObjPosition("Account_Ord_Typ" + suffix, typeX, currentY + 7);
      
      currentY += rowH + gapY;
   }
   
   // Hide extra items beyond visible count
   for(int k=visibleCount; k<g_LastAccountOrderCount; k++)
   {
      string suffix = "_" + IntegerToString(k);
      SetObjVisible("Account_Ord_Bg" + suffix, false);
      SetObjVisible("Account_Ord_Sym" + suffix, false);
      SetObjVisible("Account_Ord_Typ" + suffix, false);
   }
   
   // --- SCROLLBAR ---
   if(needsScroll && g_PanelAccount.IsVisible)
   {
      int trackH = visibleCount * (rowH + gapY) - gapY;
      int trackX = startX + width - paddingX - scrollBarWidth;
      DrawAccountOrdersScrollbar(trackX, ordersListY, trackH, g_TotalAccountOrderCount, g_AccountOrdersMaxVisible);
      SetObjVisible("Account_Ord_ScrollTrack", true);
      SetObjVisible("Account_Ord_ScrollThumb", true);
   }
   else
   {
      HideAccountOrdersScrollbar();
   }
   
   if(g_TotalAccountOrderCount == 0)
   {
      SetObjPosition("Account_NoOrd_Msg", startX + paddingX, currentY);
      currentY += 20;
   }
   
   // Ajustement hauteur fond
   int totalHeight = currentY - startY + 15;
   ObjectSetInteger(0, PREFIX + "Account_Bg", OBJPROP_YSIZE, totalHeight);
   
   ChartRedraw();
}

#endif
