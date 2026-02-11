//+------------------------------------------------------------------+
//|                                        Panel_SymbolManager.mqh   |
//|                                           FantomePad Project     |
//+------------------------------------------------------------------+
#property strict

// --- STORAGE FOR CATEGORIES ---
string g_SymMgr_Categories[];
int    g_SymMgr_CategoryCount = 0;
string g_SymMgr_SymbolsInCat[];      // Symbols in current category
int    g_SymMgr_SymbolCount = 0;     // Count of symbols in current category

//+------------------------------------------------------------------+
//| HELPER: EXTRACT PARENT PATH (Définit la catégorie)               |
//+------------------------------------------------------------------+
string GetParentPath(string path)
{
   int lastSlash = -1;
   int pos = StringFind(path, "\\", 0);
   while(pos != -1)
   {
      lastSlash = pos;
      pos = StringFind(path, "\\", pos + 1);
   }
   
   if(lastSlash <= 0) return "Global"; // Pas de dossier, symbole à la racine
   return StringSubstr(path, 0, lastSlash);
}

//+------------------------------------------------------------------+
//| HELPER: EXTRACT CATEGORIES (One-Shot Scan)                       |
//+------------------------------------------------------------------+
void ScanCategories()
{
   if(g_SymbolManagerLoaded) return;
   
   int total = SymbolsTotal(false); // False = All symbols on server
   string tempCats[];
   int tempCount = 0;
   ArrayResize(tempCats, 100); // Initial buffer
   
   for(int i=0; i<total; i++)
   {
      string name = SymbolName(i, false);
      string path = SymbolInfoString(name, SYMBOL_PATH);
      string cat = GetParentPath(path); // On extrait uniquement le dossier
      
      bool found = false;
      for(int j=0; j<tempCount; j++)
      {
         if(tempCats[j] == cat) { found = true; break; }
      }
      
      if(!found)
      {
         if(tempCount >= ArraySize(tempCats)) ArrayResize(tempCats, ArraySize(tempCats) + 50);
         tempCats[tempCount] = cat;
         tempCount++;
      }
   }
   
   ArrayResize(g_SymMgr_Categories, tempCount);
   for(int k=0; k<tempCount; k++) g_SymMgr_Categories[k] = tempCats[k];
   g_SymMgr_CategoryCount = tempCount;
   
   // Default selection
   if(g_SymMgr_CategoryCount > 0 && g_SymMgr_CurrentCategory == "") 
   {
       g_SymMgr_CurrentCategory = g_SymMgr_Categories[0];
   }
   g_SymMgr_ScrollOffset = 0;
   g_SymbolManagerLoaded = true;
}

//+------------------------------------------------------------------+
//| HELPER: LOAD SYMBOLS FOR CATEGORY                                |
//+------------------------------------------------------------------+
void LoadSymbolsForCategory(string category)
{
   int total = SymbolsTotal(false);
   string tempSyms[];
   int count = 0;
   ArrayResize(tempSyms, 200);
   
   for(int i=0; i<total; i++)
   {
      string name = SymbolName(i, false);
      string path = SymbolInfoString(name, SYMBOL_PATH);
      if(GetParentPath(path) == category) // Comparaison sur le dossier parent
      {
         if(count >= ArraySize(tempSyms)) ArrayResize(tempSyms, ArraySize(tempSyms) + 100);
         tempSyms[count] = name;
         count++;
      }
   }
   
   ArrayResize(g_SymMgr_SymbolsInCat, count);
   for(int k=0; k<count; k++) g_SymMgr_SymbolsInCat[k] = tempSyms[k];
   g_SymMgr_SymbolCount = count;
   
   // Reset scroll
   g_SymMgr_ScrollOffset = 0;
}

