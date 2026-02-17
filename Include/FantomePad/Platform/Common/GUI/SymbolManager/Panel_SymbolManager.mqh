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
   int headerH = 20;
   int catListW = 180;
   int contentY = y + headerH;
   int contentH = h - headerH;
   
   int gridX = x + catListW + 10;
   int gridY = contentY + 10;
   int gridW = w - catListW - 20;
   int gridH = contentH - 20;
   
   // DRAG OPTIMIZATION
   if(g_PanelSymbolManager.IsDragging && ObjectFind(0, PREFIX + "SYM_Bg") >= 0)
   {
       SetObjPosition("SYM_Bg", x, y);
       SetObjPosition("SYM_CatBg", x, contentY);
       SetObjPosition("SYM_Sep", x + catListW, contentY + 10);
       
       int catStartY = contentY + 10;
       for(int i=0; i<g_SymMgr_CategoryCount; i++)
       {
           SetObjPosition("SYM_Cat_" + IntegerToString(i), x + 5, catStartY);
           catStartY += 25 + 2;
           if(catStartY > y + h - 10) break;
       }
       
       int cols_drag = 3;
       int cellW_drag = (gridW / cols_drag) - 5;
       int cellH_drag = 30;
       
       for(int i=0; i<g_SymMgr_MaxVisible; i++)
       {
           if(g_SymMgr_ScrollOffset + i >= g_SymMgr_SymbolCount) break;
           int col = i % cols_drag;
           int row = i / cols_drag;
           SetObjPosition("SYM_Sym_" + IntegerToString(i), gridX + (col * (cellW_drag + 5)), gridY + (row * (cellH_drag + 5)));
       }
       
       if(ObjectFind(0, PREFIX + "SYM_ScrollTrack") >= 0)
       {
           SetObjPosition("SYM_ScrollTrack", x + w - 15, gridY);
           // Thumb pos is dynamic based on offset, but offset doesn't change during drag
           long thumbH = ObjectGetInteger(0, PREFIX + "SYM_ScrollThumb", OBJPROP_YSIZE);
           int totalRows = (g_SymMgr_SymbolCount + cols_drag - 1) / cols_drag;
           int visibleRows = gridH / (cellH_drag + 5);
           int maxScrollRows = totalRows - visibleRows;
           int currentRow = g_SymMgr_ScrollOffset / cols_drag;
           int thumbY = gridY + (int)((double)currentRow / (double)maxScrollRows * (gridH - (int)thumbH));
           SetObjPosition("SYM_ScrollThumb", x + w - 15, thumbY);
       }
       
       ChartRedraw();
       return;
   }

   // 1. MAIN WINDOW
   CreateRect("SYM_Bg", x, y, w, h, g_ColorBg, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "SYM_Bg", OBJPROP_ZORDER, 141);
   ObjectSetInteger(0, PREFIX + "SYM_Bg", OBJPROP_BORDER_COLOR, g_ColorInput);
   ObjectSetInteger(0, PREFIX + "SYM_Bg", OBJPROP_WIDTH, 2); 

   // 2. MARGIN
   SetObjVisible("SYM_Header", false); // Not used

   // 3. CATEGORY LIST
   CreateRect("SYM_CatBg", x, contentY, catListW, contentH, g_ColorBg, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "SYM_CatBg", OBJPROP_ZORDER, 142);
   
   CreateRect("SYM_Sep", x + catListW, contentY + 10, 1, contentH - 20, C'50,50,50', BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "SYM_Sep", OBJPROP_ZORDER, 142);
   
   int catItemH = 25;
   int catStartY = contentY + 10;
   
   for(int i=0; i<g_SymMgr_CategoryCount; i++)
   {
       string catName = g_SymMgr_Categories[i];
       bool isSelected = (catName == g_SymMgr_CurrentCategory);
       color catBg = isSelected ? g_ColorBtnActive : g_ColorBg;
       color catTxt = isSelected ? clrWhite : g_ColorText;
       
       string btnName = "SYM_Cat_" + IntegerToString(i);
       CreateButton(btnName, catName, x + 5, catStartY, catListW - 10, catItemH, catBg, catTxt);
       ObjectSetInteger(0, PREFIX + btnName, OBJPROP_ZORDER, 143);
       ObjectSetInteger(0, PREFIX + btnName, OBJPROP_ALIGN, ALIGN_LEFT);
       SetObjVisible(btnName, (catStartY + catItemH <= y + h - 10));
       
       catStartY += catItemH + 2;
   }
   
   // 4. SYMBOL GRID
   
   int cols = 3;
   int cellW = (gridW / cols) - 5;
   int cellH = 30;
   
   int rows = gridH / (cellH + 5);
   g_SymMgr_MaxVisible = rows * cols; 
   
   for(int i=0; i<100; i++) // Fixed pool
   {
       string btnName = "SYM_Sym_" + IntegerToString(i);
       int dataIdx = g_SymMgr_ScrollOffset + i;
       
       if(i >= g_SymMgr_MaxVisible || dataIdx >= g_SymMgr_SymbolCount)
       {
           SetObjVisible(btnName, false);
           continue; 
       }
       
       string sym = g_SymMgr_SymbolsInCat[dataIdx];
       int col = i % cols;
       int row = i / cols;
       int cellX = gridX + (col * (cellW + 5));
       int cellY = gridY + (row * (cellH + 5));
       
       bool isInMarket = (bool)SymbolInfoInteger(sym, SYMBOL_SELECT);
       color cellBg = isInMarket ? g_ColorBtnActive : g_ColorBg; 
       
       CreateButton(btnName, sym, cellX, cellY, cellW, cellH, cellBg, g_ColorText);
       ObjectSetInteger(0, PREFIX + btnName, OBJPROP_ZORDER, 143);
       SetObjVisible(btnName, true);
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
       
       CreateRect("SYM_ScrollTrack", scrollX, trackY, trackW, trackH, g_ColorBg, BORDER_FLAT);
       ObjectSetInteger(0, PREFIX + "SYM_ScrollTrack", OBJPROP_ZORDER, 142);
        SetObjVisible("SYM_ScrollTrack", true);
       
       int maxScrollRows = totalRows - visibleRows;
       g_ScrollSymbolManager.ViewportHeight = trackH;
       g_ScrollSymbolManager.ContentHeight = totalRows * 35; 
       
       int thumbH = (int)((double)visibleRows / (double)totalRows * trackH);
       if(thumbH < 20) thumbH = 20;
       
       int currentRow = g_SymMgr_ScrollOffset / cols;
       int thumbY = trackY + (int)((double)currentRow / (double)maxScrollRows * (trackH - thumbH));
       
       CreateRect("SYM_ScrollThumb", scrollX, thumbY, trackW, thumbH, g_ColorText, BORDER_FLAT);
       ObjectSetInteger(0, PREFIX + "SYM_ScrollThumb", OBJPROP_ZORDER, 143);
        SetObjVisible("SYM_ScrollThumb", true);
   }
   else
   {
       SetObjVisible("SYM_ScrollTrack", false);
       SetObjVisible("SYM_ScrollThumb", false);
   }
   ChartRedraw();
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
