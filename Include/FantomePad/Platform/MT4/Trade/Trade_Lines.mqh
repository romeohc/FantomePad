//+------------------------------------------------------------------+
//|                                                  Trade_Lines.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _TRADE_LINES_MQH_
#define _TRADE_LINES_MQH_

#include "../../Common/Core/Defines.mqh"

//+------------------------------------------------------------------+
//| GESTION DES LIGNES GRAPHIQUES                                    |
//+------------------------------------------------------------------+
int GetSlippagePoints(int slippagePips)
{
   int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
   if(digits == 3 || digits == 5) return slippagePips * 10;
   return slippagePips;
}

void UpdateSingleLine(string lineSuffix, string editSuffix, color col)
{
   string editName = PREFIX + editSuffix;
   string lineName = PREFIX + lineSuffix;
   
   string text = ObjectGetString(0, editName, OBJPROP_TEXT);
   double price = StringToDouble(text);
   
   if(price > 0)
   {
      if(ObjectFind(0, lineName) < 0)
      {
         ObjectCreate(0, lineName, OBJ_HLINE, 0, 0, price);
         ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, true);
         ObjectSetInteger(0, lineName, OBJPROP_SELECTED, true); 
         ObjectSetString(0, lineName, OBJPROP_TEXT, lineSuffix); 
      }
      
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, col);
      ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, lineName, OBJPROP_BACK, true);
      
      double currentLinePrice = ObjectGetDouble(0, lineName, OBJPROP_PRICE1);
      if(MathAbs(currentLinePrice - price) > Point)
      {
         ObjectSetDouble(0, lineName, OBJPROP_PRICE1, price);
      }
   }
   else
   {
      if(ObjectFind(0, lineName) >= 0) ObjectDelete(0, lineName);
   }
}

void UpdateChartLines()
{
   if(!g_ShowOrderLines || !g_PanelMain.IsVisible)
   {
       string sufs[] = {"Line_SL", "Line_TP", "Line_Price", "Line_SL_Txt", "Line_TP_Txt", "Line_Price_Txt"};
       for(int i=0; i<ArraySize(sufs); i++)
          if(ObjectFind(0, PREFIX + sufs[i]) >= 0) ObjectDelete(0, PREFIX + sufs[i]);
       
       ChartRedraw();
       return;
   }

   UpdateSingleLine("Line_SL", "Edit_SL", g_ColorSLLine);
   UpdateSingleLine("Line_TP", "Edit_TP", g_ColorTPLine);
   
   if(CurrentTypeIndex != 0) 
   {
      UpdateSingleLine("Line_Price", "Edit_Price", g_ColorEntryLine);
   } 
   else 
   {
      if(ObjectFind(0, PREFIX + "Line_Price") >= 0) ObjectDelete(0, PREFIX + "Line_Price");
   }
   
   ChartRedraw();
}

void CreateHLine(string name, double price, color col, int style, int width, string labelText = "")
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
   }
   
   double curPrice = ObjectGetDouble(0, name, OBJPROP_PRICE1);
   if(MathAbs(curPrice - price) > Point) ObjectSetDouble(0, name, OBJPROP_PRICE1, price);
   
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   
   string txtName = name + "_Txt";
   if(labelText != "")
   {
      int firstBar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
      int offset = 3; 
      if(firstBar < offset) offset = 0;
      datetime txtTime = iTime(Symbol(), Period(), firstBar - offset);
      
      if(ObjectFind(0, txtName) < 0)
      {
         ObjectCreate(0, txtName, OBJ_TEXT, 0, txtTime, price);
         ObjectSetInteger(0, txtName, OBJPROP_FONTSIZE, 9);
         ObjectSetString(0, txtName, OBJPROP_FONT, "Arial Bold");
         ObjectSetInteger(0, txtName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, txtName, OBJPROP_BACK, false);
         ObjectSetInteger(0, txtName, OBJPROP_SELECTABLE, false);
      }
      
      ObjectSetDouble(0, txtName, OBJPROP_PRICE1, price);
      ObjectSetInteger(0, txtName, OBJPROP_TIME1, (long)txtTime);
      ObjectSetString(0, txtName, OBJPROP_TEXT, labelText);
      ObjectSetInteger(0, txtName, OBJPROP_COLOR, col);
   }
   else
   {
       if(ObjectFind(0, txtName) >= 0) ObjectDelete(0, txtName);
   }
}

void UpdateOpenOrderLines()
{
   if(!g_ShowPositionLines)
   {
      int total = ObjectsTotal(0, -1, -1);
      for(int i = total - 1; i >= 0; i--)
      {
         string name = ObjectName(0, i);
         if(StringFind(name, PREFIX + "Open_") >= 0) ObjectDelete(0, name);
      }
      ChartRedraw();
      return;
   }
   
   string activeTickets = "|";
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol())
         {
            int ticket = OrderTicket();
            activeTickets += IntegerToString(ticket) + "|";
            
            double op = OrderOpenPrice();
            double sl = OrderStopLoss();
            double tp = OrderTakeProfit();
            int type = OrderType();
            
            string entryLabel = (type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP) ? "SELL" : "BUY";
            string tPrefix = PREFIX + "Open_" + IntegerToString(ticket);
            int d = (int)MarketInfo(Symbol(), MODE_DIGITS);
            
            CreateHLine(tPrefix + "_Ent", op, clrWhite, STYLE_DOT, 1, entryLabel + " - " + DoubleToString(op, d));
            
            if(sl > 0) CreateHLine(tPrefix + "_SL", sl, g_ColorSLLine, STYLE_DOT, 1, "SL - " + DoubleToString(sl, d));
            else {
                if(ObjectFind(0, tPrefix + "_SL") >= 0) ObjectDelete(0, tPrefix + "_SL");
                if(ObjectFind(0, tPrefix + "_SL_Txt") >= 0) ObjectDelete(0, tPrefix + "_SL_Txt");
            }
            
            if(tp > 0) CreateHLine(tPrefix + "_TP", tp, g_ColorTPLine, STYLE_DOT, 1, "TP - " + DoubleToString(tp, d));
            else {
                if(ObjectFind(0, tPrefix + "_TP") >= 0) ObjectDelete(0, tPrefix + "_TP");
                if(ObjectFind(0, tPrefix + "_TP_Txt") >= 0) ObjectDelete(0, tPrefix + "_TP_Txt");
            }
         }
      }
   }
   
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, PREFIX + "Open_") >= 0)
      {
         string parts[];
         ushort sep = StringGetCharacter("_", 0);
         StringSplit(name, sep, parts);
         
         if(ArraySize(parts) >= 3)
         {
            if(StringFind(activeTickets, "|" + parts[2] + "|") < 0) ObjectDelete(0, name);
         }
      }
   }
}

#endif
