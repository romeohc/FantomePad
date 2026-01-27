//+------------------------------------------------------------------+
//|                                                Panel_Main.mqh    |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| VISIBLE CHART PRICE RANGE HELPER                                 |
//+------------------------------------------------------------------+
// Gets the price range currently visible on the chart.
// Used to position order lines so they remain visible to the user.
void GetVisibleChartPriceRange(double &priceMin, double &priceMax)
{
   // Get the visible bar range
   int firstVisibleBar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
   int barsVisible = (int)ChartGetInteger(0, CHART_WIDTH_IN_BARS);
   
   // Calculate the last visible bar index (bars are counted from current=0)
   int lastVisibleBar = firstVisibleBar - barsVisible;
   if(lastVisibleBar < 0) lastVisibleBar = 0;
   
   // Scan visible bars to find high/low
   double highest = -1e10;
   double lowest  = 1e10;
   
   for(int i = lastVisibleBar; i <= firstVisibleBar && i < Bars; i++)
   {
      double h = iHigh(Symbol(), Period(), i);
      double l = iLow(Symbol(), Period(), i);
      if(h > highest) highest = h;
      if(l < lowest)  lowest = l;
   }
   
   // Fallback if no bars
   if(highest < lowest)
   {
      highest = Ask + 100 * Point;
      lowest = Bid - 100 * Point;
   }
   
   priceMin = lowest;
   priceMax = highest;
}

