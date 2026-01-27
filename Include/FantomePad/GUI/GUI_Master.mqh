//+------------------------------------------------------------------+
//|                                              GUI_Master.mqh      |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

// Includes
#include "Components/Components.mqh"
#include "../Trade/Trade.mqh"       // Needs access to AutoSwitchOrderType
#include "Panel_Main.mqh"
#include "Panel_Settings.mqh"
#include "Panel_Info.mqh"
#include "Panel_Manager.mqh"
#include "Panel_Positions.mqh"
#include "Panel_History.mqh"

// --- FORWARD DECLARATIONS REMOVED (Defined in Includes or Locals) ---

//+------------------------------------------------------------------+
//| INITIALISATION GUI GLOBALE                                       |
//+------------------------------------------------------------------+
void GUI_OnInit()
{
   if(GlobalVariableCheck("FantomePad_LastSelectedTicket"))
   {
      SelectedPositionTicket = (int)GlobalVariableGet("FantomePad_LastSelectedTicket");
      GlobalVariableDel("FantomePad_LastSelectedTicket");
      g_PanelPositions.IsVisible = true;
      
      // --- INSTANT LINES UPDATE (FIXES LATENCY ON SYMBOL CHANGE) ---
      UpdateOpenOrderLines();
   }

   CreatePanel();
   CreateInfoPanel();
   CreateManagerPanel(); 
   CreatePositionsPanel();
   CreateHistoryPanel();
   
   // Apply Loaded State
   CreatePositionsPanel();
   CreateHistoryPanel();
   
   // Apply Loaded State
   if(g_PanelMain.IsVisible) 
   {
      UpdateUIMode();
      ApplyDefaultTradeValues(); // Force update defaults on Init (Symbol change)
   }
   else ToggleMainPanel(false);
   
   if(g_PanelPositions.IsVisible) TogglePositionsPanel(true);
   else TogglePositionsPanel(false);
   
   if(g_PanelInfo.IsVisible) ToggleInfoPanel(true);
   else ToggleInfoPanel(false);
   
   if(g_PanelHistory.IsVisible) ToggleHistoryPanel(true);
   else ToggleHistoryPanel(false);
   
   if(g_PanelSettings.IsVisible) OpenSettings();
}

//+------------------------------------------------------------------+
//| TOAST NOTIFICATION SYSTEM (REMOVED)                              |
//+------------------------------------------------------------------+
void UpdateToastNotification() 
{
   // Logic removed as requested
   string bgName = PREFIX + "Toast_Bg";
   string txtName = PREFIX + "Toast_Txt";
   string closeName = PREFIX + "Toast_BtnClose";
   
   if(ObjectFind(0, bgName) >= 0) ObjectDelete(0, bgName);
   if(ObjectFind(0, txtName) >= 0) ObjectDelete(0, txtName);
   if(ObjectFind(0, closeName) >= 0) ObjectDelete(0, closeName);
}

//+------------------------------------------------------------------+
//| EVENT TICK (MISE A JOUR CONTINUE)                                |
//+------------------------------------------------------------------+
void GUI_OnTick()
{
   // Throttle UI updates to save CPU (500ms)
   static uint lastUpdate = 0;
   if(GetTickCount() - lastUpdate < 500) return; 
   lastUpdate = GetTickCount();

   UpdateInfoPanel();
   UpdatePositionsValues();
   // UpdateToastNotification(); // Removed 
   // Warning update moved to Timer for responsiveness
}

//+------------------------------------------------------------------+
//| EVENT TIMER (HIGH FREQUENCY UPDATE)                              |
//+------------------------------------------------------------------+
void GUI_OnTimer()
{
   UpdateAutoTradingWarning();
}



//+------------------------------------------------------------------+
//| HELPER: RETRIEVE ORIGINAL LOT SIZE (TRACE HISTORY)               |
//+------------------------------------------------------------------+
double GetOriginalLotSize(int ticket)
{
   if(!OrderSelect(ticket, SELECT_BY_TICKET)) return 0.0;
   
   double totalLots = OrderLots();
   string comment = OrderComment();
   
   // Loop back through history to find parents
   int safety = 0;
   while(StringFind(comment, "from #") >= 0 && safety < 50)
   {
      int pos = StringFind(comment, "from #");
      string sub = StringSubstr(comment, pos + 6);
      int prevTicket = (int)StringToInteger(sub);
      
      if(OrderSelect(prevTicket, SELECT_BY_TICKET, MODE_HISTORY))
      {
         totalLots += OrderLots(); // Add the closed amount
         comment = OrderComment();
      }
      else break;
      
      safety++;
   }
   
   return totalLots;
}

//+------------------------------------------------------------------+
//| HELPER: REFRESH ALL PANELS                                       |
//+------------------------------------------------------------------+
void RefreshAllPanels()
{
    CreatePanel(); 
    if(g_PanelMain.IsVisible) UpdateUIMode();
    else ToggleMainPanel(false);
    
    CreateInfoPanel(); 
    if(!g_PanelInfo.IsVisible) ToggleInfoPanel(false);
    
    CreateManagerPanel();
    CreatePositionsPanel();
    CreateHistoryPanel();
    
    if(g_PanelSettings.IsVisible) OpenSettings();
}

//+------------------------------------------------------------------+
//| HELPER: APPLY COLOR CHANGE                                       |
//+------------------------------------------------------------------+
void ApplyColorChange(color pickedCol)
{
    if(g_ColorPickerTarget != "")
    {
       ObjectSetInteger(0, g_ColorPickerTarget, OBJPROP_BGCOLOR, pickedCol);
       ObjectSetInteger(0, g_ColorPickerTarget, OBJPROP_BORDER_COLOR, pickedCol);
       
       if(StringFind(g_ColorPickerTarget, "_Bg") > 0)          g_ColorBg = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_Head") > 0)        g_ColorHeader = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_Input") > 0)       g_ColorInput = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_Txt") > 0)         g_ColorText = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_Green") > 0)       g_ColorGreen = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_Red") > 0)         g_ColorRed = (color)pickedCol;
       
       if(StringFind(g_ColorPickerTarget, "_ChrtBg") > 0) {
          g_ColorChartBg = (color)pickedCol;
          ChartSetInteger(0, CHART_COLOR_BACKGROUND, g_ColorChartBg);
       }
       if(StringFind(g_ColorPickerTarget, "_ChrtFg") > 0) {
           g_ColorChartFg = (color)pickedCol;
           ChartSetInteger(0, CHART_COLOR_FOREGROUND, g_ColorChartFg);
       }
       
       if(StringFind(g_ColorPickerTarget, "_EntLine") > 0)     g_ColorEntryLine = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_SLLine") > 0)      g_ColorSLLine = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_TPLine") > 0)      g_ColorTPLine = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_BtnVal") > 0)      g_ColorBtnValid = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_BtnInv") > 0)      g_ColorBtnInvalid = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_BtnAct") > 0)      g_ColorBtnActive  = (color)pickedCol;
       
       if(StringFind(g_ColorPickerTarget, "_CUp") > 0) {
          g_ColorCandleUp = (color)pickedCol;
          ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, g_ColorCandleUp);
          ChartSetInteger(0, CHART_COLOR_CHART_UP, g_ColorCandleUp);
       }
       if(StringFind(g_ColorPickerTarget, "_CDown") > 0) {
          g_ColorCandleDown = (color)pickedCol;
          ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, g_ColorCandleDown);
          ChartSetInteger(0, CHART_COLOR_CHART_DOWN, g_ColorCandleDown);
       }
       if(StringFind(g_ColorPickerTarget, "_LNorm") > 0)       g_ColorListNormal = (color)pickedCol;
       if(StringFind(g_ColorPickerTarget, "_LHov") > 0)        g_ColorListHover = (color)pickedCol;
       
       SaveConfigToFile();
       RefreshAllPanels();
    }
}

