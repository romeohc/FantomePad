//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

// Forward declaration if needed, but in MQL4 includes are flat.
// We assume Defines and GUI components are available or we manipulate objects by name.
#include <stdlib.mqh> 

//+------------------------------------------------------------------+
//| ERROR HANDLING HELPER                                            |
//+------------------------------------------------------------------+
// --- SAFE TRADE CONSTANTS ---
#define MAX_RETRIES 3
#define RETRY_DELAY 100 // ms

// --- SAFE ORDER EXECUTION ---
int SafeOrderSend(string symbol, int cmd, double volume, double price, int slippage, double sl, double tp, string comment, int magic, datetime expiration, color clr)
{
   int ticket = -1;
   int error = 0;
   
   for(int i = 0; i < MAX_RETRIES; i++)
   {
      // Always refresh rates before trading in a loop/retry
      RefreshRates();
      
      // Update Price if Market Order (to avoid Requote on retry)
      if(cmd == OP_BUY)       price = MarketInfo(symbol, MODE_ASK);
      if(cmd == OP_SELL)      price = MarketInfo(symbol, MODE_BID);
      
      // Normalize
      price = NormalizeDouble(price, (int)MarketInfo(symbol, MODE_DIGITS));
      
      // Check Free Margin (Optional but good)
      // ...
      
      ticket = OrderSend(symbol, cmd, volume, price, slippage, sl, tp, comment, magic, expiration, clr);
      
      if(ticket >= 0) return ticket; // Success
      
      error = GetLastError();
      
      // Retryable Errors
      if(error == 135 || error == 136 || error == 137 || error == 138 || error == 146) // Price Changed, Off Quotes, Busy, Requote, Context Busy
      {
         Sleep(RETRY_DELAY);
         continue; 
      }
      else
      {
         // Fatal Error
         break;
      }
   }
   
   HandleTradeError(error, "SafeOrderSend Failed");
   return -1;
}

bool SafeOrderClose(int ticket, double lots, double price, int slippage, color clr)
{
   bool result = false;
   int error = 0;
   
   for(int i = 0; i < MAX_RETRIES; i++)
   {
      RefreshRates();
      
      // Update Close Price
      if(OrderSelect(ticket, SELECT_BY_TICKET))
      {
         if(OrderType() == OP_BUY) price = MarketInfo(OrderSymbol(), MODE_BID);
         else                      price = MarketInfo(OrderSymbol(), MODE_ASK);
      }
      else return false; // Ticket gone?
      
      result = OrderClose(ticket, lots, price, slippage, clr);
      
      if(result) return true;
      
      error = GetLastError();
      if(error == 135 || error == 136 || error == 137 || error == 138 || error == 146)
      {
         Sleep(RETRY_DELAY);
         continue;
      }
      else break;
   }
   
   HandleTradeError(error, "SafeOrderClose Failed");
   return false;
}

bool SafeOrderModify(int ticket, double price, double sl, double tp, datetime expiration, color clr)
{
   bool result = false;
   int error = 0;
   
   for(int i = 0; i < MAX_RETRIES; i++)
   {
      // No need to refresh rates for Modify unless we are moving Entry of Pending
      // But checking context busy is good.
      if(IsTradeContextBusy()) 
      {
         Sleep(RETRY_DELAY);
         continue;
      }
      
      result = OrderModify(ticket, price, sl, tp, expiration, clr);
      
      if(result) return true;
      
      error = GetLastError();
      // Error 1 = No Change (Technically a success for us, silence it)
      if(error == 1) return true; 
      
      if(error == 136 || error == 137 || error == 146) // Busy, Off quotes
      {
         Sleep(RETRY_DELAY);
         continue;
      }
      else break;
   }
   
   HandleTradeError(error, "SafeOrderModify Failed");
   return false;
}

