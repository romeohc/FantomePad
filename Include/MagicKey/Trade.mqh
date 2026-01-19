//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                                                MagicKey Project  |
//+------------------------------------------------------------------+
#property strict

// Forward declaration if needed, but in MQL4 includes are flat.
// We assume Defines and GUI components are available or we manipulate objects by name.

//+------------------------------------------------------------------+
//| GESTION DES LIGNES GRAPHIQUES                                    |
//+------------------------------------------------------------------+
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
   if(ObjectCreate(0, name, OBJ_HLINE, 0, 0, price))
   {
      ObjectSetInteger(0, name, OBJPROP_COLOR, col);
      ObjectSetInteger(0, name, OBJPROP_STYLE, style);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
   
   if(labelText != "")
   {
      string txtName = name + "_Txt";
      // Positionnement avec un petit décalage par rapport au bord gauche
      int firstBar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
      int offset = 3; // On décale de 3 bougies vers la droite pour l'espace
      if(firstBar < offset) offset = 0;
      
      datetime txtTime = iTime(Symbol(), Period(), firstBar - offset);
      
      if(ObjectCreate(0, txtName, OBJ_TEXT, 0, txtTime, price))
      {
         ObjectSetString(0, txtName, OBJPROP_TEXT, labelText);
         ObjectSetInteger(0, txtName, OBJPROP_COLOR, col); // Utilise la couleur de la ligne (Rouge/Vert/Blanc)
         ObjectSetInteger(0, txtName, OBJPROP_FONTSIZE, 9);
         ObjectSetString(0, txtName, OBJPROP_FONT, "Arial Bold");
         ObjectSetInteger(0, txtName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, txtName, OBJPROP_BACK, false);
         ObjectSetInteger(0, txtName, OBJPROP_SELECTABLE, false);
      }
      else
      {
         // Mise à jour de la position et du texte pour rester synchronisé (prix/scroll)
         ObjectSetDouble(0, txtName, OBJPROP_PRICE1, price);
         ObjectSetInteger(0, txtName, OBJPROP_TIME1, (long)txtTime);
         ObjectSetString(0, txtName, OBJPROP_TEXT, labelText);
         ObjectSetInteger(0, txtName, OBJPROP_COLOR, col);
      }
   }
}

void UpdateOpenOrderLines()
{
   // Supprimer les anciennes lignes pour rafraîchir
   for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, PREFIX + "Open_") >= 0) ObjectDelete(0, name);
   }

   // Parcourir tous les ordres ouverts et pending
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol())
         {
            int ticket = OrderTicket();
            double op = OrderOpenPrice();
            double sl = OrderStopLoss();
            double tp = OrderTakeProfit();
            int type = OrderType();
            
            string entryLabel = "BUY";
            if(type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP) entryLabel = "SELL";
            
            string tPrefix = PREFIX + "Open_" + IntegerToString(ticket);
            int d = (int)MarketInfo(Symbol(), MODE_DIGITS);
            
            // 1. Ligne d'Entrée (Blanche, Label "BUY/SELL - Prix")
            CreateHLine(tPrefix + "_Ent", op, clrWhite, STYLE_DOT, 1, entryLabel + " - " + DoubleToString(op, d));
            
            // 2. Ligne Stop Loss (Rouge, Label "SL - Prix")
            if(sl > 0) CreateHLine(tPrefix + "_SL", sl, g_ColorSLLine, STYLE_DOT, 1, "SL - " + DoubleToString(sl, d));
            
            // 3. Ligne Take Profit (Verte, Label "TP - Prix")
            if(tp > 0) CreateHLine(tPrefix + "_TP", tp, g_ColorTPLine, STYLE_DOT, 1, "TP - " + DoubleToString(tp, d));
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
      riskMoney = AccountBalance() * (riskValue / 100.0);
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
             ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_BGCOLOR, g_ColorBtnValid);
             ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_BORDER_COLOR, g_ColorBtnValid);
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
             ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_BGCOLOR, g_ColorBtnValid);
             ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_BORDER_COLOR, g_ColorBtnValid);
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
          // Utilise la couleur "Button Valid" générique pour l'action de validation
          ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_BGCOLOR, g_ColorBtnValid);
          ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_BORDER_COLOR, g_ColorBtnValid);
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
   if(volume <= 0) volume = 0.01; // Safety fallback 
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
   
   int ticket = OrderSend(symbol, cmd, volume, price, 10, sl, tp, "ProPanel", 0, 0, clrNONE);
   
   if(ticket < 0) 
      Alert("Erreur sur ", symbol, ": ", GetLastError());
   else 
   {
      PlaySound("ok.wav");
      
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