//+------------------------------------------------------------------+
//| EVENT DISPATCHER                                                 |
//+------------------------------------------------------------------+
void GUI_OnChartEvent(const int id,
                      const long &lparam,
                      const double &dparam,
                      const string &sparam)
{
   // Redessiner si la fenêtre change de taille
   if(id == CHARTEVENT_CHART_CHANGE)
   {
      // --- SAFETY CHECK: Recenter panels if hidden by resize ---
      if(g_PanelMain.IsVisible) {
          long h = ObjectGetInteger(0, PREFIX + "Bg", OBJPROP_YSIZE);
          if(h < 50) h = 200; 
          ApplyPanelSafety(g_PanelMain.X, g_PanelMain.Y, g_PanelMain.Width, (int)h);
      }
      
      if(g_PanelInfo.IsVisible) {
          long h = ObjectGetInteger(0, PREFIX + "Info_Bg", OBJPROP_YSIZE);
          if(h < 50) h = 150;
          ApplyPanelSafety(g_PanelInfo.X, g_PanelInfo.Y, 200, (int)h);
      }
      
      if(g_PanelPositions.IsVisible) {
          long h = ObjectGetInteger(0, PREFIX + "Pos_Bg", OBJPROP_YSIZE);
          if(h < 50) h = 150;
          ApplyPanelSafety(g_PanelPositions.X, g_PanelPositions.Y, 280, (int)h);
      }
      
      if(g_PanelHistory.IsVisible) {
          long h = ObjectGetInteger(0, PREFIX + "Hist_Bg", OBJPROP_YSIZE);
          if(h < 50) h = 200;
          ApplyPanelSafety(g_PanelHistory.X, g_PanelHistory.Y, 800, (int)h);
      }
      
      if(g_PanelSettings.IsVisible) {
           int h = 50 + g_ScrollSettings.ViewportHeight;
           ApplyPanelSafety(g_PanelSettings.X, g_PanelSettings.Y, 340, h);
      }

      CreatePanel();
      CreateInfoPanel();
      CreateManagerPanel();
      CreatePositionsPanel();
      CreateHistoryPanel();
      if(g_PanelMain.IsVisible) UpdateUIMode();
      else ToggleMainPanel(false);
      
      if(g_PanelSettings.IsVisible) OpenSettings(); // Redraw settings if open
   }
   
   // --- CLIC SUR LE GRAPHIQUE (VIDE) ---
   if(id == CHARTEVENT_CLICK)
   {
      // On n'exécute la fermeture que si le dernier clic sur un objet date de plus de 100ms
      // car MT4 envoie parfois les deux événements presque en même temps.
      if(IsListOpen && (GetTickCount() - LastClickTime) > 100) 
      {
         CloseSymbolList();
      }
      
      // Close Color Picker on Chart Click
      // We add a delay check to prevent closing immediately if the click was also an Object Click (which updates LastClickTime)
      if(g_IsColorPickerOpen && (GetTickCount() - LastClickTime) > 100)
      {
         CloseColorPicker();
      }
   }
   
   // --- GESTION DU HOVER ET DRAG ---
   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int mouseX = (int)lparam;
      int mouseY = (int)dparam;
      int buttons = (int)sparam;
      
      // Update Globals for Wheel
      LastMouseX = mouseX;
      LastMouseY = mouseY;
      
      // --- DETECT HOVER ON LIST (POUR DISABLE CHART SCROLL) ---
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
      
      // LOGIQUE DE DRAG AND DROP
      if((buttons & 1) == 1) // Clic gauche enfoncé
      {
         g_BlockClick = false; // Reset safety block on new press
         
         // DISABLE CHART SCROLL IF DRAGGING OR OVER LIST
         bool anyDrag = g_PanelMain.IsDragging || g_PanelSettings.IsDragging || g_PanelInfo.IsDragging || g_PanelPositions.IsDragging || g_PanelHistory.IsDragging || IsScrollDragging || g_ScrollSettings.IsDragging || g_ScrollHistory.IsDragging || g_ScrollInfoOrders.IsDragging;
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
         
         // --- 0.7 DRAG SCROLLBAR (INFO ORDERS) ---
         if(g_PanelInfo.IsVisible && !g_PanelMain.IsDragging && !g_PanelSettings.IsDragging && !IsScrollDragging && !g_ScrollSettings.IsDragging && !g_ScrollHistory.IsDragging && !g_PanelInfo.IsDragging)
         {
             int maxScroll = g_TotalInfoOrderCount - g_InfoOrdersMaxVisible;
             if(maxScroll < 0) maxScroll = 0;
             
             // Calculate track height for orders scrollbar
             int rowH = 28;
             int gapY = 4;
             int visibleCount = (g_TotalInfoOrderCount > g_InfoOrdersMaxVisible) ? g_InfoOrdersMaxVisible : g_TotalInfoOrderCount;
             int trackH = visibleCount * (rowH + gapY) - gapY;
             if(trackH < 20) trackH = 20;
             
             if(HandleScrollDrag(g_ScrollInfoOrders.IsDragging, g_ScrollInfoOrders.DragAnchorY, g_InfoOrdersScrollOffset, mouseX, mouseY, "Info_Ord_ScrollThumb", trackH, maxScroll))
             {
                 UpdateInfoLayout();
             }
         }
      
         // --- PANELS DRAG ---
         bool processed = false;
         
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
         
         // 2. INFO PANEL
         if(!processed && g_PanelInfo.IsVisible && !g_PanelSettings.IsDragging && !g_PanelMain.IsDragging && !IsScrollDragging)
         {
              if(HandlePanelDrag(g_PanelInfo.IsDragging, g_PanelInfo.X, g_PanelInfo.Y, g_PanelInfo.DragOffsetX, g_PanelInfo.DragOffsetY, mouseX, mouseY, 200, 150, "Info_Bg"))
              {
                  UpdateInfoLayout();
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
         if(!processed && g_PanelHistory.IsVisible && !g_PanelSettings.IsDragging && !g_PanelPositions.IsDragging && !g_PanelInfo.IsDragging && !g_PanelMain.IsDragging && !IsScrollDragging && !g_ScrollHistory.IsDragging)
         {
             if(HandlePanelDrag(g_PanelHistory.IsDragging, g_PanelHistory.X, g_PanelHistory.Y, g_PanelHistory.DragOffsetX, g_PanelHistory.DragOffsetY, mouseX, mouseY, 800, 200, "Hist_Bg"))
             {
                 CreateHistoryPanel();
                 processed = true;
             }
         }
         
         // 5. MAIN PANEL
         if(!processed && !g_PanelSettings.IsDragging && !g_PanelInfo.IsDragging && !g_PanelPositions.IsDragging && !g_PanelHistory.IsDragging && !IsScrollDragging && !g_ScrollSettings.IsDragging && !g_ScrollHistory.IsDragging)
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
      else
      {
         // MOUSE UP
         bool wasDragging = (g_PanelMain.IsDragging || g_PanelSettings.IsDragging || g_PanelInfo.IsDragging || g_PanelPositions.IsDragging || g_PanelHistory.IsDragging);
         
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
         
         if(g_PanelInfo.IsDragging)
         {
            long h = ObjectGetInteger(0, PREFIX + "Info_Bg", OBJPROP_YSIZE);
            if(h < 50) h = 150;
            ApplyPanelSafety(g_PanelInfo.X, g_PanelInfo.Y, 200, (int)h);
            g_PanelInfo.IsDragging = false;
            UpdateInfoLayout(); // Apply Position
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
         if(g_PanelHistory.IsDragging) g_PanelHistory.IsDragging = false; // Redundant safety
         if(g_ScrollHistory.IsDragging)
         {
            g_ScrollHistory.IsDragging = false;
            g_BlockClick = true;
         }
         if(g_ScrollInfoOrders.IsDragging)
         {
            g_ScrollInfoOrders.IsDragging = false;
            g_BlockClick = true;
         }
         
         // Re-enable chart scroll ONLY if not over list and not in other modal state
         if(!isOverList) 
         {
             ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
             // Reset static state tracker (declared in Mouse Move, but we can't access it here easily without moving it global)
             // Workaround: We force it to true, so next Mouse Move cycle will re-evaluate correctly 
             // (It will see !shouldDisableScroll and if lastScrollState was false, it sets true. If we force true here, we might desync)
             // However, since static vars are local to function, we can't touch it.
             // Best approach: Move "lastScrollState" to global scope or similar.
             // OR: Since this is Mouse Up, just force it nicely. The Mouse Move logic will "heal" itself on next move.
             // But to be consistent, we should rely on Mouse Move loop or make the variable global.
             // For now, let's leave it as is, but we must acknowledge the "lastScrollState" won't know we reset it.
             // Wait, if we reset it here, on next Mouse Move, "lastScrollState" inside that function thinks it's still FALSE.
             // So !shouldDisableScroll is true, !lastScrollState is true -> It will set True again. No harm done.
             // Redundant call but safe.
         }
         else
         {
             // Keep disabled if hovering list to allow wheel scroll without chart scroll
             ChartSetInteger(0, CHART_MOUSE_SCROLL, false); 
         }
         ChartRedraw();
      }

      if(IsListOpen && !g_PanelMain.IsDragging && !g_PanelSettings.IsDragging && !IsScrollDragging)
      {
         // On boucle uniquement sur les items visibles pour optimiser
         for(int i = 0; i < VisibleListItems; i++)
         {
            string btnName = PREFIX + "ListItem_" + IntegerToString(i);
            
            // Récupération des coordonnées de l'objet
            long x = ObjectGetInteger(0, btnName, OBJPROP_XDISTANCE);
            long y = ObjectGetInteger(0, btnName, OBJPROP_YDISTANCE);
            long w = ObjectGetInteger(0, btnName, OBJPROP_XSIZE);
            long h = ObjectGetInteger(0, btnName, OBJPROP_YSIZE);
            
            // Détection si la souris est dessus
            if(mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h)
            {
               ObjectSetInteger(0, btnName, OBJPROP_BGCOLOR, ColorListHover);
            }
            else
            {
               ObjectSetInteger(0, btnName, OBJPROP_BGCOLOR, g_ColorInput);
            }
         }
         ChartRedraw();
      }

      // --- HOVER ACTIVE ORDERS (INFO PANEL) ---
      if(g_PanelInfo.IsVisible && !g_PanelMain.IsDragging && !g_PanelSettings.IsDragging && !IsScrollDragging && !g_PanelInfo.IsDragging)
      {
          bool redraw = false;
          for(int i=0; i<g_LastInfoOrderCount; i++)
          {
             string cardName = PREFIX + "Info_Ord_Bg_" + IntegerToString(i);
             // Check if object exists (safety)
             if(ObjectFind(0, cardName) < 0) continue;
             
             long x = ObjectGetInteger(0, cardName, OBJPROP_XDISTANCE);
             long y = ObjectGetInteger(0, cardName, OBJPROP_YDISTANCE);
             long w = ObjectGetInteger(0, cardName, OBJPROP_XSIZE);
             long h = ObjectGetInteger(0, cardName, OBJPROP_YSIZE);
             
             color currentColor = (color)ObjectGetInteger(0, cardName, OBJPROP_BGCOLOR);
             color targetColor = g_ColorInput;
             
             if(mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h)
             {
                targetColor = g_ColorListHover; // Use global dynamic hover color
             }
             
             if(currentColor != targetColor)
             {
                ObjectSetInteger(0, cardName, OBJPROP_BGCOLOR, targetColor);
                redraw = true;
             }
          }
          if(redraw) ChartRedraw();
      }
   }
   
   // --- MOUSE WHEEL SCROLLING ---
   if(id == CHARTEVENT_MOUSE_WHEEL)
   {
      if(IsListOpen)
      {
          // Check if mouse is over ListContainer
          long lx = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_XDISTANCE);
          long ly = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_YDISTANCE);
          long lw = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_XSIZE);
          long lh = ObjectGetInteger(0, PREFIX + "ListContainer", OBJPROP_YSIZE);
          
          if(LastMouseX >= lx && LastMouseX <= lx + lw && LastMouseY >= ly && LastMouseY <= ly + lh)
          {
              int delta = (int)dparam;
              int total = SymbolsTotal(true);
              
              if(delta > 0) // SCROLL UP
              {
                  if(g_SymbolListOffset > 0) g_SymbolListOffset--;
              }
              else // SCROLL DOWN
              {
                  if(g_SymbolListOffset < total - VisibleListItems) g_SymbolListOffset++;
              }
              
              DrawSymbolList();
              // Prevent chart scrolling if possible, but MQL4 doesn't easily allow consuming this event.
              // However, since we handled it, the user sees the list scroll.
          }
      }
      
      // --- MOUSE WHEEL FOR INFO ORDERS ---
      if(g_PanelInfo.IsVisible && g_TotalInfoOrderCount > g_InfoOrdersMaxVisible)
      {
          // Check if mouse is over the orders list area in Info Panel
          // We check if there's a scrollbar visible (meaning > 3 orders)
          if(ObjectFind(0, PREFIX + "Info_Ord_ScrollTrack") >= 0)
          {
              long trackX = ObjectGetInteger(0, PREFIX + "Info_Ord_ScrollTrack", OBJPROP_XDISTANCE);
              long trackY = ObjectGetInteger(0, PREFIX + "Info_Ord_ScrollTrack", OBJPROP_YDISTANCE);
              long trackH = ObjectGetInteger(0, PREFIX + "Info_Ord_ScrollTrack", OBJPROP_YSIZE);
              
              // Use the first order card to determine the list area
              if(ObjectFind(0, PREFIX + "Info_Ord_Bg_0") >= 0)
              {
                  long ordX = ObjectGetInteger(0, PREFIX + "Info_Ord_Bg_0", OBJPROP_XDISTANCE);
                  long ordY = ObjectGetInteger(0, PREFIX + "Info_Ord_Bg_0", OBJPROP_YDISTANCE);
                  long ordW = ObjectGetInteger(0, PREFIX + "Info_Ord_Bg_0", OBJPROP_XSIZE);
                  
                  // Check if mouse is over the orders list area (including scrollbar)
                  int scrollAreaWidth = 260 - 40; // panel width - padding*2
                  if(LastMouseX >= ordX && LastMouseX <= ordX + scrollAreaWidth && 
                     LastMouseY >= ordY && LastMouseY <= ordY + trackH + 10)
                  {
                      int delta = (int)dparam;
                      int maxOffset = g_TotalInfoOrderCount - g_InfoOrdersMaxVisible;
                      
                      if(delta > 0) // SCROLL UP
                      {
                          if(g_InfoOrdersScrollOffset > 0) g_InfoOrdersScrollOffset--;
                      }
                      else // SCROLL DOWN
                      {
                          if(g_InfoOrdersScrollOffset < maxOffset) g_InfoOrdersScrollOffset++;
                      }
                      
                      UpdateInfoLayout();
                      UpdateInfoPanel();
                  }
              }
          }
      }
   }

   // Gestion des clics boutons
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
       LastClickTime = GetTickCount(); // Enregistrer l'heure du clic sur un objet
       
       // --- SAFETY BLOCK AFTER DRAG ---
       if(g_BlockClick || IsScrollDragging)
       {
           g_BlockClick = false;
           ObjectSetInteger(0, sparam, OBJPROP_STATE, false); // Reset visual state
           ChartRedraw();
           return;
       }
       
       // --- TOAST CLOSE (REMOVED) ---
       /*
       if(sparam == PREFIX + "Toast_BtnClose")
       {
           g_ToastMsg = "";
           UpdateToastNotification(); 
           ChartRedraw();
           return;
       }
       */
   
      // --- TOGGLE RISK MODE (% / CURRENCY) ---
      if(sparam == PREFIX + "Label_RiskPerc")
      {
         RiskMode++;
         if(RiskMode > 2) RiskMode = 0;
         
         // RESET to Default Value
         if(RiskMode == 1) // Currency
         {
            ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, "0");
         }
         else if(RiskMode == 2) // R
         {
             ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, "0");
         }
         else // %
         {
            ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, "0");
         }
         
         UpdateUIMode();
         UpdateCalculatedLot();
         // Petit effet visuel
         EffectButton(sparam);
         return;
      }
      
      // --- SETTINGS ---
      if(sparam == PREFIX + "Set_Btn_MgrPos")
      {
          g_ManagerPosition++;
          if(g_ManagerPosition > 5) g_ManagerPosition = 0;
          
          // Update Text
          ObjectSetString(0, PREFIX + "Set_Btn_MgrPos", OBJPROP_TEXT, ManagerPositions[g_ManagerPosition]);
          
          // Update Real Panel
          UpdateManagerPanel();
          EffectButton(sparam);
          return;
      }

      if(sparam == PREFIX + "Set_Btn_ShowLines")
      {
          g_ShowOrderLines = !g_ShowOrderLines;
          
          // Update Text/Visuals
          string t = g_ShowOrderLines ? "ON" : "OFF";
          color b = g_ShowOrderLines ? g_ColorBtnActive : g_ColorInput;
          ObjectSetString(0, PREFIX + "Set_Btn_ShowLines", OBJPROP_TEXT, t);
          ObjectSetInteger(0, PREFIX + "Set_Btn_ShowLines", OBJPROP_BGCOLOR, b);
          
          UpdateChartLines(); 
          EffectButton(sparam);
          SaveConfigToFile();
          return;
      }

      if(sparam == PREFIX + "Set_Btn_ShowPosLines")
      {
          g_ShowPositionLines = !g_ShowPositionLines;
          
          // Update Text/Visuals
          string t2 = g_ShowPositionLines ? "ON" : "OFF";
          color b2 = g_ShowPositionLines ? g_ColorBtnActive : g_ColorInput;
          ObjectSetString(0, PREFIX + "Set_Btn_ShowPosLines", OBJPROP_TEXT, t2);
          ObjectSetInteger(0, PREFIX + "Set_Btn_ShowPosLines", OBJPROP_BGCOLOR, b2);
          
          UpdateOpenOrderLines(); // Refresh the open position lines
          EffectButton(sparam);
          SaveConfigToFile();
          return;
      }

      
      // --- MANAGER PANEL EVENTS ---
      
      // 1. Toggle Trading Panel
      if(sparam == PREFIX + "Mgr_Btn_Main")
      {
         g_PanelMain.IsVisible = !g_PanelMain.IsVisible;
         ToggleMainPanel(g_PanelMain.IsVisible);
         UpdateManagerPanel(); 
         EffectButton(sparam);
         SaveConfigToFile();
         return;
      }
      
      // 2. Button Positions Panel (Toggle Positions)
      if(sparam == PREFIX + "Mgr_Btn_Pos")
      {
         g_PanelPositions.IsVisible = !g_PanelPositions.IsVisible;
         TogglePositionsPanel(g_PanelPositions.IsVisible);
         UpdateManagerPanel(); 
         EffectButton(sparam);
         SaveConfigToFile();
         return;
      }

      // 3. Toggle Info Panel
      if(sparam == PREFIX + "Mgr_Btn_Info")
      {
         g_PanelInfo.IsVisible = !g_PanelInfo.IsVisible;
         ToggleInfoPanel(g_PanelInfo.IsVisible);
         UpdateManagerPanel(); 
         EffectButton(sparam);
         SaveConfigToFile();
         return;
      }
      
      // 3.5 History Panel
      if(sparam == PREFIX + "Mgr_Btn_History")
       {
          g_PanelHistory.IsVisible = !g_PanelHistory.IsVisible;
          ToggleHistoryPanel(g_PanelHistory.IsVisible);
          UpdateManagerPanel(); 
          EffectButton(sparam);
          SaveConfigToFile();
          return;
       }
      
      // 3. Toggle Settings (Shortcut)
      if(sparam == PREFIX + "Mgr_Btn_Settings")
      {
         ToggleSettings();
         UpdateManagerPanel(); // Refresh button state
         EffectButton(sparam);
         SaveConfigToFile();
         return;
      }

      // --- CLICK ON ACTIVE ORDER (INFO PANEL) ---
      if(StringFind(sparam, PREFIX + "Info_Ord_") >= 0)
      {
          // Extract visual index from object name
          // Pattern: PTP_Info_Ord_Bg_X or PTP_Info_Ord_Sym_X or PTP_Info_Ord_Typ_X
          int visualIdx = -1;
          
          // Find the underscore before the index
          int lastUnder = -1;
          for(int c = StringLen(sparam) - 1; c >= 0; c--)
          {
             if(StringGetCharacter(sparam, c) == '_')
             {
                lastUnder = c;
                break;
             }
          }
          
          if(lastUnder > 0)
          {
             string idxStr = StringSubstr(sparam, lastUnder + 1);
             visualIdx = (int)StringToInteger(idxStr);
          }
          
          // Get ticket from global array
          int ticket = -1;
          if(visualIdx >= 0 && visualIdx < ArraySize(g_InfoOrdersTickets))
          {
             ticket = g_InfoOrdersTickets[visualIdx];
          }
          
          if(ticket > 0 && OrderSelect(ticket, SELECT_BY_TICKET))
          {
             string symbol = OrderSymbol();
             
             // 1. Select this order in Position Manager
             SelectedPositionTicket = ticket;
             
             // 2. Open Position Manager if not already visible
             if(!g_PanelPositions.IsVisible)
             {
                g_PanelPositions.IsVisible = true;
                TogglePositionsPanel(true);
                UpdateManagerPanel(); // Update Manager Panel button states
                SaveConfigToFile();
             }
             else
             {
                // Just update the values since we changed the selected ticket
                UpdatePositionsValues();
             }
             
             // 3. Switch Chart if different symbol
             if(symbol != "" && symbol != Symbol())
             {
                // Save ticket to global variable so it persists after EA reload
                GlobalVariableSet("FantomePad_LastSelectedTicket", (double)ticket);
                ChartSetSymbolPeriod(0, symbol, Period());
                // Note: Changing symbol triggers EA reload
             }
              else
              {
                 // Same symbol: Update lines immediately (INSTANT UX)
                 UpdateOpenOrderLines();
                 ChartRedraw();
              }
          }
          
          return;
      }

      // --- HISTORY FILTER EVENTS --- 
      if(sparam == PREFIX + "Hist_Btn_Daily")
      {
         SetHistoryFilter(H_FILTER_DAILY);
         EffectButton(sparam);
         return;
      }
      if(sparam == PREFIX + "Hist_Btn_Weekly")
      {
         SetHistoryFilter(H_FILTER_WEEKLY);
         EffectButton(sparam);
         return;
      }
      if(sparam == PREFIX + "Hist_Btn_Monthly")
      {
         SetHistoryFilter(H_FILTER_MONTHLY);
         EffectButton(sparam);
         return;
      }
      if(sparam == PREFIX + "Hist_Btn_Custom")
      {
         SetHistoryFilter(H_FILTER_CUSTOM);
         EffectButton(sparam);
         return;
      }
      if(sparam == PREFIX + "Hist_Btn_Apply")
      {
          // Deprecated - Auto Update logic moved to ENDEDIT
          return;
      }

      // --- COLOR PICKER EVENTS ---
      // 1. Click on a Settings Color Button -> Open Picker
      if(StringFind(sparam, PREFIX + "Set_Btn_Color_") >= 0)
      {
         g_ColorPickerTarget = sparam;
         CreateColorPicker();
         return;
      }
       // 2. Clic sur le bouton de couleur personnalisée
       // 2. Clic sur le bouton de couleur personnalisée
       if(sparam == PREFIX + "CP_Btn_Custom")
       {
           string hexStr = ObjectGetString(0, PREFIX + "CP_Edit_Custom", OBJPROP_TEXT);
           color pickedCol = HexStringToColor(hexStr);
           
           // --- ADD TO PALETTE IF NEW ---
           bool exists = false;
           for(int i=0; i<ArraySize(g_ColorPalette); i++) {
              if(g_ColorPalette[i] == pickedCol) { exists = true; break; }
           }
           
           if(!exists) {
              int size = ArraySize(g_ColorPalette);
              ArrayResize(g_ColorPalette, size + 1);
              g_ColorPalette[size] = pickedCol;
              
              // Redraw Picker to show new color in list immediately
              CreateColorPicker();
              ChartRedraw();
           }
           
           ApplyColorChange(pickedCol);
           CloseColorPicker();
           return;
       }

       // 3. Click on a Color Picker Item -> Apply & Close
       if(StringFind(sparam, PREFIX + "CP_Item_") >= 0)
      {
         long pickedCol = ObjectGetInteger(0, sparam, OBJPROP_BGCOLOR);
         if(g_ColorPickerTarget != "")
         {
            ObjectSetInteger(0, g_ColorPickerTarget, OBJPROP_BGCOLOR, pickedCol);
            ObjectSetInteger(0, g_ColorPickerTarget, OBJPROP_BORDER_COLOR, pickedCol);
            
            // --- INSTANT SAVE ---
            if(StringFind(g_ColorPickerTarget, "_Bg") > 0)          g_ColorBg = (color)pickedCol;
            if(StringFind(g_ColorPickerTarget, "_Head") > 0)        g_ColorHeader = (color)pickedCol;
            if(StringFind(g_ColorPickerTarget, "_Input") > 0)       g_ColorInput = (color)pickedCol;
            if(StringFind(g_ColorPickerTarget, "_Txt") > 0)         g_ColorText = (color)pickedCol;
            // g_ColorLabel removed
            if(StringFind(g_ColorPickerTarget, "_Green") > 0)       g_ColorGreen = (color)pickedCol;
            if(StringFind(g_ColorPickerTarget, "_Red") > 0)         g_ColorRed = (color)pickedCol;
            if(StringFind(g_ColorPickerTarget, "_ChrtBg") > 0) {
               g_ColorChartBg = (color)pickedCol;
               ChartSetInteger(0, CHART_COLOR_BACKGROUND, g_ColorChartBg);
            }
            if(StringFind(g_ColorPickerTarget, "_ChrtFg") > 0) {
               g_ColorChartFg = (color)pickedCol;
               ChartSetInteger(0, CHART_COLOR_FOREGROUND, g_ColorChartFg);
            }
            if(StringFind(g_ColorPickerTarget, "_EntLine") > 0)     g_ColorEntryLine = (color)pickedCol;
            if(StringFind(g_ColorPickerTarget, "_SLLine") > 0)      g_ColorSLLine = (color)pickedCol;
            if(StringFind(g_ColorPickerTarget, "_TPLine") > 0)      g_ColorTPLine = (color)pickedCol;
            if(StringFind(g_ColorPickerTarget, "_BtnVal") > 0)      g_ColorBtnValid = (color)pickedCol;
            if(StringFind(g_ColorPickerTarget, "_BtnInv") > 0)      g_ColorBtnInvalid = (color)pickedCol;
            if(StringFind(g_ColorPickerTarget, "_BtnAct") > 0)      g_ColorBtnActive  = (color)pickedCol;
              
            if(StringFind(g_ColorPickerTarget, "_CUp") > 0) {
                 g_ColorCandleUp = (color)pickedCol;
                 ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, g_ColorCandleUp);
                 ChartSetInteger(0, CHART_COLOR_CHART_UP, g_ColorCandleUp);
              }
              if(StringFind(g_ColorPickerTarget, "_CDown") > 0) {
                 g_ColorCandleDown = (color)pickedCol;
                 ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, g_ColorCandleDown);
                 ChartSetInteger(0, CHART_COLOR_CHART_DOWN, g_ColorCandleDown);
              }
            if(StringFind(g_ColorPickerTarget, "_LNorm") > 0)       g_ColorListNormal = (color)pickedCol;
            if(StringFind(g_ColorPickerTarget, "_LHov") > 0)        g_ColorListHover = (color)pickedCol;
            
            SaveConfigToFile();
            
            // 1. Refresh Main Panel
            CreatePanel(); 
            if(g_PanelMain.IsVisible) UpdateUIMode();
            else ToggleMainPanel(false); // Ensure phantom objects are hidden
            
            // 2. Refresh Info Panel
            CreateInfoPanel(); 
            if(!g_PanelInfo.IsVisible) ToggleInfoPanel(false);
            
            // 3. Refresh Other Panels
            CreateManagerPanel();
            CreatePositionsPanel(); // Handles visibility internally
            CreateHistoryPanel(); // Handles visibility internally
            
            OpenSettings(); // Refresh Settings (incl. bg)
         }
         CloseColorPicker();
         return;
      }
      
      // 1. Clic sur le bouton principal de l'actif
      if(sparam == PREFIX + "Btn_SymbolSelect")
      {
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false); // Désactiver l'état "enfoncé" pour garder la couleur d'origine
         ToggleSymbolList();
         ChartRedraw();
         return; // On arrête là pour éviter les conflits
      }

      // 2. Clic sur un élément de la liste (Actif spécifique)
      if(StringFind(sparam, PREFIX + "ListItem_") >= 0)
      {
         // Récupérer le nom du symbole depuis le texte du bouton cliqué
         string selectedSymbol = ObjectGetString(0, sparam, OBJPROP_TEXT);
         
         // Mettre à jour le bouton principal
         ObjectSetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT, selectedSymbol);
         
         // Changer le symbole du graphique en arrière-plan
         ChartSetSymbolPeriod(0, selectedSymbol, Period());
         
         // Fermer la liste
         CloseSymbolList();
         UpdateCalculatedLot(); // Recalculate for new symbol
         ChartRedraw();
         return;
      }
      
      // Si on clique ailleurs et que la liste est ouverte, on la ferme
      if(IsListOpen && 
         StringFind(sparam, PREFIX + "ListItem_") < 0 && 
         sparam != PREFIX + "Btn_SymbolSelect" &&
         sparam != PREFIX + "ScrollTrack" &&
         sparam != PREFIX + "ScrollThumb")
      {
         CloseSymbolList();
      }
      
      // 4. CLICK OUTSIDE CHECK (For Color Picker)
       if(g_IsColorPickerOpen)
       {
           // If the clicked object is NOT part of the Color Picker
           if(StringFind(sparam, PREFIX + "CP_") < 0)
           {
               CloseColorPicker();
               // Do NOT return, as the user might have clicked on another valid button (like Buy/Sell)
           }
       }

      // --- FIN GESTION SÉLECTEUR ---

      // --- POSITION SELECTOR EVENTS ---
      
      // 1. Clic sur le bouton de selection de position
      if(sparam == PREFIX + "Pos_Btn_Select")
      {
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false); 
         TogglePositionList();
         ChartRedraw();
         return; 
      }
      
      // 2. Clic sur un item de la liste des positions
      if(StringFind(sparam, PREFIX + "PosListItem_") >= 0 && sparam != PREFIX + "PosListItem_None")
      {
         string prefix = PREFIX + "PosListItem_";
         string sTicket = StringSubstr(sparam, StringLen(prefix));
         SelectedPositionTicket = (int)StringToInteger(sTicket);
         
         // Auto Switch Chart Symbol
         if(OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
         {
            if(OrderSymbol() != Symbol())
            {
               GlobalVariableSet("FantomePad_LastSelectedTicket", (double)SelectedPositionTicket);
               ChartSetSymbolPeriod(0, OrderSymbol(), Period());
            }
             else
             {
                // Same symbol: Update lines immediately (INSTANT UX)
                UpdateOpenOrderLines();
             }
         }
         
         ClosePositionList();
         UpdatePositionsValues(); 
         ChartRedraw();
         return;
      }
      
      // Close List if clicked outside
      if(IsPosListOpen && 
         StringFind(sparam, PREFIX + "PosListItem_") < 0 && 
         sparam != PREFIX + "Pos_Btn_Select" &&
         sparam != PREFIX + "PosListScrollTrack" &&
         sparam != PREFIX + "PosListScrollThumb")
      {
         ClosePositionList();
      }
      
      // --- PARTIAL CLOSE SHORTCUTS ---
      if(sparam == PREFIX + "Pos_Btn_25") 
      {
         if(g_PosPartialMode == 25) g_PosPartialMode = 0; // Toggle Off
         else g_PosPartialMode = 25;
         
         ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "0"); // Reset custom text
         UpdatePartialButtonsVisuals();
         UpdatePositionsValues(); // For Validate Button
         EffectButton(sparam);
      }
      
      if(sparam == PREFIX + "Pos_Btn_50") 
      {
         if(g_PosPartialMode == 50) g_PosPartialMode = 0; // Toggle Off
         else g_PosPartialMode = 50;
         
         ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "0");
         UpdatePartialButtonsVisuals();
         UpdatePositionsValues(); 
         EffectButton(sparam);
      }
      
      if(sparam == PREFIX + "Pos_Btn_100") 
      {
         if(g_PosPartialMode == 100) g_PosPartialMode = 0; // Toggle Off
         else g_PosPartialMode = 100;
         
         ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "0");
         UpdatePartialButtonsVisuals();
         UpdatePositionsValues(); 
         EffectButton(sparam);
      }
      
      // --- BE BUTTON LOGIC ---
      if(sparam == PREFIX + "Pos_Btn_BE")
      {
         if(SelectedPositionTicket != -1 && OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
         {
             // Check Eligibility (Profit/Loss)
             int type = OrderType();
             double open = OrderOpenPrice();
             double current = (type == OP_BUY) ? MarketInfo(OrderSymbol(), MODE_BID) : MarketInfo(OrderSymbol(), MODE_ASK);
             
             // Strict check: In Loss = cannot BE
             bool inLoss = (type == OP_BUY && current < open) || (type == OP_SELL && current > open);
             
             if(inLoss) return; // Cannot activate if in loss
             
             // Toggle
             g_PosBE_Active = !g_PosBE_Active;
             
             if(g_PosBE_Active)
             {
                 // Activate BE
                 color bg = (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP) ? g_ColorGreen : g_ColorRed;
                 
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, bg);
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, clrWhite);
                 ObjectSetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT, DoubleToString(open, _Digits));
             }
             else
             {
                 // Deactivate BE -> Restore Original SL
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, g_ColorInput);
                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, g_ColorText);
                 ObjectSetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT, DoubleToString(OrderStopLoss(), _Digits));
             }
             
             UpdatePositionsValues(); // Trigger Validate Button Check
             EffectButton(sparam);
         }
         return;
      }
      
      // --- VALIDATE ACTION ---
      if(sparam == PREFIX + "Pos_Btn_Validate")
      {
         EffectButton(sparam);
         if(SelectedPositionTicket != -1 && OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
         {
             if(OrderCloseTime() == 0) // Must be open
             {
                 // 1. HANDLE CLOSE
                 double pct = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT));
                 
                 // Use Button Mode if text is empty/zero
                 if(pct <= 0.001 && g_PosPartialMode > 0) pct = (double)g_PosPartialMode;
                 
                 if(pct > 0)
                 {
                     double currentLots = OrderLots();
                     double toClose = 0.0;
                     
                     // ALWAYS calc based on ORIGINAL lots (User Request)
                     double originLots = GetOriginalLotSize(SelectedPositionTicket);
                     if(originLots <= 0) originLots = currentLots; // Safety fallback
                     
                     toClose = originLots * (pct / 100.0);
                     
                     // Normalize Lots
                     double step = MarketInfo(OrderSymbol(), MODE_LOTSTEP);
                     double min = MarketInfo(OrderSymbol(), MODE_MINLOT);
                     
                     // Round to step
                     toClose = MathFloor(toClose / step) * step;
                     
                     if(toClose < min) toClose = min; // At least close min
                     if(toClose > currentLots) toClose = currentLots; // Max all
                     
                     // If 100%, ensure close all despite rounding issues
                     if(pct >= 99.9) toClose = currentLots; 
                     
                     // Close
                     int cmd = OrderType();
                     bool closed = false;
                     
                     if(cmd > 1) // Pending Order (Limit/Stop)
                     {
                        // For pending orders, "Close" means Delete. 
                        // We ignore the percentage (toClose), assuming user wants to remove the order.
                        closed = OrderDelete(SelectedPositionTicket, clrGray);
                     }
                     else // Market Order
                     {
                        double closePrice = (cmd == OP_BUY) ? MarketInfo(OrderSymbol(), MODE_BID) : MarketInfo(OrderSymbol(), MODE_ASK);
                        closed = SafeOrderClose(SelectedPositionTicket, toClose, 0, 10, clrGray); // Use SafeOrderClose with auto-price (0)
                     }
                     if(closed)
                     {
                         ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "0"); // Reset
                         g_PosPartialMode = 0; 
                         UpdatePartialButtonsVisuals();
                         
                         UpdateOpenOrderLines(); // <--- INSTANT LINES UPDATE (FIXES LATENCY)
                         UpdateCalculatedLot();  // <--- RECALC NEW LOTS (EQUITY CHANGED)
                         
                         if(g_PanelInfo.IsVisible) CreateInfoPanel();       // <--- UPDATE BALANCE/EQUITY
                         if(g_PanelHistory.IsVisible) CreateHistoryPanel(); // <--- UPDATE HISTORY
                         
                         if(toClose >= currentLots) 
                         {
                             SelectedPositionTicket = -1; // Fully Closed
                             UpdatePositionsValues();
                             ChartRedraw();
                             return; // Stop here
                         }
                         
                         // Re-select if partial
                         if(OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET)) {}
                     }
                     else
                     {
                         // Alert("Close Error: " + IntegerToString(GetLastError()));
                     }
                 }
                 
                 // 2. HANDLE MODIFY (SL/TP)
                 // Re-read incase partial close changed something (unlikely for SL/TP values but good practice)
                 if(SelectedPositionTicket != -1 && OrderSelect(SelectedPositionTicket, SELECT_BY_TICKET))
                 {
                     double currentSL = OrderStopLoss();
                     double currentTP = OrderTakeProfit();
                     double currentOpen = OrderOpenPrice();
                     
                     double inputSL = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_SL", OBJPROP_TEXT));
                     double inputTP = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_TP", OBJPROP_TEXT));
                     double inputOpen = currentOpen;

                     // Only update Entry Price for Pending Orders
                     if(OrderType() > 1) 
                     {
                        inputOpen = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_Entry", OBJPROP_TEXT));
                     }
                     
                     // Check if changed
                     // If BE Active, override Input SL
                     if(g_PosBE_Active)
                     {
                        inputSL = OrderOpenPrice();
                     }

                     if(MathAbs(inputSL - currentSL) > Point || MathAbs(inputTP - currentTP) > Point || MathAbs(inputOpen - currentOpen) > Point)
                     {
                         bool res = SafeOrderModify(SelectedPositionTicket, inputOpen, inputSL, inputTP, (datetime)0, clrBlue);
                         if(res)
                         {
                             g_LastPosSL = inputSL;
                             g_LastPosTP = inputTP;
                             g_LastPosEntry = inputOpen;
                             
                             UpdateOpenOrderLines(); // <--- INSTANT LINES UPDATE
                             
                             // Reset BE State
                             if(g_PosBE_Active)
                             {
                                 g_PosBE_Active = false;
                                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, g_ColorInput);
                                 ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, g_ColorText);
                             }
                         }
                         else
                         {
                             // Alert("Modify Error: " + IntegerToString(GetLastError()));
                         }
                     }
                 }
            }
         }
         
         UpdatePositionsValues();
         ChartRedraw();
      }
      
      // --- END POSITION SELECTOR EVENTS ---

      // Cycle Type d'Ordre
      if(sparam == PREFIX + "Btn_Type")
      {
         if(CurrentTypeIndex == 0 && CurrentDirection == 0) // Market Buy -> Market Sell
         {
            CurrentDirection = 1;
         }
         else if(CurrentTypeIndex == 0 && CurrentDirection == 1) // Market Sell -> Buy Limit
         {
            CurrentTypeIndex = 1;
            CurrentDirection = 0;
         }
         else if(CurrentTypeIndex == 4) // Sell Stop -> Market Buy
         {
            CurrentTypeIndex = 0;
            CurrentDirection = 0;
         }
         else // Buy Limit(1) -> Sell Limit(2) -> Buy Stop(3) -> Sell Stop(4)
         {
            CurrentTypeIndex++;
         }

         UpdateUIMode(); 
         UpdateCalculatedLot(); // Mise à jour immédiate des états de boutons
         ChartRedraw();
      }

      // Actions de Trading
      if(sparam == PREFIX + "Btn_Buy" && CurrentTypeIndex == 0)
      {
         EffectButton(sparam);
         UpdateCalculatedLot(); // Ensure Lot is recalculated before execution
         
         // Sécurité : Vérifier si le SL et Risk sont définis
         double sl = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
         double risk = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));
         
         if(sl <= 0 || risk <= 0) 
         {
            // HandleTradeMessage("STOP LOSS AND RISK REQUIRED!", g_ColorRed);
            return;
         }
         
         ExecuteOrder(OP_BUY);
      }
      
      if(sparam == PREFIX + "Btn_Sell" && CurrentTypeIndex == 0)
      {
         EffectButton(sparam);
         UpdateCalculatedLot(); // Ensure Lot is recalculated before execution
         
         // Sécurité : Vérifier si le SL et Risk sont définis
         double sl = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
         double risk = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));

         if(sl <= 0 || risk <= 0) 
         {
            // HandleTradeMessage("STOP LOSS AND RISK REQUIRED!", g_ColorRed);
            return;
         }

         ExecuteOrder(OP_SELL);
      }

      if(sparam == PREFIX + "Btn_Action" && CurrentTypeIndex > 0)
      {
         EffectButton(sparam);
         UpdateCalculatedLot(); // Ensure Lot is recalculated before execution
         
         // Sécurité : Validation complète pour Ordres Pending
         double sl = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
         double risk = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));
         double price = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT));
         
         if(sl <= 0 || risk <= 0 || price <= 0)
         {
             // HandleTradeMessage("PRICE, STOP LOSS AND RISK REQUIRED!", g_ColorRed);
             return;
         }
      
         int opCmd = -1;
         if(CurrentTypeIndex == 1) opCmd = OP_BUYLIMIT;
         if(CurrentTypeIndex == 2) opCmd = OP_SELLLIMIT;
         if(CurrentTypeIndex == 3) opCmd = OP_BUYSTOP;
         if(CurrentTypeIndex == 4) opCmd = OP_SELLSTOP;
         
         if(opCmd != -1) ExecuteOrder(opCmd);
      }
   }
   
   // --- SYNCHRONISATION PANEL -> GRAPHIQUE (Édition Texte) ---
   if(id == CHARTEVENT_OBJECT_ENDEDIT)
   {
      // RESET PARTIAL BUTTONS IF CUSTOM TEXT ENTERED
      if(sparam == PREFIX + "Pos_Edit_Close")
      {
         double val = StringToDouble(ObjectGetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT));
         if(val > 0)
         {
             g_PosPartialMode = 0;
             UpdatePartialButtonsVisuals();
         }
         UpdatePositionsValues(); // Check Modify Status for Validate Button
      }
   
      // INSTANT SAVE RISK
       // REMOVED DEFAULT RISK HANDLERS
      
      if(sparam == PREFIX + "Set_Edit_OneRPercent")
      {
          double r = StringToDouble(ObjectGetString(0, PREFIX + "Set_Edit_OneRPercent", OBJPROP_TEXT));
          if(r > 0) 
          {
             g_OneRPercent = r;
             SaveConfigToFile();
             CreatePanel(); 
             if(g_PanelMain.IsVisible) UpdateUIMode();
             else ToggleMainPanel(false);
          }
      }
      
      if(StringFind(sparam, PREFIX + "Edit_") >= 0)
      {
         // Validation: Ne pas autoriser les cellules vides pour SL, TP et Risk
         string currentText = ObjectGetString(0, sparam, OBJPROP_TEXT);
         StringTrimLeft(currentText);
         StringTrimRight(currentText);
         
         if(currentText == "")
         {
             if(sparam == PREFIX + "Edit_SL" || sparam == PREFIX + "Edit_TP" || sparam == PREFIX + "Edit_Risk")
             {
                 ObjectSetString(0, sparam, OBJPROP_TEXT, "0");
             }
         }
         
         UpdateChartLines(); 
         AutoSwitchOrderType(); // Vérification logique après édition manuelle
         UpdateCalculatedLot(); // Recalcul si SL, TP, Entry ou Risk change
      }
      
      // --- UPDATE POSITION SL/TP (Old Auto Logic Removed) ---
      // We do nothing here now, waiting for Validate button.
      

      // --- HISTORY SYMBOL FILTER AUTO-UPDATE ---
      if(sparam == PREFIX + "Hist_Input_Symbol")
      {
          string sSym = ObjectGetString(0, PREFIX + "Hist_Input_Symbol", OBJPROP_TEXT);
          StringToUpper(sSym);
          StringTrimLeft(sSym);
          StringTrimRight(sSym);
          
          g_HistoryFilterSymbol = sSym;
          ObjectSetString(0, PREFIX + "Hist_Input_Symbol", OBJPROP_TEXT, g_HistoryFilterSymbol);
          
          UpdateHistoryFilter();
          CreateHistoryPanel();
      }

      // --- HISTORY CUSTOM DATE AUTO-UPDATE ---
      if(sparam == PREFIX + "Hist_Input_Start" || sparam == PREFIX + "Hist_Input_End")
      {
          string sStart = ObjectGetString(0, PREFIX + "Hist_Input_Start", OBJPROP_TEXT);
          string sEnd   = ObjectGetString(0, PREFIX + "Hist_Input_End", OBJPROP_TEXT);
          
          g_HistoryCustomStart = StringToTime(sStart);
          g_HistoryCustomEnd   = StringToTime(sEnd);
          
          UpdateHistoryFilter();
          CreateHistoryPanel(); // Redraw with new filter
      }
   }
   
   // --- SYNCHRONISATION GRAPHIQUE -> PANEL (Déplacement Lignes) ---
   if(id == CHARTEVENT_OBJECT_DRAG)
   {
      bool dragged = false;
      
      if(sparam == PREFIX + "Line_SL")
      {
         double price = ObjectGetDouble(0, sparam, OBJPROP_PRICE1);
         ObjectSetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT, DoubleToString(price, _Digits));
         dragged = true;
      }
      if(sparam == PREFIX + "Line_TP")
      {
         double price = ObjectGetDouble(0, sparam, OBJPROP_PRICE1);
         ObjectSetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT, DoubleToString(price, _Digits));
         dragged = true;
      }
      if(sparam == PREFIX + "Line_Price")
      {
         double price = ObjectGetDouble(0, sparam, OBJPROP_PRICE1);
         ObjectSetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT, DoubleToString(price, _Digits));
         dragged = true;
      }
      
      if(dragged)
      {
         AutoSwitchOrderType(); // Vérification logique après drag
         UpdateCalculatedLot();
      }
   }
   
   // --- GESTION DES RACCOURCIS CLAVIER ---
   if(id == CHARTEVENT_KEYDOWN)
   {
      bool changed = false;
      
      // Touche 7 (Buy / Market) - Code ASCII 55
      if(lparam == 55)
      {
         CurrentTypeIndex = 0;
         CurrentDirection = 0; // Buy
         changed = true;
      }
      
      // Touche 8 (Sell / Market) - Code ASCII 56
      if(lparam == 56)
      {
         CurrentTypeIndex = 0;
         CurrentDirection = 1; // Sell
         changed = true;
      }
      
      // Touche 9 (Toggle Mode) - Code ASCII 57
      if(lparam == 57)
      {
         if(CurrentDirection == 0) // Direction Buy
         {
            if(CurrentTypeIndex == 0)      CurrentTypeIndex = 1; // Market -> Buy Limit
            else if(CurrentTypeIndex == 1) CurrentTypeIndex = 3; // Buy Limit -> Buy Stop
            else                           CurrentTypeIndex = 0; // Buy Stop -> Market
         }
         else // Direction Sell
         {
            if(CurrentTypeIndex == 0)      CurrentTypeIndex = 2; // Market -> Sell Limit
            else if(CurrentTypeIndex == 2) CurrentTypeIndex = 4; // Sell Limit -> Sell Stop
            else                           CurrentTypeIndex = 0; // Sell Stop -> Market
         }
         changed = true;
      }
      
      if(changed)
      {
         UpdateUIMode();
         UpdateCalculatedLot(); // Recalcul des lots et mise à jour boutons
         ChartRedraw();
      }
   }
}