//+------------------------------------------------------------------+
//| MOTEUR DE LAYOUT DYNAMIQUE                                       |
//+------------------------------------------------------------------+
void UpdateUIMode()
{
   // 1. Calcul des coordonnées de base
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   int startX = (g_PanelMain.X == -1) ? (chartW / 2) - (g_PanelMain.Width / 2) : g_PanelMain.X;
   int startY = (g_PanelMain.Y == -1) ? (chartH / 2) - (200) : g_PanelMain.Y;
   
   int paddingX = 20;
   int inputH   = 28; // Hauteur inputs augmentée
   int gapY     = 8;  // Espace entre label et input
   int sectionGap = 20; // Espace entre sections
   
   int currentY = startY + 50; 
   
   // --- Repositionnement du Header ---
   // Le bg sera redimensionné à la fin
   SetObjPosition("Bg", startX, startY);
   SetObjPosition("Header", startX, startY);
   SetObjPosition("Title", startX + 15, startY + 12);
   
   // --- LIGNE 1 : REMOVED SYMBOL SELECTOR ---
   // (Moved to Manager Panel)
   
   // --- LIGNE 2 : TYPE D'ORDRE ---
   // Label "Order Type" removed as requested
   // SetObjPosition("Label_Type", startX + paddingX, currentY);
   // currentY += 15;
   
   SetObjPosition("Btn_Type", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Btn_Type", OBJPROP_XSIZE, g_PanelMain.Width - (paddingX*2));
   ObjectSetInteger(0, PREFIX + "Btn_Type", OBJPROP_YSIZE, inputH);
   
   // Détermination du texte et de la couleur du type d'ordre
   string typeText = "";
   color  typeBgColor = g_ColorInput;
   color  typeBorderColor = g_ColorInput;
   
   if(CurrentTypeIndex == 0) // Market
   {
      if(CurrentDirection == 0) 
      {
         typeText = "BUY MARKET";
         typeBgColor = g_ColorGreen;
         typeBorderColor = typeBgColor; // No border (matches bg)
      }
      else 
      {
         typeText = "SELL MARKET";
         typeBgColor = g_ColorRed;
         typeBorderColor = typeBgColor; // No border (matches bg)
      }
   }
   else if(CurrentTypeIndex == 1 || CurrentTypeIndex == 3) // Buy Limit or Stop
   {
      typeText = OrderTypes[CurrentTypeIndex];
      typeBgColor = g_ColorGreen; 
      typeBorderColor = g_ColorGreen;
   }
   else // Sell Limit or Stop
   {
      typeText = OrderTypes[CurrentTypeIndex];
      typeBgColor = g_ColorRed;
      typeBorderColor = g_ColorRed;
   }
   
   ObjectSetString(0, PREFIX + "Btn_Type", OBJPROP_TEXT, typeText);
   ObjectSetInteger(0, PREFIX + "Btn_Type", OBJPROP_BGCOLOR, typeBgColor);
   ObjectSetInteger(0, PREFIX + "Btn_Type", OBJPROP_BORDER_COLOR, typeBorderColor);
   ObjectSetInteger(0, PREFIX + "Btn_Type", OBJPROP_COLOR, g_ColorText);
   
   currentY += inputH + sectionGap;
   
   // --- LIGNE 3 : PRIX (Seulement si Pending) ---
   if(CurrentTypeIndex == 0) // Market
   {
      SetObjVisible("Label_Price", false);
      SetObjVisible("Edit_Price", false);
   }
   else // Pending
   {
      SetObjVisible("Label_Price", true);
      SetObjVisible("Edit_Price", true);
      
      SetObjPosition("Label_Price", startX + paddingX, currentY);
      currentY += 15;
      
      SetObjPosition("Edit_Price", startX + paddingX, currentY);
      ObjectSetInteger(0, PREFIX + "Edit_Price", OBJPROP_XSIZE, g_PanelMain.Width - (paddingX*2));
      ObjectSetInteger(0, PREFIX + "Edit_Price", OBJPROP_YSIZE, inputH);
      
      currentY += inputH + sectionGap; 
   }
   
   // --- LIGNE 4 : SL & TP (SIDE BY SIDE) ---
   int halfWidth = (g_PanelMain.Width - (paddingX*2) - 10) / 2;
   
   // SL (Gauche)
   SetObjPosition("Label_SL", startX + paddingX, currentY);
   SetObjVisible("Label_SL", true); // Ensure visible
   
   // TP (Droite)
   SetObjPosition("Label_TP", startX + paddingX + halfWidth + 10, currentY);
   SetObjVisible("Label_TP", true);
   
   currentY += 15;
   
   SetObjPosition("Edit_SL", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Edit_SL", OBJPROP_XSIZE, halfWidth);
   ObjectSetInteger(0, PREFIX + "Edit_SL", OBJPROP_YSIZE, inputH);
   
   SetObjPosition("Edit_TP", startX + paddingX + halfWidth + 10, currentY);
   ObjectSetInteger(0, PREFIX + "Edit_TP", OBJPROP_XSIZE, halfWidth);
   ObjectSetInteger(0, PREFIX + "Edit_TP", OBJPROP_YSIZE, inputH);
   
   currentY += inputH + sectionGap;
   
   // --- LIGNE 5 : RISK & POSITION (SIDE BY SIDE) ---
   // Risk (Gauche)
   SetObjPosition("Label_Risk", startX + paddingX, currentY);
   
   // Lot (Droite)
   SetObjPosition("Label_Lot", startX + paddingX + halfWidth + 10, currentY);
   
   currentY += 15;
   
   SetObjPosition("Edit_Risk", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Edit_Risk", OBJPROP_XSIZE, halfWidth);
   ObjectSetInteger(0, PREFIX + "Edit_Risk", OBJPROP_YSIZE, inputH);
   
   // Positionnement du symbole % à l'intérieur de la case Risk
   // Positionnement du symbole % ou Devise à l'intérieur de la case Risk
   string riskUnit = "%";
   if(RiskMode == 1) riskUnit = AccountCurrency();
   else if(RiskMode == 2) riskUnit = "R";
   ObjectSetString(0, PREFIX + "Label_RiskPerc", OBJPROP_TEXT, riskUnit);
   
   int unitWidth = 35; 
   // Ajustement position pour être à droite dans l'input
   SetObjPosition("Label_RiskPerc", startX + paddingX + halfWidth - unitWidth - 2, currentY + 4);
   ObjectSetInteger(0, PREFIX + "Label_RiskPerc", OBJPROP_XSIZE, unitWidth);
   ObjectSetInteger(0, PREFIX + "Label_RiskPerc", OBJPROP_YSIZE, 20);
   ObjectSetInteger(0, PREFIX + "Label_RiskPerc", OBJPROP_ZORDER, 10);
   
   SetObjPosition("Edit_Lot", startX + paddingX + halfWidth + 10, currentY);
   ObjectSetInteger(0, PREFIX + "Edit_Lot", OBJPROP_XSIZE, halfWidth);
   ObjectSetInteger(0, PREFIX + "Edit_Lot", OBJPROP_YSIZE, inputH);
   
   currentY += inputH + sectionGap; // Espace normal avant les boutons
   
   // --- LIGNE 6 : BOUTONS D'ACTION ---
   
   if(CurrentTypeIndex == 0) // Market
   {
      SetObjVisible("Btn_Action", false);
      
      if(CurrentDirection == 0) // BUY ONLY
      {
         SetObjVisible("Btn_Buy", true);
         SetObjVisible("Btn_Sell", false);
         
         SetObjPosition("Btn_Buy", startX + paddingX, currentY);
         ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_XSIZE, g_PanelMain.Width - (paddingX*2));
         ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_YSIZE, 45); // Bouton plus haut
      }
      else // SELL ONLY
      {
         SetObjVisible("Btn_Buy", false);
         SetObjVisible("Btn_Sell", true);
         
         SetObjPosition("Btn_Sell", startX + paddingX, currentY);
         ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_XSIZE, g_PanelMain.Width - (paddingX*2));
         ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_YSIZE, 45); 
      }
   }
   else // Pending
   {
      SetObjVisible("Btn_Action", true);
      SetObjVisible("Btn_Buy", false);
      SetObjVisible("Btn_Sell", false);
      
      SetObjPosition("Btn_Action", startX + paddingX, currentY);
      ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_XSIZE, g_PanelMain.Width - (paddingX*2));
      ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_YSIZE, 45);
   }
   
   currentY += 60; 
   
   // --- AJUSTEMENT TAILLE FOND ---
   int totalHeight = currentY - startY + 10; 
   ObjectSetInteger(0, PREFIX + "Bg", OBJPROP_YSIZE, totalHeight);
   
   // Mise à jour des lignes (visibilité prix entrée)
   UpdateChartLines();
   
   // Maintenir l'état de validation des boutons (Gris/Actif)
   UpdateCalculatedLot();
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Création graphique (Initialisation des objets)                   |
//+------------------------------------------------------------------+
void CreatePanel()
{
   // 1. Fond & Header
   CreateRect("Bg", 0, 0, g_PanelMain.Width, 100, g_ColorBg, BORDER_FLAT); 
   CreateRect("Header", 0, 0, g_PanelMain.Width, 40, g_ColorBg, BORDER_FLAT);
   CreateLabel("Title", "Trading Panel", 0, 0, 10, g_ColorText, "Trebuchet MS Bold");
   
   // 2. Actif (Symbol) - MOVED TO MANAGER PANEL
   
   // 3. Type d'Ordre
   CreateButton("Btn_Type", OrderTypes[CurrentTypeIndex], 0, 0, g_PanelMain.Width - 40, 28, g_ColorInput, g_ColorText);
   ObjectSetString(0, PREFIX + "Btn_Type", OBJPROP_FONT, "Trebuchet MS Bold");
   
   // 4. Prix (Pending)
   CreateLabel("Label_Price", "Entry price", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Edit_Price", DoubleToString(Ask, Digits), 0, 0, g_PanelMain.Width - 40, 28);
   
   // 5. SL & TP
   CreateLabel("Label_SL", "Stop loss", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Edit_SL", "0.00000", 0, 0, g_PanelMain.Width - 40, 28);
   
   CreateLabel("Label_TP", "Take profit", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Edit_TP", "0.00000", 0, 0, g_PanelMain.Width - 40, 28);
   
   // 6. Risque
   CreateLabel("Label_Risk", "Risk", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Edit_Risk", "0", 0, 0, g_PanelMain.Width - 40, 28);
   
   // Bouton interactif pour changer le mode de risque (% <-> Devise)
   // On utilise un bouton pour faciliter le clic
   CreateButton("Label_RiskPerc", "%", 0, 0, 40, 20, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Label_RiskPerc", OBJPROP_BORDER_COLOR, g_ColorInput);
   ObjectSetInteger(0, PREFIX + "Label_RiskPerc", OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, PREFIX + "Label_RiskPerc", OBJPROP_FONT, "Trebuchet MS Bold");
   ObjectSetInteger(0, PREFIX + "Label_RiskPerc", OBJPROP_ZORDER, 10);
   
   // 7. Position
   CreateLabel("Label_Lot", "Lots (size)", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Edit_Lot", "0.00", 0, 0, g_PanelMain.Width - 40, 28, true);
   
   // 8. Boutons
   CreateButton("Btn_Sell", "VALIDATE", 0, 0, g_PanelMain.Width - 40, 45, g_ColorBtnValid, g_ColorText); 
   ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_FONTSIZE, 11);
   ObjectSetString(0, PREFIX + "Btn_Sell", OBJPROP_FONT, "Trebuchet MS Bold");
   
   CreateButton("Btn_Buy", "VALIDATE", 0, 0, g_PanelMain.Width - 40, 45, g_ColorBtnValid, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_FONTSIZE, 11);
   ObjectSetString(0, PREFIX + "Btn_Buy", OBJPROP_FONT, "Trebuchet MS Bold");

   CreateButton("Btn_Action", "VALIDATE", 0, 0, g_PanelMain.Width - 40, 45, g_ColorBtnValid, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_FONTSIZE, 11);
   ObjectSetString(0, PREFIX + "Btn_Action", OBJPROP_FONT, "Trebuchet MS Bold");
}

//+------------------------------------------------------------------+
//| Logique Automatique : Changement de Type selon Lignes            |
//+------------------------------------------------------------------+
void AutoSwitchOrderType()
{
   double sl    = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
   double tp    = StringToDouble(ObjectGetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT));
   double entry = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT));
   
   if(sl <= 0) return; // Pas de SL, pas de logique possible
   
   string symbol = ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
   if(symbol == "") symbol = Symbol();
   double bid = MarketInfo(symbol, MODE_BID);
   double ask = MarketInfo(symbol, MODE_ASK);
   
   bool changed = false;
   
   // --- LOGIQUE MARKET ---
   if(CurrentTypeIndex == 0)
   {
      // 1. Déterminer la Direction UNIQUEMENT basée sur SL et Prix du Marché
      // Pas de TP dans cette équation.
      if(sl < bid && CurrentDirection == 1) // SL en dessous du Bid => BUY
      {
         CurrentDirection = 0; // Buy
         changed = true;
      }
      else if(sl > ask && CurrentDirection == 0) // SL au dessus du Ask => SELL
      {
         CurrentDirection = 1; // Sell
         changed = true;
      }
      
      // 2. Vérification/Correction du TP (S'il existe)
      if(tp > 0)
      {
         // En BUY, TP doit être > SL (et idéalement > Entry, mais > SL est critique)
         if(CurrentDirection == 0 && tp <= sl) 
         {
            double minDist = 100 * MarketInfo(symbol, MODE_POINT);
            tp = sl + minDist; 
            ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, DoubleToString(tp, (int)MarketInfo(symbol, MODE_DIGITS)));
            UpdateChartLines(); // Met à jour la ligne sur le chart
         }
         // En SELL, TP doit être < SL
         else if(CurrentDirection == 1 && tp >= sl)
         {
            double minDist = 100 * MarketInfo(symbol, MODE_POINT);
            tp = sl - minDist;
            ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, DoubleToString(tp, (int)MarketInfo(symbol, MODE_DIGITS)));
            UpdateChartLines();
         }
      }
   }
   // --- LOGIQUE PENDING (LIMIT / STOP) ---
   else
   {
      if(entry > 0)
      {
         // 1. Déterminer la Direction STRICTEMENT selon SL vs Entry
         int targetDirection = -1; // 0=Buy, 1=Sell
         
         if(sl < entry) targetDirection = 0; // Buy
         else           targetDirection = 1; // Sell
         
         // 2. Déterminer le Type (Limit ou Stop) selon Entry vs Market
         int targetType = -1;
         
         if(targetDirection == 0) // Intended BUY
         {
            if(entry < ask) targetType = 1; // Buy Limit
            else            targetType = 3; // Buy Stop
         }
         else // Intended SELL
         {
             if(entry > bid) targetType = 2; // Sell Limit
             else            targetType = 4; // Sell Stop
         }
         
         // 3. Appliquer le changement Type/Direction
         if(targetType != -1 && targetType != CurrentTypeIndex)
         {
            CurrentTypeIndex = targetType;
            if(targetType == 1 || targetType == 3) CurrentDirection = 0;
            else                                   CurrentDirection = 1;
            changed = true;
         }
         
         // 4. Vérification/Correction du TP
         if(tp > 0)
         {
             if(CurrentDirection == 0 && tp <= sl)
             {
                 double minDist = 100 * MarketInfo(symbol, MODE_POINT);
                 tp = sl + minDist;
                 ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, DoubleToString(tp, (int)MarketInfo(symbol, MODE_DIGITS)));
                 UpdateChartLines();
             }
             else if(CurrentDirection == 1 && tp >= sl)
             {
                 double minDist = 100 * MarketInfo(symbol, MODE_POINT);
                 tp = sl - minDist;
                 ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, DoubleToString(tp, (int)MarketInfo(symbol, MODE_DIGITS)));
                 UpdateChartLines();
             }
         }
      }
   }
   
   if(changed)
   {
      UpdateUIMode();
      UpdateCalculatedLot();
      ChartRedraw();
   }
}