void HandleTradeError(int error, string extraMsg="")
{
   string desc = ErrorDescription(error);
   string fullMsg = "Error " + IntegerToString(error) + ": " + desc;
   if(extraMsg != "") fullMsg += " (" + extraMsg + ")";
   
   Print(fullMsg);
   
   // Set Toast Global (picked up by GUI)
   g_ToastMsg = fullMsg;
   g_ToastColor = g_ColorRed;
   g_ToastStartTime = GetTickCount();
}

void HandleTradeMessage(string msg, color col)
{
   Print(msg);
   g_ToastMsg = msg;
   g_ToastColor = col;
   g_ToastStartTime = GetTickCount();
}

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
   
   // Si le prix est valide (> 0), on affiche/maj la ligne
   if(price > 0)
   {
      if(ObjectFind(0, lineName) < 0)
      {
         ObjectCreate(0, lineName, OBJ_HLINE, 0, 0, price);
         ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, true);
         ObjectSetInteger(0, lineName, OBJPROP_SELECTED, true); 
         ObjectSetString(0, lineName, OBJPROP_TEXT, lineSuffix); 
      }
      
      // Mise à jour systématique des styles
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, col);
      ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, lineName, OBJPROP_BACK, true);
      
      // Mise à jour de la position si nécessaire
      double currentLinePrice = ObjectGetDouble(0, lineName, OBJPROP_PRICE1);
      if(MathAbs(currentLinePrice - price) > Point)
      {
         ObjectSetDouble(0, lineName, OBJPROP_PRICE1, price);
      }
   }
   else
   {
      // Si vide ou 0, on supprime la ligne
      if(ObjectFind(0, lineName) >= 0) ObjectDelete(0, lineName);
   }
}

