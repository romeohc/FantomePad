//+------------------------------------------------------------------+
//|                                           Panel_Navigation.mqh   |
//|                                           FantomePad Project     |
//+------------------------------------------------------------------+
#property strict

// --- Navigation Panel Globals moved to TPanelState g_PanelNavigation ---




//+------------------------------------------------------------------+
//| AUTO-TRADING WARNING LOGIC                                       |
//+------------------------------------------------------------------+
void UpdateAutoTradingWarning()
{
    string bgName = PREFIX + "Nav_Warn_Bg";
    string txtName = PREFIX + "Nav_Warn_Txt";
    
    // Check if AutoTrading is allowed globally
    if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
    {
       // Position Logic
       int panelCenterX = g_PanelNavigation.X + (g_PanelNavigation.Width / 2);
       int rectW = 150;
       int rectH = 20;
       int rectX = panelCenterX - (rectW / 2);
       int rectY = g_PanelNavigation.Y - 25;
       
       // Safety: Put below if too close to top
       if(rectY < 5) rectY = g_PanelNavigation.Y + g_PanelNavigation.Height + 5; 
       
       // 1. Draw Background (Red Cell)
       if(ObjectFind(0, bgName) < 0)
       {
           CreateRect("Nav_Warn_Bg", rectX, rectY, rectW, rectH, g_ColorRed, BORDER_FLAT);
           ObjectSetInteger(0, bgName, OBJPROP_ZORDER, 100);
       }
       else
       {
           ObjectSetInteger(0, bgName, OBJPROP_XDISTANCE, rectX);
           ObjectSetInteger(0, bgName, OBJPROP_YDISTANCE, rectY);
           ObjectSetInteger(0, bgName, OBJPROP_XSIZE, rectW);
           ObjectSetInteger(0, bgName, OBJPROP_YSIZE, rectH);
           ObjectSetInteger(0, bgName, OBJPROP_BGCOLOR, g_ColorRed);
       }
       
       // 2. Draw Text (White, No Emoji)
       if(ObjectFind(0, txtName) < 0)
       {
           CreateLabel("Nav_Warn_Txt", "AutoTrading Disabled", panelCenterX, rectY + 2, 8, clrWhite, "Trebuchet MS Bold");
           ObjectSetInteger(0, txtName, OBJPROP_ANCHOR, ANCHOR_UPPER);
           ObjectSetInteger(0, txtName, OBJPROP_ZORDER, 101);
       }
       else
       {
           ObjectSetInteger(0, txtName, OBJPROP_XDISTANCE, panelCenterX);
           ObjectSetInteger(0, txtName, OBJPROP_YDISTANCE, rectY + 2);
           ObjectSetString(0, txtName, OBJPROP_TEXT, "AutoTrading Disabled"); 
           ObjectSetInteger(0, txtName, OBJPROP_COLOR, clrWhite);
           ObjectSetInteger(0, txtName, OBJPROP_ANCHOR, ANCHOR_UPPER); 
       }
    }
    else
    {
       // Clean up
       if(ObjectFind(0, bgName) >= 0) ObjectDelete(0, bgName);
       if(ObjectFind(0, txtName) >= 0) ObjectDelete(0, txtName);
    }
}

