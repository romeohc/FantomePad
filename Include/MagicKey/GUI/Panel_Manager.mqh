//+------------------------------------------------------------------+
//|                                           Panel_Manager.mqh      |
//|                                                MagicKey Project  |
//+------------------------------------------------------------------+
#property strict

// --- Manager Panel Globals ---
int MgrPanelX = 20; // Top Left (offset slightly)
int MgrPanelY = 20; 
   int MgrPanelW = 410; 
   int MgrPanelH = 40;

void CreateManagerPanel()
{
   // Background (Fixed position, no drag logic implied)
   CreateRect("Mgr_Bg", MgrPanelX, MgrPanelY, MgrPanelW, MgrPanelH, g_ColorBg, BORDER_FLAT);

   // Buttons Layout
   int btnW = 55;
   int btnH = 24;
   int margin = 5;
   int startX = MgrPanelX + margin;
   int startY = MgrPanelY + 8; // Vertically centered approx
   
   // Button 1: Trade Panel (Toggle Main)
   color bgTrade = IsMainPanelVisible ? g_ColorGreen : g_ColorBtnInvalid;
   CreateButton("Mgr_Btn_Main", "Trade", startX, startY, btnW, btnH, bgTrade, g_ColorText);
   
   // Button 2: Positions Panel (Toggle Positions)
   int currentX = startX + btnW + margin;
   color bgPos = IsPositionsPanelVisible ? g_ColorGreen : g_ColorBtnInvalid;
   CreateButton("Mgr_Btn_Pos", "Pos", currentX, startY, btnW, btnH, bgPos, g_ColorText);

   // Button 3: Info Panel (Toggle Account Info)
   currentX += btnW + margin;
   color bgInfo = IsInfoPanelVisible ? g_ColorGreen : g_ColorBtnInvalid;
   CreateButton("Mgr_Btn_Info", "Info", currentX, startY, btnW, btnH, bgInfo, g_ColorText);

   // Button 4: History (New)
   currentX += btnW + margin;
   color bgHist = IsHistoryPanelVisible ? g_ColorGreen : g_ColorBtnInvalid;
   CreateButton("Mgr_Btn_History", "Hist", currentX, startY, btnW, btnH, bgHist, g_ColorText);
   
   // Button 5: Settings (Toggle Config)
   currentX += btnW + margin;
   color bgSet = IsSettingsOpen ? g_ColorGreen : g_ColorBtnInvalid;
   CreateButton("Mgr_Btn_Settings", "Set", currentX, startY, btnW, btnH, bgSet, g_ColorText);

   // Button 6: Symbol Select
   currentX += btnW + margin;
   int symBtnW = 100; // Wider for symbol name
   // We reuse the ID "Btn_SymbolSelect" so GUI_Master logic works
   CreateButton("Btn_SymbolSelect", Symbol(), currentX, startY, symBtnW, btnH, g_ColorInput, g_ColorText);
}

// Logic to clean up if needed provided here, though GUI_Master handles most redraws
void UpdateManagerPanel()
{
   CreateManagerPanel();
}

//+------------------------------------------------------------------+
//| GESTION DE LA LISTE DÉROULANTE (Moved from Panel_Main)           |
//+------------------------------------------------------------------+
void CloseSymbolList()
{
   // Supprime tous les objets de liste
   for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, PREFIX + "ListItem_") >= 0 || 
         name == PREFIX + "ScrollTrack" || 
         name == PREFIX + "ScrollThumb" ||
         name == PREFIX + "ListContainer") 
      {
         ObjectDelete(0, name);
      }
   }
   
   IsListOpen = false;
   VisibleListItems = 0;
   g_SymbolListOffset = 0; 
   ChartRedraw();
}