void UpdateChartLines()
{
   UpdateSingleLine("Line_SL", "Edit_SL", g_ColorSLLine);
   UpdateSingleLine("Line_TP", "Edit_TP", g_ColorTPLine);
   
   // La ligne de prix n'a de sens que si on est en ordre Pending
   if(CurrentTypeIndex != 0) 
   {
      UpdateSingleLine("Line_Price", "Edit_Price", g_ColorEntryLine);
   } 
   else 
   {
      // En mode Market, on supprime la ligne de prix si elle existe
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
   
   // Update Line Props
   double curPrice = ObjectGetDouble(0, name, OBJPROP_PRICE1);
   if(MathAbs(curPrice - price) > Point) ObjectSetDouble(0, name, OBJPROP_PRICE1, price);
   
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   
   string txtName = name + "_Txt";
   if(labelText != "")
   {
      // Positionnement intelligent
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
      
      // Always Update Text Props
      ObjectSetDouble(0, txtName, OBJPROP_PRICE1, price);
      ObjectSetInteger(0, txtName, OBJPROP_TIME1, (long)txtTime);
      ObjectSetString(0, txtName, OBJPROP_TEXT, labelText);
      ObjectSetInteger(0, txtName, OBJPROP_COLOR, col);
   }
   else
   {
       // If empty label, ensure text object is gone
       if(ObjectFind(0, txtName) >= 0) ObjectDelete(0, txtName);
   }
}

void UpdateOpenOrderLines()
{
   string activeTickets = "|";
   
   // 1. Update/Create Active Lines
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
            
            string entryLabel = "BUY";
            if(type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP) entryLabel = "SELL";
            
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
   
   // 2. Cleanup Orphans
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, PREFIX + "Open_") >= 0)
      {
         // Split: PTP_Open_TICKET_...
         string parts[];
         ushort sep = StringGetCharacter("_", 0);
         StringSplit(name, sep, parts);
         
         // parts[0]=PTP, parts[1]=Open, parts[2]=Ticket
         if(ArraySize(parts) >= 3)
         {
            string t = parts[2];
            if(StringFind(activeTickets, "|" + t + "|") < 0)
            {
               ObjectDelete(0, name);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| CALCUL ET EXECUTION                                             |
//+------------------------------------------------------------------+
double CalculateLotSize(double entryPrice, double slPrice, double riskValue)
{
   if(entryPrice <= 0 || slPrice <= 0 || riskValue <= 0) return 0.0;
   if(MathAbs(entryPrice - slPrice) <= Point) return 0.0;
   
   string symbol = ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
   if(symbol == "") symbol = Symbol();
   
   double tickSize   = MarketInfo(symbol, MODE_TICKSIZE);
   double tickValue  = MarketInfo(symbol, MODE_TICKVALUE);
   double lotStep    = MarketInfo(symbol, MODE_LOTSTEP);
   double minLot     = MarketInfo(symbol, MODE_MINLOT);
   double maxLot     = MarketInfo(symbol, MODE_MAXLOT);
   
   if(tickSize == 0 || tickValue == 0) return 0.0;
   
   // Calcul du risque en argent
   double riskMoney = 0;
   
   if(RiskMode == 1) // Currency
   {
      // Risque exprimé directement en devise du compte
      riskMoney = riskValue;
   }
   else if(RiskMode == 2) // Risk R (Factor)
   {
       // Convertir R en % du solde
       // Exemple: Input 1.0 R -> 1.0 * g_OneRPercent (2%) -> 2% risk
       double riskPrc = riskValue * g_OneRPercent;
       riskMoney = AccountBalance() * (riskPrc / 100.0);
   }
   else // Percentage (RiskMode == 0)
   {
      // Risque exprimé en pourcentage du solde
      riskMoney = AccountEquity() * (riskValue / 100.0);
   }
   
   // Distance SL en points
   double distance = MathAbs(entryPrice - slPrice);
   
   // Formule : RiskMoney = Lots * TickValue * (Distance / TickSize)
   // Donc : Lots = RiskMoney / (TickValue * (Distance / TickSize))
   
   double steps = distance / tickSize;
   double lotSize = riskMoney / (steps * tickValue);
   
   // Normalisation
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   
   if(lotSize < minLot) lotSize = minLot; 
   if(lotSize > maxLot) lotSize = maxLot;
   
   return lotSize;
}

void UpdateCalculatedLot()
{
   // Récupérer les valeurs courantes
   string symbol = ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
   if(symbol == "") symbol = Symbol();
   
   double entry = 0;
   double currentBid = MarketInfo(symbol, MODE_BID);
   double currentAsk = MarketInfo(symbol, MODE_ASK);
   
   // Prix d'entrée dépend du type
   if(CurrentTypeIndex == 0) // Market
   {
      // En temps réel : on prend le prix exact selon la direction
      if(CurrentDirection == 0) entry = currentAsk; // Buy -> Ask
      else                      entry = currentBid; // Sell -> Bid
   }
   else
   {
      entry = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT));
   }
   
   double sl = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
   double risk = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));
   
   // --- GESTION COULEUR BOUTONS (SÉCURITÉ) ---
   
   if(CurrentTypeIndex == 0) // Market (BUY / SELL SEPARÉS)
   {
      // Market: SL > 0 et Risk > 0
      bool isValid = (sl > 0 && risk > 0);
      
      if(CurrentDirection == 0) // BUY BUTTON
      {
         if(!isValid) 
         {
            ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_BGCOLOR, g_ColorBtnInvalid);
            ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_BORDER_COLOR, g_ColorBtnInvalid);
         }
         else        
         {
             ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_BGCOLOR, g_ColorGreen);
             ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_BORDER_COLOR, g_ColorGreen);
          }
       }
       else // SELL BUTTON
       {
          if(!isValid) 
          {
             ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_BGCOLOR, g_ColorBtnInvalid);
             ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_BORDER_COLOR, g_ColorBtnInvalid);
          }
          else        
          {
             ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_BGCOLOR, g_ColorRed);
             ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_BORDER_COLOR, g_ColorRed);
          }
       }
   }
   else // Pending (BOUTON UNIQUE "VALIDATE")
   {
       // Pending: Entry > 0, SL > 0, Risk > 0
       bool isValid = (sl > 0 && risk > 0 && entry > 0);
       
       if(!isValid)
       {
          ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_BGCOLOR, g_ColorBtnInvalid);
          ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_BORDER_COLOR, g_ColorBtnInvalid);
       }
       else
       {
           // Determine Color based on Pending Type
           color actionCol = g_ColorBtnValid; // Fallback
           // Buy Limit (1) or Buy Stop (3) -> Green
           if(CurrentTypeIndex == 1 || CurrentTypeIndex == 3) actionCol = g_ColorGreen;
           // Sell Limit (2) or Sell Stop (4) -> Red
           else if(CurrentTypeIndex == 2 || CurrentTypeIndex == 4) actionCol = g_ColorRed;

           ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_BGCOLOR, actionCol);
           ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_BORDER_COLOR, actionCol);
       }
   }
   
   double lots = CalculateLotSize(entry, sl, risk);
   
   ObjectSetString(0, PREFIX + "Edit_Lot", OBJPROP_TEXT, DoubleToString(lots, 2));
}

