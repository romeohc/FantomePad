//+------------------------------------------------------------------+
//|                                               GUI_Event_Drag.mqh |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| PROCESS DRAG LOGIC                                               |
//| Called from MouseMove when button is pressed                     |
//+------------------------------------------------------------------+
void ProcessDragLogic(int mouseX, int mouseY)
{
    g_BlockClick = false; // Reset safety block on new press
    bool processed = false;
         
    // DISABLE CHART SCROLL IF DRAGGING OR OVER LIST
    bool isOverList = false;
    if(IsListOpen)
    {
        long lx = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_XDISTANCE);
        long ly = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_YDISTANCE);
        long lw = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_XSIZE);
        long lh = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_YSIZE);
        
        if(mouseX >= lx && mouseX <= lx + lw && mouseY >= ly && mouseY <= ly + lh)
        {
           isOverList = true;
        }
    }

    bool anyDrag = g_PanelMain.IsDragging || g_PanelSettings.IsDragging || g_PanelAccount.IsDragging || g_PanelPositions.IsDragging || g_PanelHistory.IsDragging || g_PanelSymbolManager.IsDragging || IsScrollDragging || g_ScrollSettings.IsDragging || g_ScrollHistory.IsDragging || g_ScrollAccountOrders.IsDragging;
    if(anyDrag || isOverList)
    {
        ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
    }
 
    // --- 0. DRAG SCROLLBAR (SYMBOL LIST) ---
    if(IsListOpen && !g_PanelMain.IsDragging && !g_PanelSettings.IsDragging && !g_ScrollSettings.IsDragging)
    {
        int total = SymbolsTotal(true);
        int trackH = (int)ObjectGetInteger(0, PREFIX + "ScrollTrack", OBJPROP_YSIZE);
        int maxScroll = total - VisibleListItems;
        if(maxScroll < 0) maxScroll = 0;
        
        if(HandleScrollDrag(IsScrollDragging, ScrollDragY, g_SymbolListOffset, mouseX, mouseY, "ScrollThumb", trackH, maxScroll))
        {
            DrawSymbolList();
        }
    }
    
    // --- 0.5 DRAG SCROLLBAR (SETTINGS) ---
    if(g_PanelSettings.IsVisible && !g_PanelMain.IsDragging && !g_PanelSettings.IsDragging && !IsScrollDragging)
    {
        int maxScroll = g_ScrollSettings.ContentHeight - g_ScrollSettings.ViewportHeight;
        if(maxScroll < 0) maxScroll = 0;
        
        if(HandleScrollDrag(g_ScrollSettings.IsDragging, g_ScrollSettings.DragAnchorY, g_ScrollSettings.ScrollY, mouseX, mouseY, "Set_ScrollThumb", g_ScrollSettings.ViewportHeight, maxScroll))
        {
            OpenSettings();
        }
    }
    
    // --- 0.6 DRAG SCROLLBAR (HISTORY) ---
    if(g_PanelHistory.IsVisible && !g_PanelMain.IsDragging && !g_PanelSettings.IsDragging && !IsScrollDragging && !g_ScrollSettings.IsDragging && !g_PanelHistory.IsDragging)
    {
        int maxScroll = g_ScrollHistory.ContentHeight - g_ScrollHistory.ViewportHeight;
        if(maxScroll < 0) maxScroll = 0;
        
        if(HandleScrollDrag(g_ScrollHistory.IsDragging, g_ScrollHistory.DragAnchorY, g_ScrollHistory.ScrollY, mouseX, mouseY, "Hist_ScrollThumb", g_ScrollHistory.ViewportHeight, maxScroll))
        {
            CreateHistoryPanel();
        }
    }
    
    // --- 0.7 DRAG SCROLLBAR (ACCOUNT ORDERS) ---
    if(g_PanelAccount.IsVisible && !g_PanelMain.IsDragging && !g_PanelSettings.IsDragging && !IsScrollDragging && !g_ScrollSettings.IsDragging && !g_ScrollHistory.IsDragging && !g_PanelAccount.IsDragging)
    {
        int maxScroll = g_TotalAccountOrderCount - g_AccountOrdersMaxVisible;
        if(maxScroll < 0) maxScroll = 0;
        
        // Calculate track height for orders scrollbar
        int rowH = 28;
        int gapY = 4;
        int visibleCount = (g_TotalAccountOrderCount > g_AccountOrdersMaxVisible) ? g_AccountOrdersMaxVisible : g_TotalAccountOrderCount;
        int trackH = visibleCount * (rowH + gapY) - gapY;
        if(trackH < 20) trackH = 20;
        
        if(HandleScrollDrag(g_ScrollAccountOrders.IsDragging, g_ScrollAccountOrders.DragAnchorY, g_AccountOrdersScrollOffset, mouseX, mouseY, "Account_Ord_ScrollThumb", trackH, maxScroll))
        {
            UpdateAccountLayout();
        }
    }
    // --- 0.8 DRAG SCROLLBAR (SYMBOL MANAGER) ---
    if(g_PanelSymbolManager.IsVisible && !processed && !g_PanelMain.IsDragging && !g_PanelSettings.IsDragging && !IsScrollDragging && !g_PanelSymbolManager.IsDragging)
    {
        int cols = 3;
        int totalRows = (g_SymMgr_SymbolCount + cols - 1) / cols;
        int visibleRows = g_SymMgr_MaxVisible / cols;
        int maxScrollRows = totalRows - visibleRows;
        if(maxScrollRows < 0) maxScrollRows = 0;
        
        int currentRow = g_SymMgr_ScrollOffset / cols;
        
        if(HandleScrollDrag(g_ScrollSymbolManager.IsDragging, g_ScrollSymbolManager.DragAnchorY, currentRow, mouseX, mouseY, "SYM_ScrollThumb", g_ScrollSymbolManager.ViewportHeight, maxScrollRows))
        {
            g_SymMgr_ScrollOffset = currentRow * cols;
            // Cap it
            if(g_SymMgr_ScrollOffset + g_SymMgr_MaxVisible > g_SymMgr_SymbolCount)
                g_SymMgr_ScrollOffset = MathMax(0, g_SymMgr_SymbolCount - g_SymMgr_MaxVisible);
            if(g_SymMgr_ScrollOffset < 0) g_SymMgr_ScrollOffset = 0;
            
            CreateSymbolManagerPanel();
            processed = true;
        }
    }
 
    if(g_ScrollSymbolManager.IsDragging) processed = true;
 
    // --- PANELS DRAG ---
    
    // 1. SETTINGS PANEL
    if(g_PanelSettings.IsVisible && !g_PanelMain.IsDragging && !IsScrollDragging && !g_ScrollSettings.IsDragging)
    {
        // Initialisation position si nécessaire
        if(g_PanelSettings.X == -1)
        {
           int cw = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
           int ch = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
           g_PanelSettings.X = (cw/2) - (300/2);
           g_PanelSettings.Y = (ch/2) - (350/2);
        }
        
        if(HandlePanelDrag(g_PanelSettings.IsDragging, g_PanelSettings.X, g_PanelSettings.Y, g_PanelSettings.DragOffsetX, g_PanelSettings.DragOffsetY, mouseX, mouseY, 340, 50 + g_ScrollSettings.ViewportHeight))
        {
           OpenSettings();
           processed = true;
        }
    }
    
    // 2. ACCOUNT PANEL
    if(!processed && g_PanelAccount.IsVisible && !g_PanelSettings.IsDragging && !g_PanelMain.IsDragging && !IsScrollDragging)
    {
         if(HandlePanelDrag(g_PanelAccount.IsDragging, g_PanelAccount.X, g_PanelAccount.Y, g_PanelAccount.DragOffsetX, g_PanelAccount.DragOffsetY, mouseX, mouseY, 200, 150, "Account_Bg"))
         {
             UpdateAccountLayout();
             processed = true;
         }
    }

    // 3. POSITIONS PANEL
    if(!processed && g_PanelPositions.IsVisible && !g_PanelSettings.IsDragging && !g_PanelMain.IsDragging && !IsScrollDragging)
    {
        if(HandlePanelDrag(g_PanelPositions.IsDragging, g_PanelPositions.X, g_PanelPositions.Y, g_PanelPositions.DragOffsetX, g_PanelPositions.DragOffsetY, mouseX, mouseY, 280, 150, "Pos_Bg"))
        {
            UpdatePositionsLayout();
            processed = true;
        }
    }

    // 4. HISTORY PANEL
    if(!processed && g_PanelHistory.IsVisible && !g_PanelSettings.IsDragging && !g_PanelPositions.IsDragging && !g_PanelAccount.IsDragging && !g_PanelMain.IsDragging && !IsScrollDragging && !g_ScrollHistory.IsDragging)
    {
        if(HandlePanelDrag(g_PanelHistory.IsDragging, g_PanelHistory.X, g_PanelHistory.Y, g_PanelHistory.DragOffsetX, g_PanelHistory.DragOffsetY, mouseX, mouseY, 800, 200, "Hist_Bg"))
        {
            CreateHistoryPanel();
            processed = true;
        }
    }
    
    // 5. SYMBOL MANAGER PANEL
    if(!processed && g_PanelSymbolManager.IsVisible && !g_PanelSettings.IsDragging && !g_PanelPositions.IsDragging && !g_PanelAccount.IsDragging && !g_PanelHistory.IsDragging && !g_PanelMain.IsDragging && !IsScrollDragging)
    {
        if(HandlePanelDrag(g_PanelSymbolManager.IsDragging, g_PanelSymbolManager.X, g_PanelSymbolManager.Y, g_PanelSymbolManager.DragOffsetX, g_PanelSymbolManager.DragOffsetY, mouseX, mouseY, g_PanelSymbolManager.Width, g_PanelSymbolManager.Height, "SYM_Bg"))
        {
            CreateSymbolManagerPanel();
            processed = true;
        }
    }
    
    // 6. MAIN PANEL
    if(!processed && !g_PanelSettings.IsDragging && !g_PanelAccount.IsDragging && !g_PanelPositions.IsDragging && !g_PanelHistory.IsDragging && !IsScrollDragging && !g_ScrollSettings.IsDragging && !g_ScrollHistory.IsDragging)
    {
       // Initialisation position si nécessaire
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
       }
    }
}