void CreateNavigationPanel()
{
   // Init Dimensions
   g_PanelNavigation.Width = 560; 
   g_PanelNavigation.Height = 35; 

   // Dynamic Positioning
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

   // 0: TL, 1: TC, 2: TR, 3: BL, 4: BC, 5: BR
   int marginY = 30; // Increased spacing from edges
   int marginX = 30;
   
   if(g_NavigationPosition == 0) // TL
   {
       g_PanelNavigation.X = marginX;
       g_PanelNavigation.Y = marginY;
   }
   else if(g_NavigationPosition == 1) // TC
   {
       g_PanelNavigation.X = (chartW / 2) - (g_PanelNavigation.Width / 2);
       g_PanelNavigation.Y = marginY;
   }
   else if(g_NavigationPosition == 2) // TR
   {
       g_PanelNavigation.X = chartW - g_PanelNavigation.Width - marginX;
       g_PanelNavigation.Y = marginY;
   }
   else if(g_NavigationPosition == 3) // BL
   {
       g_PanelNavigation.X = marginX;
       g_PanelNavigation.Y = chartH - g_PanelNavigation.Height - marginY;
   }
   else if(g_NavigationPosition == 4) // BC
   {
       g_PanelNavigation.X = (chartW / 2) - (g_PanelNavigation.Width / 2);
       g_PanelNavigation.Y = chartH - g_PanelNavigation.Height - marginY; // Reduced margin to 10px from 40px
   }
   else if(g_NavigationPosition == 5) // BR
   {
       g_PanelNavigation.X = chartW - g_PanelNavigation.Width - marginX;
       g_PanelNavigation.Y = chartH - g_PanelNavigation.Height - marginY;
   }
   
   // Safety
   if(g_PanelNavigation.X < 0) g_PanelNavigation.X = 0;
   if(g_PanelNavigation.Y < 0) g_PanelNavigation.Y = 0;

   // Background (Fixed position, no drag logic implied)
   CreateRect("Nav_Bg", g_PanelNavigation.X, g_PanelNavigation.Y, g_PanelNavigation.Width, g_PanelNavigation.Height, g_ColorBg, BORDER_FLAT);
   
   // --- BETA LABEL REMOVED ---
   if(ObjectFind(0, PREFIX + "Nav_Lbl_Beta") >= 0) ObjectDelete(0, PREFIX + "Nav_Lbl_Beta");

   // Buttons Layout
   int btnW = 85; // Increased width for text
   int btnH = 24;
   int margin = 5;
   int startX = g_PanelNavigation.X + margin;
   int startY = g_PanelNavigation.Y + 6; // Shifted up from 30
   
   // Button 1: Trade Panel (Toggle Main)
   color bgTrade = g_PanelMain.IsVisible ? g_ColorBtnActive : g_ColorBtnInvalid;
   CreateButton("Nav_Btn_Main", "Trade", startX, startY, btnW, btnH, bgTrade, g_ColorText);
   ObjectSetString(0, PREFIX + "Nav_Btn_Main", OBJPROP_FONT, "Trebuchet MS Bold");
   
   // Button 2: Positions Panel (Toggle Positions) -> "Position"
   int currentX = startX + btnW + margin;
   color bgPos = g_PanelPositions.IsVisible ? g_ColorBtnActive : g_ColorBtnInvalid;
   CreateButton("Nav_Btn_Pos", "Position", currentX, startY, btnW, btnH, bgPos, g_ColorText);
   ObjectSetString(0, PREFIX + "Nav_Btn_Pos", OBJPROP_FONT, "Trebuchet MS Bold");

   // Button 3: Account Panel (Toggle Account Info) -> "Account"
   currentX += btnW + margin;
   color bgAccount = g_PanelAccount.IsVisible ? g_ColorBtnActive : g_ColorBtnInvalid;
   CreateButton("Nav_Btn_Account", "Account", currentX, startY, btnW, btnH, bgAccount, g_ColorText);
   ObjectSetString(0, PREFIX + "Nav_Btn_Account", OBJPROP_FONT, "Trebuchet MS Bold");

   // Button 4: History -> "History"
   currentX += btnW + margin;
   color bgHist = g_PanelHistory.IsVisible ? g_ColorBtnActive : g_ColorBtnInvalid;
   CreateButton("Nav_Btn_History", "History", currentX, startY, btnW, btnH, bgHist, g_ColorText);
   ObjectSetString(0, PREFIX + "Nav_Btn_History", OBJPROP_FONT, "Trebuchet MS Bold");
   
   // Button 5: Settings (Toggle Config) -> "Settings"
   currentX += btnW + margin;
   color bgSet = g_PanelSettings.IsVisible ? g_ColorBtnActive : g_ColorBtnInvalid;
   CreateButton("Nav_Btn_Settings", "Settings", currentX, startY, btnW, btnH, bgSet, g_ColorText);
   ObjectSetString(0, PREFIX + "Nav_Btn_Settings", OBJPROP_FONT, "Trebuchet MS Bold");

    // Button 6: Symbol Select
    currentX += btnW + margin;
    int symBtnW = 100; // Wider for symbol name
    CreateButton("Nav_Btn_SymbolSelect", Symbol(), currentX, startY, symBtnW, btnH, g_ColorInput, g_ColorText);

    // Cleanup old label if exists
    if(ObjectFind(0, PREFIX + "Nav_Lbl_AccountName") >= 0) ObjectDelete(0, PREFIX + "Nav_Lbl_AccountName");
    
    UpdateAutoTradingWarning();
}