//+------------------------------------------------------------------+
//| APPLY DEFAULT VALUES (Entry/SL/TP)                               |
//+------------------------------------------------------------------+
// This function now uses the visible chart range to calculate distances
// so that Order Lines (Entry, SL, TP) are ALWAYS visible on the chart.
void ApplyDefaultTradeValues()
{
   string symbol = ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
   if(symbol == "") symbol = Symbol();
   
   double bid = MarketInfo(symbol, MODE_BID);
   double ask = MarketInfo(symbol, MODE_ASK);
   double point = MarketInfo(symbol, MODE_POINT);
   int digits = (int)MarketInfo(symbol, MODE_DIGITS);
   
   // Safety against zero dividing or weird symbols
   if(point == 0) return;
   
   // --- DYNAMIC DISTANCE CALCULATION BASED ON VISIBLE CHART ---
   // Get the visible price range
   double priceMin, priceMax;
   GetVisibleChartPriceRange(priceMin, priceMax);
   
   double visibleRange = priceMax - priceMin;
   
   // Define proportions of the visible range for each distance
   // We use fractions of the visible range to ensure lines stay on screen
   // Entry offset: ~5% of visible range (for pending orders)
   // SL: ~15% of visible range from entry  
   // TP: ~25% of visible range from entry
   double proportionEntry = 0.05;
   double proportionSL = 0.15;
   double proportionTP = 0.25;
   
   // Calculate dynamic distances
   double distEntry = visibleRange * proportionEntry;
   double distSL = visibleRange * proportionSL;  
   double distTP = visibleRange * proportionTP;
   
   // Minimum floor to avoid too-small distances (at least 10 pips = 100 points on 5-digit)
   double minDist = 100 * point;
   if(distEntry < minDist) distEntry = minDist;
   if(distSL < minDist * 2) distSL = minDist * 2;
   if(distTP < minDist * 3) distTP = minDist * 3;
   
   double entry = 0, sl = 0, tp = 0;
   
   // 1. Determine Entry
   if(CurrentTypeIndex == 0) // Market
   {
       // No Entry Price Input for Market
       if(CurrentDirection == 0) entry = ask; // Buy
       else                      entry = bid; // Sell
   }
   else if(CurrentTypeIndex == 1) // Buy Limit (Below Ask)
   {
       entry = ask - distEntry;
   }
   else if(CurrentTypeIndex == 2) // Sell Limit (Above Bid)
   {
       entry = bid + distEntry;
   }
   else if(CurrentTypeIndex == 3) // Buy Stop (Above Ask)
   {
       entry = ask + distEntry;
   }
   else if(CurrentTypeIndex == 4) // Sell Stop (Below Bid)
   {
       entry = bid - distEntry;
   }
   
   // 2. Determine SL / TP based on Entry and Direction
   int dir = CurrentDirection;
   
   // For Pending, overwrite direction based on Type (Buy Limit/Stop -> Buy, Sell Limit/Stop -> Sell)
   if(CurrentTypeIndex > 0)
   {
       if(CurrentTypeIndex == 1 || CurrentTypeIndex == 3) dir = 0; // Buy Pending
       else dir = 1; // Sell Pending
   }
   
   if(dir == 0) // BUY
   {
       sl = entry - distSL;
       tp = entry + distTP;
   }
   else // SELL
   {
       sl = entry + distSL;
       tp = entry - distTP;
   }
   
   // --- CLAMP TO VISIBLE RANGE ---
   // Ensure all prices stay within the visible chart area with some margin
   double margin = visibleRange * 0.05; // 5% margin from edges
   double clampMin = priceMin + margin;
   double clampMax = priceMax - margin;
   
   // Clamp Entry (for pending orders)
   if(CurrentTypeIndex != 0)
   {
       if(entry < clampMin) entry = clampMin;
       if(entry > clampMax) entry = clampMax;
   }
   
   // Recalculate SL/TP based on potentially clamped entry
   if(dir == 0) // BUY
   {
       sl = entry - distSL;
       tp = entry + distTP;
   }
   else // SELL
   {
       sl = entry + distSL;
       tp = entry - distTP;
   }
   
   // Clamp SL
   if(sl < clampMin) sl = clampMin;
   if(sl > clampMax) sl = clampMax;
   
   // Clamp TP
   if(tp < clampMin) tp = clampMin;
   if(tp > clampMax) tp = clampMax;
   
   // 3. Apply to Interface
   // Only update Entry field if NOT Market
   if(CurrentTypeIndex != 0)
   {
       ObjectSetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT, DoubleToString(entry, digits));
   }
   
   ObjectSetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT, DoubleToString(sl, digits));
   ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, DoubleToString(tp, digits));
   
   // 4. Update Lines
   UpdateChartLines();
   UpdateCalculatedLot(); // Refresh Risk Calc
}

