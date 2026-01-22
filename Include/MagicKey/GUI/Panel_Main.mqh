//+------------------------------------------------------------------+
//|                                                Panel_Main.mqh    |
//|                                                MagicKey Project  |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| MOTEUR DE LAYOUT DYNAMIQUE                                       |
//+------------------------------------------------------------------+
void UpdateUIMode()
{
   // 1. Calcul des coordonnées de base
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   int startX = (PanelX == -1) ? (chartW / 2) - (PanelWidth / 2) : PanelX;
   int startY = (PanelY == -1) ? (chartH / 2) - (200) : PanelY;
   
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
   // --- LIGNE 2 : TYPE D'ORDRE ---
   // Label "Order Type" removed as requested
   // SetObjPosition("Label_Type", startX + paddingX, currentY);
   // currentY += 15;
   
   SetObjPosition("Btn_Type", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Btn_Type", OBJPROP_XSIZE, PanelWidth - (paddingX*2));
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
      ObjectSetInteger(0, PREFIX + "Edit_Price", OBJPROP_XSIZE, PanelWidth - (paddingX*2));
      ObjectSetInteger(0, PREFIX + "Edit_Price", OBJPROP_YSIZE, inputH);
      
      currentY += inputH + sectionGap; 
   }
   
   // --- LIGNE 4 : SL & TP (SIDE BY SIDE) ---
   int halfWidth = (PanelWidth - (paddingX*2) - 10) / 2;
   
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
         ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_XSIZE, PanelWidth - (paddingX*2));
         ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_YSIZE, 45); // Bouton plus haut
      }
      else // SELL ONLY
      {
         SetObjVisible("Btn_Buy", false);
         SetObjVisible("Btn_Sell", true);
         
         SetObjPosition("Btn_Sell", startX + paddingX, currentY);
         ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_XSIZE, PanelWidth - (paddingX*2));
         ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_YSIZE, 45); 
      }
   }
   else // Pending
   {
      SetObjVisible("Btn_Action", true);
      SetObjVisible("Btn_Buy", false);
      SetObjVisible("Btn_Sell", false);
      
      SetObjPosition("Btn_Action", startX + paddingX, currentY);
      ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_XSIZE, PanelWidth - (paddingX*2));
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
   CreateRect("Bg", 0, 0, PanelWidth, 100, g_ColorBg, BORDER_FLAT); 
   CreateRect("Header", 0, 0, PanelWidth, 40, g_ColorBg, BORDER_FLAT);
   CreateLabel("Title", "Trading Panel", 0, 0, 10, g_ColorText, "Trebuchet MS Bold");
   
   // 2. Actif (Symbol) - MOVED TO MANAGER PANEL
   // CreateLabel("Label_Symbol", "Symbol", 0, 0, 8, g_ColorText, "Trebuchet MS");
   // CreateButton("Btn_SymbolSelect", Symbol(), 0, 0, PanelWidth - 40, 28, g_ColorInput, g_ColorText);
   
   // 3. Type d'Ordre
   // CreateLabel("Label_Type", "Order type", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateButton("Btn_Type", OrderTypes[CurrentTypeIndex], 0, 0, PanelWidth - 40, 28, g_ColorInput, g_ColorText);
   ObjectSetString(0, PREFIX + "Btn_Type", OBJPROP_FONT, "Trebuchet MS Bold");
   
   // 4. Prix (Pending)
   CreateLabel("Label_Price", "Entry price", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Edit_Price", DoubleToString(Ask, Digits), 0, 0, PanelWidth - 40, 28);
   
   // 5. SL & TP
   CreateLabel("Label_SL", "Stop loss", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Edit_SL", "0.00000", 0, 0, PanelWidth - 40, 28);
   
   CreateLabel("Label_TP", "Take profit", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Edit_TP", "0.00000", 0, 0, PanelWidth - 40, 28);
   
   // 6. Risque
   CreateLabel("Label_Risk", "Risk", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Edit_Risk", DoubleToString(g_DefaultRisk, 1), 0, 0, PanelWidth - 40, 28);
   
   // Bouton interactif pour changer le mode de risque (% <-> Devise)
   // On utilise un bouton pour faciliter le clic
   CreateButton("Label_RiskPerc", "%", 0, 0, 40, 20, g_ColorInput, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Label_RiskPerc", OBJPROP_BORDER_COLOR, g_ColorInput);
   ObjectSetInteger(0, PREFIX + "Label_RiskPerc", OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, PREFIX + "Label_RiskPerc", OBJPROP_FONT, "Trebuchet MS Bold");
   ObjectSetInteger(0, PREFIX + "Label_RiskPerc", OBJPROP_ZORDER, 10);
   
   // 7. Position
   CreateLabel("Label_Lot", "Lots (size)", 0, 0, 8, g_ColorText, "Trebuchet MS");
   CreateEdit("Edit_Lot", "0.00", 0, 0, PanelWidth - 40, 28, true);
   
   // 8. Boutons
   CreateButton("Btn_Sell", "VALIDATE", 0, 0, PanelWidth - 40, 45, g_ColorBtnValid, g_ColorText); 
   ObjectSetInteger(0, PREFIX + "Btn_Sell", OBJPROP_FONTSIZE, 11);
   ObjectSetString(0, PREFIX + "Btn_Sell", OBJPROP_FONT, "Trebuchet MS Bold");
   
   CreateButton("Btn_Buy", "VALIDATE", 0, 0, PanelWidth - 40, 45, g_ColorBtnValid, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Btn_Buy", OBJPROP_FONTSIZE, 11);
   ObjectSetString(0, PREFIX + "Btn_Buy", OBJPROP_FONT, "Trebuchet MS Bold");

   CreateButton("Btn_Action", "VALIDATE", 0, 0, PanelWidth - 40, 45, g_ColorBtnValid, g_ColorText);
   ObjectSetInteger(0, PREFIX + "Btn_Action", OBJPROP_FONTSIZE, 11);
   ObjectSetString(0, PREFIX + "Btn_Action", OBJPROP_FONT, "Trebuchet MS Bold");
}

// LIST FUNCTIONS MOVED TO PANEL_MANAGER.MQH

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
   }
   else
   {
      // If hiding, we must manually hide conditional elements
      SetObjVisible("Label_Price", false);
      SetObjVisible("Edit_Price", false);
      SetObjVisible("Btn_Buy", false);
      SetObjVisible("Btn_Sell", false);
      SetObjVisible("Btn_Action", false);
      
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