//+------------------------------------------------------------------+
//| MAIN DRAW FUNCTION                                               |
//+------------------------------------------------------------------+
void CreateSymbolManagerPanel()
{
   if(!g_PanelSymbolManager.IsVisible) return;
   
   // Scan on first open
   if(!g_SymbolManagerLoaded) 
   {
       ScanCategories();
       if(g_SymMgr_CurrentCategory != "") LoadSymbolsForCategory(g_SymMgr_CurrentCategory);
   }
   
   // --- POSITIONING ---
   if(g_PanelSymbolManager.X == -1)
   {
       int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
       int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
       g_PanelSymbolManager.X = (chartW / 2) - (g_PanelSymbolManager.Width / 2);
       g_PanelSymbolManager.Y = (chartH / 2) - (g_PanelSymbolManager.Height / 2);
   }
   
   int x = g_PanelSymbolManager.X;
   int y = g_PanelSymbolManager.Y;
   int w = g_PanelSymbolManager.Width;
   int h = g_PanelSymbolManager.Height;
   
   // 1. MAIN WINDOW (SYM_ prefix for Trigram compliance)
   CreateRect("SYM_Bg", x, y, w, h, g_ColorBg, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "SYM_Bg", OBJPROP_ZORDER, 141);
   ObjectSetInteger(0, PREFIX + "SYM_Bg", OBJPROP_BORDER_COLOR, g_ColorInput);
   ObjectSetInteger(0, PREFIX + "SYM_Bg", OBJPROP_WIDTH, 2); 

   // 2. MARGIN (Replaces Header)
   int headerH = 20;
   
   /* 
   // Close Button
   int closeBtnSize = 24;
   CreateButton("SYM_Btn_Close", "X", x + w - closeBtnSize - 10, y + 8, closeBtnSize, closeBtnSize, g_ColorBtnInvalid, g_ColorText);
   ObjectSetInteger(0, PREFIX + "SYM_Btn_Close", OBJPROP_ZORDER, 143);
   */

   // 3. CATEGORY LIST (LEFT SIDE)
   int catListW = 180;
   int contentY = y + headerH;
   int contentH = h - headerH;
   
   CreateRect("SYM_CatBg", x, contentY, catListW, contentH, g_ColorBg, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "SYM_CatBg", OBJPROP_ZORDER, 142);
   
   // Vertical Separator
   CreateRect("SYM_Sep", x + catListW, contentY + 10, 1, contentH - 20, C'50,50,50', BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "SYM_Sep", OBJPROP_ZORDER, 142);
   
   int catItemH = 25;
   int catStartY = contentY + 10;
   
   for(int i=0; i<g_SymMgr_CategoryCount; i++)
   {
       if(catStartY + catItemH > y + h - 10) break; 
       
       string catName = g_SymMgr_Categories[i];
       bool isSelected = (catName == g_SymMgr_CurrentCategory);
       color catBg = isSelected ? g_ColorBtnActive : g_ColorBg;
       color catTxt = isSelected ? clrWhite : g_ColorText;
       
       string btnName = "SYM_Cat_" + IntegerToString(i);
       CreateButton(btnName, catName, x + 5, catStartY, catListW - 10, catItemH, catBg, catTxt);
       ObjectSetInteger(0, PREFIX + btnName, OBJPROP_ZORDER, 143);
       ObjectSetInteger(0, PREFIX + btnName, OBJPROP_ALIGN, ALIGN_LEFT);
       
       catStartY += catItemH + 2;
   }
   
   // 4. SYMBOL GRID (RIGHT SIDE)
   int gridX = x + catListW + 10;
   int gridY = contentY + 10;
   int gridW = w - catListW - 20;
   int gridH = contentH - 20;
   
   int cols = 3;
   int cellW = (gridW / cols) - 5;
   int cellH = 30;
   
   int rows = gridH / (cellH + 5);
   g_SymMgr_MaxVisible = rows * cols; 
   
   int drawnCount = 0;
   for(int i=0; i<g_SymMgr_MaxVisible; i++)
   {
       int dataIdx = g_SymMgr_ScrollOffset + i;
       if(dataIdx >= g_SymMgr_SymbolCount) break;
       
       string sym = g_SymMgr_SymbolsInCat[dataIdx];
       int col = i % cols;
       int row = i / cols;
       int cellX = gridX + (col * (cellW + 5));
       int cellY = gridY + (row * (cellH + 5));
       
       string btnName = "SYM_Sym_" + IntegerToString(i);
       bool isInMarket = (bool)SymbolInfoInteger(sym, SYMBOL_SELECT);
       color cellBg = isInMarket ? g_ColorBtnActive : g_ColorBg; // Mint if added, Dark if not
       
       CreateButton(btnName, sym, cellX, cellY, cellW, cellH, cellBg, g_ColorText);
       ObjectSetInteger(0, PREFIX + btnName, OBJPROP_ZORDER, 143);
       drawnCount++;
   }
   
   for(int j=drawnCount; j<100; j++) 
   {
       string btnName = PREFIX + "SYM_Sym_" + IntegerToString(j);
       if(ObjectFind(0, btnName) >= 0) ObjectDelete(0, btnName);
   }
      // 5. SCROLLBAR
    int totalRows = (g_SymMgr_SymbolCount + cols - 1) / cols;
    int visibleRows = rows;
    
    if(totalRows > visibleRows)
    {
        int scrollX = x + w - 15;
        int trackY = gridY;
        int trackH = gridH;
        int trackW = 8;
        
        // Track
        CreateRect("SYM_ScrollTrack", scrollX, trackY, trackW, trackH, g_ColorBg, BORDER_FLAT);
        ObjectSetInteger(0, PREFIX + "SYM_ScrollTrack", OBJPROP_ZORDER, 142);
        
        // Thumb Calculation
        int maxScrollRows = totalRows - visibleRows;
        g_ScrollSymbolManager.ViewportHeight = trackH;
        g_ScrollSymbolManager.ContentHeight = totalRows * 35; // Approximation for ratio
        
        int thumbH = (int)((double)visibleRows / (double)totalRows * trackH);
        if(thumbH < 20) thumbH = 20;
        
        // Current Scroll Y mapping
        // g_SymMgr_ScrollOffset is index of first visible symbol. 
        // We want g_SymMgr_ScrollOffset / cols to be the current row.
        int currentRow = g_SymMgr_ScrollOffset / cols;
        int thumbY = trackY + (int)((double)currentRow / (double)maxScrollRows * (trackH - thumbH));
        
        CreateRect("SYM_ScrollThumb", scrollX, thumbY, trackW, thumbH, g_ColorText, BORDER_FLAT);
        ObjectSetInteger(0, PREFIX + "SYM_ScrollThumb", OBJPROP_ZORDER, 143);
    }
    else
    {
        ObjectsDeleteAll(0, PREFIX + "SYM_Scroll");
    }
}

//+------------------------------------------------------------------+
//| ACTION: TOGGLE MANAGER                                           |
//+------------------------------------------------------------------+
void ToggleSymbolManager(bool force = false)
{
    if(force) g_PanelSymbolManager.IsVisible = true;
    else g_PanelSymbolManager.IsVisible = !g_PanelSymbolManager.IsVisible;
    
    if(!g_PanelSymbolManager.IsVisible)
    {
        ObjectsDeleteAll(0, PREFIX + "SYM_");
    }
    
    RefreshAllPanels();
}