// Forward declaration for UpdateUIMode needed in AutoSwitch
// But we can't easily circular depend. We'll use a callback or just assume it's there via master, 
// OR we return a flag "NeedsUpdate" to the caller. 
// For now, let's keep it simple and assume the caller will handle UI update if we change state,
// OR we simply copy the necessary logic here if it's small.
// Actually, AutoSwitchOrderType calls UpdateUIMode. We will need to address this dependency.
// Solution: We will move AutoSwitchOrderType to the Main Panel logic or Master Logic because it affects the UI state heavily.
// Wait, AutoSwitchOrderType modifies CurrentTypeIndex/CurrentDirection which are UI states.
// I will move AutoSwitchOrderType to Panel_Main.mqh later as it orchestrates the UI state. 
// Here I only keep pure execution and calculation.

void ExecuteOrder(int cmd)
{
   // Lecture du symbole depuis le bouton (et non plus l'Edit)
   string symbol = ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
   if(symbol == "") symbol = Symbol(); 
   
   double sl     = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
   double tp     = StringToDouble(ObjectGetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT));
   double risk   = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));
   
   // Use calculated volume
   double volume = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Lot", OBJPROP_TEXT));
   
   // Hardened Validation: Reject invalid volume
   if(volume <= 0) 
   {
      HandleTradeMessage("Invalid Volume (" + DoubleToString(volume, 2) + ")", g_ColorRed);
      return; 
   } 
   double price  = 0;
   
   double ask = MarketInfo(symbol, MODE_ASK);
   double bid = MarketInfo(symbol, MODE_BID);
   double digits = MarketInfo(symbol, MODE_DIGITS);
   
   if(cmd == OP_BUY)         price = ask;
   else if(cmd == OP_SELL)   price = bid;
   else                      price = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT)); 
   
   price = NormalizeDouble(price, (int)digits);
   sl    = NormalizeDouble(sl, (int)digits);
   tp    = NormalizeDouble(tp, (int)digits);
   
   int slippagePoints = GetSlippagePoints(MaxSlippage); // Use MaxSlippage input
   int ticket = SafeOrderSend(symbol, cmd, volume, price, slippagePoints, sl, tp, "ProPanel", MagicNumber, 0, clrNONE);
   
   if(ticket < 0) 
      { /* HandleTradeError called inside SafeOrderSend */ }
   else 
   {
      // PlaySound("ok.wav"); // Removed as requested
      
      // --- SÉCURITÉ ANTI-DOUBLON (RESET AUTOMATIQUE) ---
      ObjectSetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT, "0.00000");
      ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, "0.00000");
      ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, "0.0");
      
      // Reset du Prix d'entrée
      ObjectSetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT, "0.00000");
      
      UpdateChartLines();
      UpdateCalculatedLot(); 
      ChartRedraw();
   }
}


