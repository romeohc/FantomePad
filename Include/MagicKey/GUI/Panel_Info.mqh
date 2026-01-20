//+------------------------------------------------------------------+
//|                                              Panel_Info.mqh      |
//|                                                MagicKey Project  |
//+------------------------------------------------------------------+
#property strict

// GLOBAL pour suivre le nombre d'ordres affichés
int g_LastInfoOrderCount = 0;

string GetOrderTypeStrShort(int type)
{
   switch(type)
   {
      case OP_BUY:      return "BUY";
      case OP_SELL:     return "SELL";
      case OP_BUYLIMIT: return "BUY LIMIT";
      case OP_SELLLIMIT: return "SELL LIMIT";
      case OP_BUYSTOP:  return "BUY STOP";
      case OP_SELLSTOP: return "SELL STOP";
      default:          return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| MISE A JOUR DU LAYOUT (POSITIONNEMENT)                           |
//+------------------------------------------------------------------+
void UpdateInfoLayout()
{
   int startX = InfoPanelX;
   int startY = InfoPanelY;
   int width  = 260; // Wider Panel for better spacing
   
   int paddingX = 20;
   int rowH     = 28; // Height of an order row
   int gapY     = 4;  // Gap between rows
   
   int currentY = startY + 50; 
   
   // --- HEAD & BG ---
   SetObjPosition("Info_Bg", startX, startY);
   SetObjPosition("Info_Header", startX, startY);
   SetObjPosition("Info_Title", startX + 15, startY + 12);
   
   ObjectSetInteger(0, PREFIX + "Info_Bg", OBJPROP_XSIZE, width);
   ObjectSetInteger(0, PREFIX + "Info_Header", OBJPROP_XSIZE, width);
   
   // --- ACCOUNT SECTION ---
   // Balance (Main)
   SetObjPosition("Info_Lbl_Balance", startX + paddingX, currentY);
   currentY += 14; 
   SetObjPosition("Info_Val_Balance", startX + paddingX, currentY);
   currentY += 30; // More space after Balance
   
   // Equity & Margin (Side by Side)
   int secondColX = startX + (width / 2) + 5;
   int firstColX  = startX + paddingX;
   
   // Equity (Left)
   SetObjPosition("Info_Lbl_Equity", firstColX, currentY);
   // Margin (Right)
   SetObjPosition("Info_Lbl_Margin", secondColX, currentY);
   
   currentY += 14;
   
   SetObjPosition("Info_Val_Equity", firstColX, currentY);
   SetObjPosition("Info_Val_Margin", secondColX, currentY);
   
   currentY += 30; // Space before separator
   
   // --- SEPARATOR ---
   SetObjPosition("Info_Sep", startX + paddingX, currentY);
   ObjectSetInteger(0, PREFIX + "Info_Sep", OBJPROP_XSIZE, width - (paddingX*2));
   
   currentY += 15;
   
   // --- POSITIONS HEADER ---
   SetObjPosition("Info_SubTitle_Pos", startX + paddingX, currentY);
   currentY += 20;
   
   // --- POSITIONS LIST ---
   for(int i=0; i<g_LastInfoOrderCount; i++)
   {
      string suffix = "_" + IntegerToString(i);
      
      // Background Card
      SetObjPosition("Info_Ord_Bg" + suffix, startX + paddingX, currentY);
      ObjectSetInteger(0, PREFIX + "Info_Ord_Bg" + suffix, OBJPROP_XSIZE, width - (paddingX*2));
      ObjectSetInteger(0, PREFIX + "Info_Ord_Bg" + suffix, OBJPROP_YSIZE, rowH);
      
      // Symbol (Left)
      SetObjPosition("Info_Ord_Sym" + suffix, startX + paddingX + 8, currentY + 6);
      
      // Type (Right)
      // Note: Alignment is tricky without width calculation, so we manually position far right
      // Ideally we would right align, but simple positioning:
      SetObjPosition("Info_Ord_Typ" + suffix, startX + width - paddingX - 70, currentY + 7);
      
      currentY += rowH + gapY;
   }
   
   // Ajustement hauteur fond
   int totalHeight = currentY - startY + 15;
   ObjectSetInteger(0, PREFIX + "Info_Bg", OBJPROP_YSIZE, totalHeight);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| CRÉATION DES OBJETS                                              |
//+------------------------------------------------------------------+
void CreateInfoPanel()
{
   int width = 260;
   
   // 1. Fond & Header
   CreateRect("Info_Bg", 0, 0, width, 100, g_ColorBg, BORDER_FLAT); 
   CreateRect("Info_Header", 0, 0, width, 45, g_ColorHeader, BORDER_FLAT);
   CreateLabel("Info_Title", "ACCOUNT OVERVIEW", 0, 0, 10, clrWhite, "Trebuchet MS Bold");
   
   // 2. Account Data
   CreateLabel("Info_Lbl_Balance", "BALANCE", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Info_Val_Balance", "...", 0, 0, 14, clrWhite, "Trebuchet MS Bold"); // Bigger, White
   
   CreateLabel("Info_Lbl_Equity", "EQUITY", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Info_Val_Equity", "...", 0, 0, 10, g_ColorText, "Trebuchet MS Bold");
   
   CreateLabel("Info_Lbl_Margin", "MARGIN", 0, 0, 7, g_ColorLabel, "Trebuchet MS");
   CreateLabel("Info_Val_Margin", "...", 0, 0, 10, g_ColorText, "Trebuchet MS Bold");
   
   // 3. Separator Line
   CreateRect("Info_Sep", 0, 0, 100, 1, g_ColorHeader, BORDER_FLAT);
   
   // 4. SubHeader
   CreateLabel("Info_SubTitle_Pos", "ACTIVE ORDERS", 0, 0, 8, g_ColorLabel, "Trebuchet MS Bold");
   
   UpdateInfoLayout();
   UpdateInfoPanel();
}

//+------------------------------------------------------------------+
//| MISE A JOUR DES VALEURS (TICK)                                   |
//+------------------------------------------------------------------+
void UpdateInfoPanel()
{
   if(!IsInfoPanelVisible) return;

   string currency = AccountCurrency();
   
   double bal = AccountBalance();
   double equ = AccountEquity();
   double marg = AccountFreeMargin();
   
   string sBal = DoubleToString(bal, 2) + " " + currency;
   string sEqu = DoubleToString(equ, 2) + " " + currency;
   string sMarg = DoubleToString(marg, 2) + " " + currency;
   
   ObjectSetString(0, PREFIX + "Info_Val_Balance", OBJPROP_TEXT, sBal);
   ObjectSetString(0, PREFIX + "Info_Val_Equity", OBJPROP_TEXT, sEqu);
   ObjectSetString(0, PREFIX + "Info_Val_Margin", OBJPROP_TEXT, sMarg);
   
   // --- ORDER LIST UPDATES ---
   int total = OrdersTotal();
   int visualIndex = 0;
   
   for(int i=0; i<total; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         // DATA
         string typeStr = GetOrderTypeStrShort(OrderType());
         string symbol  = OrderSymbol();
         color typeColor = (OrderType() % 2 == 0) ? g_ColorGreen : g_ColorRed;
         
         string suffix = "_" + IntegerToString(visualIndex);
         
         // 1. Background Card (Darker than BG to pop, or lighter? lets use Header Color for card)
         string nameBg = "Info_Ord_Bg" + suffix;
         if(ObjectFind(0, PREFIX + nameBg) < 0) CreateRect(nameBg, 0, 0, 10, 10, g_ColorInput, BORDER_FLAT); 
         ObjectSetInteger(0, PREFIX + nameBg, OBJPROP_BGCOLOR, g_ColorInput); // Use Input color for cards
         ObjectSetInteger(0, PREFIX + nameBg, OBJPROP_BORDER_COLOR, g_ColorInput);
         SetObjVisible(nameBg, true);

         // 2. Symbol Label
         string nameSym = "Info_Ord_Sym" + suffix;
         if(ObjectFind(0, PREFIX + nameSym) < 0) CreateLabel(nameSym, symbol, 0, 0, 9, clrWhite, "Trebuchet MS Bold");
         ObjectSetString(0, PREFIX + nameSym, OBJPROP_TEXT, symbol);
         SetObjVisible(nameSym, true);
         
         // 3. Type Label
         string nameTyp = "Info_Ord_Typ" + suffix;
         if(ObjectFind(0, PREFIX + nameTyp) < 0) CreateLabel(nameTyp, typeStr, 0, 0, 8, typeColor, "Trebuchet MS");
         ObjectSetString(0, PREFIX + nameTyp, OBJPROP_TEXT, typeStr);
         ObjectSetInteger(0, PREFIX + nameTyp, OBJPROP_COLOR, typeColor);
         SetObjVisible(nameTyp, true);
         
         visualIndex++;
      }
   }
   
   // Clean up stale objects (Bg + Sym + Typ)
   if(visualIndex < g_LastInfoOrderCount)
   {
      for(int k=visualIndex; k<g_LastInfoOrderCount; k++)
      {
         string suffix = "_" + IntegerToString(k);
         ObjectDelete(0, PREFIX + "Info_Ord_Bg" + suffix);
         ObjectDelete(0, PREFIX + "Info_Ord_Sym" + suffix);
         ObjectDelete(0, PREFIX + "Info_Ord_Typ" + suffix);
      }
   }
   
   g_LastInfoOrderCount = visualIndex;
   
   // Recalculate Layout (Height & Positions)
   UpdateInfoLayout();
}

//+------------------------------------------------------------------+
//| VISIBILITY CONTROL                                               |
//+------------------------------------------------------------------+
void ToggleInfoPanel(bool visible)
{
   SetObjVisible("Info_Bg", visible);
   SetObjVisible("Info_Header", visible);
   SetObjVisible("Info_Title", visible);
   
   SetObjVisible("Info_Lbl_Balance", visible);
   SetObjVisible("Info_Val_Balance", visible);
   SetObjVisible("Info_Lbl_Equity", visible);
   SetObjVisible("Info_Val_Equity", visible);
   SetObjVisible("Info_Lbl_Margin", visible);
   SetObjVisible("Info_Val_Margin", visible);
   
   SetObjVisible("Info_Sep", visible);
   SetObjVisible("Info_SubTitle_Pos", visible);
   
   // Position Lines
   for(int i=0; i<g_LastInfoOrderCount; i++)
   {
      string suffix = "_" + IntegerToString(i);
      SetObjVisible("Info_Ord_Bg" + suffix, visible);
      SetObjVisible("Info_Ord_Sym" + suffix, visible);
      SetObjVisible("Info_Ord_Typ" + suffix, visible);
   }
   
   if(visible) UpdateInfoLayout();
}
