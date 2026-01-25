//+------------------------------------------------------------------+
//|                                           Panel_Manager.mqh      |
//|                                           FantomePad Project     |
//+------------------------------------------------------------------+
#property strict

// --- Manager Panel Globals moved to TPanelState g_PanelManager ---

void CreateManagerPanel()
{
   // Init Dimensions
   g_PanelManager.Width = 560; // Exact width for symmetry
   g_PanelManager.Height = 40;

   // Dynamic Positioning
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

   // 0: TL, 1: TC, 2: TR, 3: BL, 4: BC, 5: BR
   int marginY = 30; // Increased spacing from edges
   int marginX = 30;
   
   if(g_ManagerPosition == 0) // TL
   {
       g_PanelManager.X = marginX;
       g_PanelManager.Y = marginY;
   }
   else if(g_ManagerPosition == 1) // TC
   {
       g_PanelManager.X = (chartW / 2) - (g_PanelManager.Width / 2);
       g_PanelManager.Y = marginY;
   }
   else if(g_ManagerPosition == 2) // TR
   {
       g_PanelManager.X = chartW - g_PanelManager.Width - marginX;
       g_PanelManager.Y = marginY;
   }
   else if(g_ManagerPosition == 3) // BL
   {
       g_PanelManager.X = marginX;
       g_PanelManager.Y = chartH - g_PanelManager.Height - marginY;
   }
   else if(g_ManagerPosition == 4) // BC
   {
       g_PanelManager.X = (chartW / 2) - (g_PanelManager.Width / 2);
       g_PanelManager.Y = chartH - g_PanelManager.Height - marginY; // Reduced margin to 10px from 40px
   }
   else if(g_ManagerPosition == 5) // BR
   {
       g_PanelManager.X = chartW - g_PanelManager.Width - marginX;
       g_PanelManager.Y = chartH - g_PanelManager.Height - marginY;
   }
   
   // Safety
   if(g_PanelManager.X < 0) g_PanelManager.X = 0;
   if(g_PanelManager.Y < 0) g_PanelManager.Y = 0;

   // Background (Fixed position, no drag logic implied)
   CreateRect("Mgr_Bg", g_PanelManager.X, g_PanelManager.Y, g_PanelManager.Width, g_PanelManager.Height, g_ColorBg, BORDER_FLAT);

   // Buttons Layout
   int btnW = 85; // Increased width for text
   int btnH = 24;
   int margin = 5;
   int startX = g_PanelManager.X + margin;
   int startY = g_PanelManager.Y + 8; // Vertically centered approx
   
   // Button 1: Trade Panel (Toggle Main)
   color bgTrade = g_PanelMain.IsVisible ? g_ColorBtnActive : g_ColorBtnInvalid;
   CreateButton("Mgr_Btn_Main", "Trade", startX, startY, btnW, btnH, bgTrade, g_ColorText);
   ObjectSetString(0, PREFIX + "Mgr_Btn_Main", OBJPROP_FONT, "Trebuchet MS Bold");
   
   // Button 2: Positions Panel (Toggle Positions) -> "Manager"
   int currentX = startX + btnW + margin;
   color bgPos = g_PanelPositions.IsVisible ? g_ColorBtnActive : g_ColorBtnInvalid;
   CreateButton("Mgr_Btn_Pos", "Manager", currentX, startY, btnW, btnH, bgPos, g_ColorText);
   ObjectSetString(0, PREFIX + "Mgr_Btn_Pos", OBJPROP_FONT, "Trebuchet MS Bold");

   // Button 3: Info Panel (Toggle Account Info) -> "Account"
   currentX += btnW + margin;
   color bgInfo = g_PanelInfo.IsVisible ? g_ColorBtnActive : g_ColorBtnInvalid;
   CreateButton("Mgr_Btn_Info", "Account", currentX, startY, btnW, btnH, bgInfo, g_ColorText);
   ObjectSetString(0, PREFIX + "Mgr_Btn_Info", OBJPROP_FONT, "Trebuchet MS Bold");

   // Button 4: History -> "History"
   currentX += btnW + margin;
   color bgHist = g_PanelHistory.IsVisible ? g_ColorBtnActive : g_ColorBtnInvalid;
   CreateButton("Mgr_Btn_History", "History", currentX, startY, btnW, btnH, bgHist, g_ColorText);
   ObjectSetString(0, PREFIX + "Mgr_Btn_History", OBJPROP_FONT, "Trebuchet MS Bold");
   
   // Button 5: Settings (Toggle Config) -> "Settings"
   currentX += btnW + margin;
   color bgSet = g_PanelSettings.IsVisible ? g_ColorBtnActive : g_ColorBtnInvalid;
   CreateButton("Mgr_Btn_Settings", "Settings", currentX, startY, btnW, btnH, bgSet, g_ColorText);
   ObjectSetString(0, PREFIX + "Mgr_Btn_Settings", OBJPROP_FONT, "Trebuchet MS Bold");

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
   // Optimized Deletion
   ObjectsDeleteAll(0, PREFIX + "ListItem_");
   
   // Clean up specific container elements
   if(ObjectFind(0, PREFIX + "ScrollTrack") >= 0) ObjectDelete(0, PREFIX + "ScrollTrack");
   if(ObjectFind(0, PREFIX + "ScrollThumb") >= 0) ObjectDelete(0, PREFIX + "ScrollThumb");
   if(ObjectFind(0, PREFIX + "ListContainer") >= 0) ObjectDelete(0, PREFIX + "ListContainer");
   
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
   
   int contentHeight = count * itemHeight;
   int containerWidth = (int)w; // Keep same width

   // --- DIRECTION LOGIC ---
   // If Manager Position is Bottom (3, 4, 5), list opens Upwards
   bool opensUpwards = (g_ManagerPosition >= 3);
   
   int startY = 0;
   if(opensUpwards)
   {
      startY = (int)y - contentHeight - 2;
   }
   else
   {
      startY = (int)y + (int)h + 2; 
   }
   
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