//+------------------------------------------------------------------+
//| PROCESS DRAG END (Mouse Up)                                      |
//+------------------------------------------------------------------+
void ProcessDragEnd()
{
   bool isOverList = false;
   if(IsListOpen)
   {
       long lx = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_XDISTANCE);
       long ly = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_YDISTANCE);
       long lw = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_XSIZE);
       long lh = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_YSIZE);
       
       if(LastMouseX >= lx && LastMouseX <= lx + lw && LastMouseY >= ly && LastMouseY <= ly + lh)
       {
          isOverList = true;
       }
   }

   bool wasDragging = (g_PanelMain.IsDragging || g_PanelSettings.IsDragging || g_PanelAccount.IsDragging || g_PanelPositions.IsDragging || g_PanelHistory.IsDragging || g_PanelSymbolManager.IsDragging);
   
   if(g_PanelMain.IsDragging)
   {
      // Calculate Height dynamically as done in Drag
      long h = ObjectGetInteger(0, PREFIX + "Bg", OBJPROP_YSIZE);
      if(h < 50) h = 200;
      
      ApplyPanelSafety(g_PanelMain.X, g_PanelMain.Y, g_PanelMain.Width, (int)h);
      g_PanelMain.IsDragging = false;
      UpdateUIMode(); // Apply Position
   }
   
   if(g_PanelSettings.IsDragging)
   {
      int h = 50 + g_ScrollSettings.ViewportHeight;
      ApplyPanelSafety(g_PanelSettings.X, g_PanelSettings.Y, 340, h); 
      g_PanelSettings.IsDragging = false;
      OpenSettings(); // Apply Position
   }
   
   if(g_PanelAccount.IsDragging)
   {
      long h = ObjectGetInteger(0, PREFIX + "Account_Bg", OBJPROP_YSIZE);
      if(h < 50) h = 150;
      ApplyPanelSafety(g_PanelAccount.X, g_PanelAccount.Y, 200, (int)h);
      g_PanelAccount.IsDragging = false;
      UpdateAccountLayout(); // Apply Position
   }
   
   if(g_PanelPositions.IsDragging)
   {
      long h = ObjectGetInteger(0, PREFIX + "Pos_Bg", OBJPROP_YSIZE);
      if(h < 50) h = 150;
      ApplyPanelSafety(g_PanelPositions.X, g_PanelPositions.Y, 280, (int)h);
      g_PanelPositions.IsDragging = false;
      UpdatePositionsLayout(); // Apply Position
   }
   
   if(g_PanelHistory.IsDragging)
   {
      long h = ObjectGetInteger(0, PREFIX + "Hist_Bg", OBJPROP_YSIZE);
      if(h < 50) h = 200;
      ApplyPanelSafety(g_PanelHistory.X, g_PanelHistory.Y, 800, (int)h);
      g_PanelHistory.IsDragging = false;
      CreateHistoryPanel(); // Apply Position
   }

   if(g_PanelSymbolManager.IsDragging)
   {
      ApplyPanelSafety(g_PanelSymbolManager.X, g_PanelSymbolManager.Y, g_PanelSymbolManager.Width, g_PanelSymbolManager.Height);
      g_PanelSymbolManager.IsDragging = false;
      CreateSymbolManagerPanel(); // Apply Position
   }
   
   if(wasDragging) SaveConfigToFile();

   if(IsScrollDragging)
   {
       IsScrollDragging = false;
       g_BlockClick = true; // Block subsequent click event from this release
   }
   if(g_ScrollSettings.IsDragging)
   {
       g_ScrollSettings.IsDragging = false;
       g_BlockClick = true;
   }
   if(g_ScrollHistory.IsDragging)
   {
      g_ScrollHistory.IsDragging = false;
      g_BlockClick = true;
   }
   if(g_ScrollAccountOrders.IsDragging)
   {
      g_ScrollAccountOrders.IsDragging = false;
      g_BlockClick = true;
   }
   if(g_ScrollSymbolManager.IsDragging)
   {
      g_ScrollSymbolManager.IsDragging = false;
      g_BlockClick = true;
   }
   
   // Re-enable chart scroll ONLY if not over list and not in other modal state
   if(!isOverList) 
   {
       ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
   }
   else
   {
       // Keep disabled if hovering list to allow wheel scroll without chart scroll
       ChartSetInteger(0, CHART_MOUSE_SCROLL, false); 
   }
   ChartRedraw();
}