//+------------------------------------------------------------------+
//| SHOW VALIDATION ERROR MESSAGE                                    |
//+------------------------------------------------------------------+
// Displays an error message in a red cell below the trading panel
// with white text and a close button (X) in the top right corner.
void ShowValidationError(string message)
{
   g_ValidationErrorMsg = message;
   g_ValidationErrorVisible = true;
   
   // Calculate position (below the main panel)
   int panelX = g_PanelMain.X;
   int panelY = g_PanelMain.Y;
   
   // Get actual panel height
   long panelH = ObjectGetInteger(0, PREFIX + "Bg", OBJPROP_YSIZE);
   if(panelH < 50) panelH = 300; // Fallback
   
   int errorX = panelX;
   int errorY = (int)(panelY + panelH + 10); // 10px gap below panel
   int errorW = g_PanelMain.Width;
   int errorH = 45; // Height of error message box
   
   // 1. Background (Red)
   string bgName = PREFIX + "ValErr_Bg";
   if(ObjectFind(0, bgName) < 0) ObjectCreate(0, bgName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bgName, OBJPROP_XDISTANCE, errorX);
   ObjectSetInteger(0, bgName, OBJPROP_YDISTANCE, errorY);
   ObjectSetInteger(0, bgName, OBJPROP_XSIZE, errorW);
   ObjectSetInteger(0, bgName, OBJPROP_YSIZE, errorH);
   ObjectSetInteger(0, bgName, OBJPROP_BGCOLOR, C'180,45,50'); // Dark Red
   ObjectSetInteger(0, bgName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bgName, OBJPROP_BORDER_COLOR, C'220,60,60'); // Lighter red border
   ObjectSetInteger(0, bgName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bgName, OBJPROP_BACK, false);
   ObjectSetInteger(0, bgName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bgName, OBJPROP_ZORDER, 100);
   
   // 2. Error Text (White, centered)
   string txtName = PREFIX + "ValErr_Txt";
   if(ObjectFind(0, txtName) < 0) ObjectCreate(0, txtName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, txtName, OBJPROP_XDISTANCE, errorX + 15);
   ObjectSetInteger(0, txtName, OBJPROP_YDISTANCE, errorY + 14);
   ObjectSetString(0, txtName, OBJPROP_TEXT, message);
   ObjectSetString(0, txtName, OBJPROP_FONT, "Trebuchet MS Bold");
   ObjectSetInteger(0, txtName, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, txtName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, txtName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, txtName, OBJPROP_BACK, false);
   ObjectSetInteger(0, txtName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, txtName, OBJPROP_ZORDER, 101);
   
   // 3. Close Button (X) in top right corner
   string closeName = PREFIX + "ValErr_Close";
   if(ObjectFind(0, closeName) < 0) ObjectCreate(0, closeName, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, closeName, OBJPROP_XDISTANCE, errorX + errorW - 30);
   ObjectSetInteger(0, closeName, OBJPROP_YDISTANCE, errorY + 8);
   ObjectSetInteger(0, closeName, OBJPROP_XSIZE, 22);
   ObjectSetInteger(0, closeName, OBJPROP_YSIZE, 22);
   ObjectSetString(0, closeName, OBJPROP_TEXT, "X");
   ObjectSetString(0, closeName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, closeName, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, closeName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, closeName, OBJPROP_BGCOLOR, C'150,35,40'); // Darker red for button
   ObjectSetInteger(0, closeName, OBJPROP_BORDER_COLOR, C'150,35,40');
   ObjectSetInteger(0, closeName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, closeName, OBJPROP_BACK, false);
   ObjectSetInteger(0, closeName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, closeName, OBJPROP_ZORDER, 102);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| HIDE VALIDATION ERROR MESSAGE                                    |
//+------------------------------------------------------------------+
// Closes and removes the validation error message display
void HideValidationError()
{
   g_ValidationErrorMsg = "";
   g_ValidationErrorVisible = false;
   
   // Delete all error message objects
   string bgName = PREFIX + "ValErr_Bg";
   string txtName = PREFIX + "ValErr_Txt";
   string closeName = PREFIX + "ValErr_Close";
   
   if(ObjectFind(0, bgName) >= 0) ObjectDelete(0, bgName);
   if(ObjectFind(0, txtName) >= 0) ObjectDelete(0, txtName);
   if(ObjectFind(0, closeName) >= 0) ObjectDelete(0, closeName);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| VISIBILITY CONTROL                                               |
//+------------------------------------------------------------------+
void ToggleMainPanel(bool visible)
{
   SetObjVisible("Bg", visible);
   SetObjVisible("Header", visible);
   SetObjVisible("Title", visible);
   SetObjVisible("Btn_Type", visible);
   
   if(visible)
   {
      // If showing, we rely on UpdateUIMode to restore correct state
      UpdateUIMode(); 
      ApplyDefaultTradeValues(); // Apply Defaults on Open 
   }
   else
   {
      // If hiding, we must manually hide conditional elements
      SetObjVisible("Label_Price", false);
      SetObjVisible("Edit_Price", false);
      SetObjVisible("Btn_Buy", false);
      SetObjVisible("Btn_Sell", false);
      SetObjVisible("Btn_Action", false);
      
      // --- CLEANUP VALIDATION ERROR ---
      HideValidationError();
      
      // --- CLEANUP EXTRA CHART LINES ---
      // When hiding, we must ensure "Ghost" lines are removed
      ObjectDelete(0, PREFIX + "Line_SL");
      ObjectDelete(0, PREFIX + "Line_TP");
      ObjectDelete(0, PREFIX + "Line_Price");
      
      ObjectDelete(0, PREFIX + "Line_SL_Txt");
      ObjectDelete(0, PREFIX + "Line_TP_Txt");
      ObjectDelete(0, PREFIX + "Line_Price_Txt");
   }
   
   SetObjVisible("Label_SL", visible);
   SetObjVisible("Edit_SL", visible);
   SetObjVisible("Label_TP", visible);
   SetObjVisible("Edit_TP", visible);
   SetObjVisible("Label_Risk", visible);
   SetObjVisible("Edit_Risk", visible);
   SetObjVisible("Label_RiskPerc", visible);
   SetObjVisible("Label_Lot", visible);
   SetObjVisible("Edit_Lot", visible);
}

//+------------------------------------------------------------------+
//| EVENT MANAGER                                                    |
//+------------------------------------------------------------------+
bool PanelMain_OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   // 1. DRAG LOGIC
   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int mouseX = (int)lparam;
      int mouseY = (int)dparam;
      int buttons = (int)sparam;
      
      // LOGIQUE DE DRAG AND DROP
      if((buttons & 1) == 1) // Clic gauche enfoncé
      {
         // On ne traite pas si quelqu'un d'autre drag déjà
         // Le Master appellera ce handler UNIQUEMENT si personne d'autre n'a pris la main via l'ordre d'appel.
         
         if(g_PanelMain.X == -1)
         {
            int cw = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
            int ch = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
            g_PanelMain.X = (cw / 2) - (g_PanelMain.Width / 2);
            g_PanelMain.Y = (ch / 2) - (200);
         }
            
         if(HandlePanelDrag(g_PanelMain.IsDragging, g_PanelMain.X, g_PanelMain.Y, g_PanelMain.DragOffsetX, g_PanelMain.DragOffsetY, mouseX, mouseY, g_PanelMain.Width, 200, "Bg"))
         {
            UpdateUIMode();
            return true; 
         }
      }
      else
      {
         // MOUSE UP
         if(g_PanelMain.IsDragging)
         {
            long h = ObjectGetInteger(0, PREFIX + "Bg", OBJPROP_YSIZE);
            if(h < 50) h = 200;
            
            ApplyPanelSafety(g_PanelMain.X, g_PanelMain.Y, g_PanelMain.Width, (int)h);
            g_PanelMain.IsDragging = false;
            UpdateUIMode();
            SaveConfigToFile();
            return true;
         }
      }
   }
   
   // 2. CLICK EVENTS
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
       if(sparam == PREFIX + "Label_RiskPerc")
       {
          RiskMode++;
          if(RiskMode > 2) RiskMode = 0;
          
          if(RiskMode == 1)      ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, "0");
          else if(RiskMode == 2) ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, "0");
          else                   ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, "0");
          
          UpdateUIMode();
          UpdateCalculatedLot();
          EffectButton(sparam);
          return true;
       }
       
       if(sparam == PREFIX + "Btn_Type")
       {
          if(CurrentTypeIndex == 0 && CurrentDirection == 0) CurrentDirection = 1;
          else if(CurrentTypeIndex == 0 && CurrentDirection == 1) { CurrentTypeIndex = 1; CurrentDirection = 0; }
          else if(CurrentTypeIndex == 4) { CurrentTypeIndex = 0; CurrentDirection = 0; }
          else CurrentTypeIndex++;
          
          UpdateUIMode(); 
          ApplyDefaultTradeValues(); // Apply Defaults on Type Change 
          UpdateCalculatedLot();
          ChartRedraw();
          return true;
       }
       
       if(sparam == PREFIX + "Btn_Buy" && CurrentTypeIndex == 0)
       {
          EffectButton(sparam);
          ExecuteOrder(OP_BUY);
          return true;
       }
       if(sparam == PREFIX + "Btn_Sell" && CurrentTypeIndex == 0)
       {
          EffectButton(sparam);
          ExecuteOrder(OP_SELL);
          return true;
       }
       if(sparam == PREFIX + "Btn_Action" && CurrentTypeIndex > 0)
       {
          EffectButton(sparam);
          int opCmd = -1;
          if(CurrentTypeIndex == 1) opCmd = OP_BUYLIMIT;
          if(CurrentTypeIndex == 2) opCmd = OP_SELLLIMIT;
          if(CurrentTypeIndex == 3) opCmd = OP_BUYSTOP;
          if(CurrentTypeIndex == 4) opCmd = OP_SELLSTOP;
          if(opCmd != -1) ExecuteOrder(opCmd);
          return true;
       }
   }
   
   // 3. EDIT EVENTS (Validation)
   if(id == CHARTEVENT_OBJECT_ENDEDIT)
   {
       if(StringFind(sparam, PREFIX + "Edit_") >= 0)
       {
           string currentText = ObjectGetString(0, sparam, OBJPROP_TEXT);
           StringTrimLeft(currentText); StringTrimRight(currentText);
           
           if(currentText == "")
           {
              if(sparam == PREFIX + "Edit_SL" || sparam == PREFIX + "Edit_TP" || sparam == PREFIX + "Edit_Risk")
                 ObjectSetString(0, sparam, OBJPROP_TEXT, "0");
           }
           
           UpdateChartLines(); 
           AutoSwitchOrderType();
           UpdateCalculatedLot();
           return true; 
       }
   }
   
   // 4. DRAG LINES
   if(id == CHARTEVENT_OBJECT_DRAG)
   {
       if(sparam == PREFIX + "Line_SL" || sparam == PREFIX + "Line_TP" || sparam == PREFIX + "Line_Price")
       {
          string editName = "Edit_SL";
          if(sparam == PREFIX + "Line_TP") editName = "Edit_TP";
          if(sparam == PREFIX + "Line_Price") editName = "Edit_Price";
          
          double price = ObjectGetDouble(0, sparam, OBJPROP_PRICE1);
          ObjectSetString(0, PREFIX + editName, OBJPROP_TEXT, DoubleToString(price, _Digits));
          
          AutoSwitchOrderType();
          UpdateCalculatedLot();
          return true;
       }
   }
   
   // 5. KEYDOWN
   if(id == CHARTEVENT_KEYDOWN)
   {
       bool changed = false;
       if(lparam == 55) { CurrentTypeIndex = 0; CurrentDirection = 0; changed = true; } // 7
       if(lparam == 56) { CurrentTypeIndex = 0; CurrentDirection = 1; changed = true; } // 8
       if(lparam == 57) { changed = true; } // 9
       
       if(changed)
       {
           // Force Apply Defaults for direct shortcuts 7 and 8 too
           // (Logic below handles 57 toggle, but we want 55/56 to trigger defaults too)
           // We do it by letting the 'changed' block run and adding the call there.

          if(lparam == 57)
          {
             if(CurrentDirection == 0) {
                if(CurrentTypeIndex == 0) CurrentTypeIndex = 1;
                else if(CurrentTypeIndex == 1) CurrentTypeIndex = 3;
                else CurrentTypeIndex = 0;
             } else {
                if(CurrentTypeIndex == 0) CurrentTypeIndex = 2;
                else if(CurrentTypeIndex == 2) CurrentTypeIndex = 4;
                else CurrentTypeIndex = 0;
             }
          }
          UpdateUIMode();
          ApplyDefaultTradeValues(); // Apply Defaults on Shortcut Change
          UpdateCalculatedLot();
          ChartRedraw();
          return true;
       }
   }

   return false;
}