void DrawSymbolList()
{
   long x = ObjectGetInteger(0, PREFIX + "Btn_SymbolSelect", OBJPROP_XDISTANCE);
   long y = ObjectGetInteger(0, PREFIX + "Btn_SymbolSelect", OBJPROP_YDISTANCE);
   long w = ObjectGetInteger(0, PREFIX + "Btn_SymbolSelect", OBJPROP_XSIZE);
   long h = ObjectGetInteger(0, PREFIX + "Btn_SymbolSelect", OBJPROP_YSIZE);
   
   int total = SymbolsTotal(true);
   int itemHeight = 25;
   int scrollBarWidth = 10;
   
   // Determine visible count
   int maxVis = g_SymbolListMaxVisible;
   int count = (total > maxVis) ? maxVis : total;
   
   // Safety clamp offset
   if(g_SymbolListOffset > total - count) g_SymbolListOffset = total - count;
   if(g_SymbolListOffset < 0) g_SymbolListOffset = 0;
   
   VisibleListItems = count;
   
   bool showScroll = (total > maxVis);
   
   int startY = (int)y + (int)h + 2; 
   int contentHeight = count * itemHeight;
   int containerWidth = (int)w; // Keep same width
   
   CreateRect("ListContainer", (int)x, startY - 2, containerWidth, contentHeight + 4, g_ColorBg, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "ListContainer", OBJPROP_ZORDER, 9); 
   ObjectSetInteger(0, PREFIX + "ListContainer", OBJPROP_BGCOLOR, g_ColorBg); 
   ObjectSetInteger(0, PREFIX + "ListContainer", OBJPROP_BORDER_COLOR, g_ColorBg);
   
   int itemWidth = showScroll ? containerWidth - scrollBarWidth - 2 : containerWidth - 4;
   int itemX = (int)x + 2;
   int currentY = startY;
   
   // ITEMS
   for(int i = 0; i < count; i++)
   {
      int dataIdx = g_SymbolListOffset + i;
      if(dataIdx >= total) break;
      
      string symName = SymbolName(dataIdx, true);
      string btnName = "ListItem_" + IntegerToString(i);
      
      CreateButton(btnName, symName, itemX, currentY, itemWidth, itemHeight, g_ColorInput, g_ColorText);
      ObjectSetString(0, PREFIX + btnName, OBJPROP_TEXT, symName); 
      ObjectSetInteger(0, PREFIX + btnName, OBJPROP_ZORDER, 10);
      ObjectSetInteger(0, PREFIX + btnName, OBJPROP_BORDER_COLOR, g_ColorInput);
      ObjectSetInteger(0, PREFIX + btnName, OBJPROP_COLOR, g_ColorText); 
      
      currentY += itemHeight;
   }
   
   // SCROLLBAR
   if(showScroll)
   {
       int trackX = (int)x + containerWidth - scrollBarWidth - 2;
       int trackH = contentHeight;
       int trackY = startY;
       
       // Track
       CreateRect("ScrollTrack", trackX, trackY, scrollBarWidth, trackH, g_ColorBg, BORDER_FLAT);
       ObjectSetInteger(0, PREFIX + "ScrollTrack", OBJPROP_ZORDER, 10);
       
       // Thumb
       double ratio = (double)count / (double)total;
       int thumbH = (int)(trackH * ratio);
       if(thumbH < 20) thumbH = 20; // Min height
       
       // Position
       int maxOffset = total - count;
       double scrollPrc = (maxOffset > 0) ? (double)g_SymbolListOffset / (double)maxOffset : 0;
       int availableTrack = trackH - thumbH;
       int relativeY = (int)(scrollPrc * availableTrack);
       
       CreateRect("ScrollThumb", trackX + 1, trackY + relativeY, scrollBarWidth - 2, thumbH, g_ColorBtnValid, BORDER_FLAT);
       ObjectSetInteger(0, PREFIX + "ScrollThumb", OBJPROP_ZORDER, 11);
       ObjectSetInteger(0, PREFIX + "ScrollThumb", OBJPROP_BGCOLOR, g_ColorText); 
   }
   
   ChartRedraw();
}

void ToggleSymbolList()
{
   if(IsListOpen) CloseSymbolList();
   else 
   {
      IsListOpen = true;
      DrawSymbolList();
   }
}