// Logic to clean up if needed provided here, though GUI_Master handles most redraws
void UpdateNavigationPanel()
{
   CreateNavigationPanel();
}

//+------------------------------------------------------------------+
//| GESTION DE LA LISTE DÉROULANTE (Moved from Panel_Main)           |
//+------------------------------------------------------------------+
void CloseSymbolList()
{
   // Supprime tous les objets de liste
   // Optimized Deletion
   ObjectsDeleteAll(0, PREFIX + "ListItem_");
   if(ObjectFind(0, PREFIX + "List_Btn_Add") >= 0) ObjectDelete(0, PREFIX + "List_Btn_Add");
   
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
   long x = ObjectGetInteger(0, PREFIX + "Nav_Btn_SymbolSelect", OBJPROP_XDISTANCE);
   long y = ObjectGetInteger(0, PREFIX + "Nav_Btn_SymbolSelect", OBJPROP_YDISTANCE);
   long w = ObjectGetInteger(0, PREFIX + "Nav_Btn_SymbolSelect", OBJPROP_XSIZE);
   long h = ObjectGetInteger(0, PREFIX + "Nav_Btn_SymbolSelect", OBJPROP_YSIZE);
   
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
   
   int headerHeight = 30; // Height for the Add button area
   int contentHeight = (count * itemHeight) + headerHeight;
   int containerWidth = (int)w; // Keep same width

   // --- DIRECTION LOGIC ---
   // If Navigation Position is Bottom (3, 4, 5), list opens Upwards
   bool opensUpwards = (g_NavigationPosition >= 3);
   
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
   // [NEW] Add Button at the top of the list or as a special header
   // We will place it as a fixed header inside the list container, shifting items down.
   
   // Create Add Button
   string addBtnName = "List_Btn_Add";
   CreateButton(addBtnName, "Edit", itemX, currentY, itemWidth, 25, g_ColorBtnActive, g_ColorText);
   ObjectSetInteger(0, PREFIX + addBtnName, OBJPROP_ZORDER, 10);
   ObjectSetString(0, PREFIX + addBtnName, OBJPROP_FONT, "Trebuchet MS Bold");
   
   currentY += headerHeight;
   
   for(int i = 0; i < count; i++)
   {
      int dataIdx = g_SymbolListOffset + i;
      if(dataIdx >= total) break;
      
      string symName = SymbolName(dataIdx, true);
      string btnName = "ListItem_" + IntegerToString(i);
      
      color itemBg = (dataIdx == g_SymbolHoverIndex) ? g_ColorBtnActive : g_ColorInput;
      
      CreateButton(btnName, symName, itemX, currentY, itemWidth, itemHeight, itemBg, g_ColorText);
      ObjectSetString(0, PREFIX + btnName, OBJPROP_TEXT, symName); 
      ObjectSetInteger(0, PREFIX + btnName, OBJPROP_ZORDER, 10);
      ObjectSetInteger(0, PREFIX + btnName, OBJPROP_BORDER_COLOR, itemBg);
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


