//+------------------------------------------------------------------+
//|                                              GUI_Master.mqh      |
//|                                                MagicKey Project  |
//+------------------------------------------------------------------+
#property strict

// Includes
#include "Components.mqh"
#include "../Trade.mqh"       // Needs access to AutoSwitchOrderType
#include "Panel_Main.mqh"
#include "Panel_Settings.mqh"
#include "Panel_Info.mqh"
#include "Panel_Manager.mqh"
#include "Panel_Positions.mqh"

//+------------------------------------------------------------------+
//| INITIALISATION GUI GLOBALE                                       |
//+------------------------------------------------------------------+
void GUI_OnInit()
{
   CreatePanel();
   CreateInfoPanel();
   CreateManagerPanel(); 
   CreatePositionsPanel();
   UpdateUIMode(); 
}

//+------------------------------------------------------------------+
//| EVENT TICK (MISE A JOUR CONTINUE)                                |
//+------------------------------------------------------------------+
void GUI_OnTick()
{
   UpdateInfoPanel();
   UpdatePositionsValues();
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
      CreatePanel();
      CreateInfoPanel();
      CreateManagerPanel();
      CreatePositionsPanel();
      UpdateUIMode();
      if(IsSettingsOpen) OpenSettings(); // Redraw settings if open
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
         if(IsDragging || IsSettingsDragging || IsScrollDragging || IsSettingsScrollDragging || isOverList)
         {
             ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
         }
      
         // --- 0. DRAG SCROLLBAR (SYMBOL LIST) ---
         if(IsListOpen)
         {
             if(!IsScrollDragging && !IsDragging && !IsSettingsDragging && !IsSettingsScrollDragging)
             {
                 // Check start drag
                 long tx = ObjectGetInteger(0, PREFIX + "ScrollThumb", OBJPROP_XDISTANCE);
                 long ty = ObjectGetInteger(0, PREFIX + "ScrollThumb", OBJPROP_YDISTANCE);
                 long tw = ObjectGetInteger(0, PREFIX + "ScrollThumb", OBJPROP_XSIZE);
                 long th = ObjectGetInteger(0, PREFIX + "ScrollThumb", OBJPROP_YSIZE);
                 
                 // Expanded hit area for easier grabbing
                 if(mouseX >= tx - 5 && mouseX <= tx + tw + 5 && mouseY >= ty && mouseY <= ty + th)
                 {
                     IsScrollDragging = true;
                     ScrollDragY = mouseY;
                     ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
                 }
             }
             
             if(IsScrollDragging)
             {
                 int deltaY = mouseY - ScrollDragY;
                 if(deltaY != 0)
                 {
                     // Calculate movement ratio
                     long trackH = ObjectGetInteger(0, PREFIX + "ScrollTrack", OBJPROP_YSIZE);
                     long thumbH = ObjectGetInteger(0, PREFIX + "ScrollThumb", OBJPROP_YSIZE);
                     int availableTrack = (int)(trackH - thumbH);
                     
                     if(availableTrack > 0)
                     {
                         int total = SymbolsTotal(true);
                         int maxOffset = total - VisibleListItems; // Approx
                         if (maxOffset < 0) maxOffset = 0;
                         
                         double moveRatio = (double)deltaY / (double)availableTrack;
                         int offsetChange = (int)(moveRatio * maxOffset);
                         
                         if(MathAbs(offsetChange) >= 1)
                         {
                             g_SymbolListOffset += offsetChange;
                             ScrollDragY = mouseY; // Reset anchor
                             DrawSymbolList(); // This ensures clamps are applied
                         }
                     }
                 }
             }
         }
         
         // --- 0.5 DRAG SCROLLBAR (SETTINGS) ---
         if(IsSettingsOpen)
         {
             if(!IsSettingsScrollDragging && !IsDragging && !IsSettingsDragging && !IsScrollDragging)
             {
                  long tx = ObjectGetInteger(0, PREFIX + "Set_ScrollThumb", OBJPROP_XDISTANCE);
                  long ty = ObjectGetInteger(0, PREFIX + "Set_ScrollThumb", OBJPROP_YDISTANCE);
                  long tw = ObjectGetInteger(0, PREFIX + "Set_ScrollThumb", OBJPROP_XSIZE);
                  long th = ObjectGetInteger(0, PREFIX + "Set_ScrollThumb", OBJPROP_YSIZE);
                  
                  if(mouseX >= tx - 5 && mouseX <= tx + tw + 5 && mouseY >= ty && mouseY <= ty + th)
                  {
                      IsSettingsScrollDragging = true;
                      SettingsScrollDragY = mouseY;
                      ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
                  }
             }
             
             if(IsSettingsScrollDragging)
             {
                 int deltaY = mouseY - SettingsScrollDragY;
                 if(deltaY != 0)
                 {
                     long trackH = SettingsViewportHeight;
                     long thumbH = ObjectGetInteger(0, PREFIX + "Set_ScrollThumb", OBJPROP_YSIZE);
                     int availableTrack = (int)(trackH - thumbH);
                     
                     if(availableTrack > 0)
                     {
                         int maxScroll = SettingsContentHeight - SettingsViewportHeight;
                         if(maxScroll < 0) maxScroll = 0;
                         
                         double moveRatio = (double)deltaY / (double)availableTrack;
                         int offsetChange = (int)(moveRatio * maxScroll);
                         
                         if(MathAbs(offsetChange) >= 1)
                         {
                             g_SettingsScrollY += offsetChange;
                             if(g_SettingsScrollY < 0) g_SettingsScrollY = 0;
                             if(g_SettingsScrollY > maxScroll) g_SettingsScrollY = maxScroll;
                             
                             SettingsScrollDragY = mouseY;
                             OpenSettings();
                         }
                     }
                 }
             }
         }
      
         // --- 1. DRAG SETTINGS PANEL ---
         bool processedSettings = false;
         if(IsSettingsOpen && !IsDragging && !IsScrollDragging && !IsSettingsScrollDragging)
         {
            if(!IsSettingsDragging)
            {
               // Initialisation position si nécessaire (sécurité)
               if(SettingsX == -1)
               {
                  int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
                  int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
                  SettingsX = (chartW/2) - (300/2);
                  SettingsY = (chartH/2) - (350/2);
               }
               
               // Detection Settings Panel (Full Window)
               int settingsW = 340;
               int settingsH = 50 + SettingsViewportHeight;
               if(mouseX >= SettingsX && mouseX <= SettingsX + settingsW && mouseY >= SettingsY && mouseY <= SettingsY + settingsH)
               {
                  IsSettingsDragging = true;
                  SettingsDragOffsetX = mouseX - SettingsX;
                  SettingsDragOffsetY = mouseY - SettingsY;
                  ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
               }
            }
            
            if(IsSettingsDragging)
            {
               SettingsX = mouseX - SettingsDragOffsetX;
               SettingsY = mouseY - SettingsDragOffsetY;
               OpenSettings(); // Redessine le panel settings
               processedSettings = true;
            }
         }
         
         // --- 1.5 DRAG INFO PANEL ---
         bool processedInfo = false;
         if(!processedSettings && !IsSettingsDragging && !IsDragging && !IsScrollDragging)
         {
            if(!IsInfoDragging)
            {
               // Detection Info Panel
               int infoW = 200;
               long infoH = ObjectGetInteger(0, PREFIX + "Info_Bg", OBJPROP_YSIZE);
               if(infoH < 50) infoH = 150;
               
               if(mouseX >= InfoPanelX && mouseX <= InfoPanelX + infoW && mouseY >= InfoPanelY && mouseY <= InfoPanelY + infoH)
               {
                  IsInfoDragging = true;
                  InfoDragOffsetX = mouseX - InfoPanelX;
                  InfoDragOffsetY = mouseY - InfoPanelY;
                  ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
               }
            }
            
            if(IsInfoDragging)
            {
               InfoPanelX = mouseX - InfoDragOffsetX;
               InfoPanelY = mouseY - InfoDragOffsetY;
               UpdateInfoLayout();
               processedInfo = true;
            }
         }

         // --- 1.6 DRAG POSITIONS PANEL ---
         bool processedPos = false;
         if(!processedSettings && !IsSettingsDragging && !processedInfo && !IsInfoDragging && !IsDragging && !IsScrollDragging)
         {
            if(!IsPositionsDragging)
            {
               // Detection Positions Panel
               int posW = 280; // Matches CreatePositionsPanel
               long posH = ObjectGetInteger(0, PREFIX + "Pos_Bg", OBJPROP_YSIZE);
               if(posH < 50) posH = 150;
               
               if(mouseX >= PositionsPanelX && mouseX <= PositionsPanelX + posW && mouseY >= PositionsPanelY && mouseY <= PositionsPanelY + posH)
               {
                  IsPositionsDragging = true;
                  PositionsDragOffsetX = mouseX - PositionsPanelX;
                  PositionsDragOffsetY = mouseY - PositionsPanelY;
                  ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
               }
            }
            
            if(IsPositionsDragging)
            {
               PositionsPanelX = mouseX - PositionsDragOffsetX;
               PositionsPanelY = mouseY - PositionsDragOffsetY;
               UpdatePositionsLayout();
               processedPos = true;
            }
         }
         
         // --- 2. DRAG MAIN PANEL ---
         if(!processedSettings && !IsSettingsDragging && !processedInfo && !IsInfoDragging && !processedPos && !IsPositionsDragging && !IsScrollDragging && !IsSettingsScrollDragging)
         {
            if(!IsDragging)
            {
               // Calculer la position actuelle (soit fixée, soit centrée par défaut)
               int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
               int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
               int curX = (PanelX == -1) ? (chartW / 2) - (PanelWidth / 2) : PanelX;
               int curY = (PanelY == -1) ? (chartH / 2) - (200) : PanelY;
   
               // On récupère la hauteur dynamique du fond
               long bgH = ObjectGetInteger(0, PREFIX + "Bg", OBJPROP_YSIZE);
               if(bgH < 50) bgH = 200; // Fallback safety
               
               // On vérifie si on est sur le Panel pour commencer le drag (Header OU Body)
               if(mouseX >= curX && mouseX <= curX + PanelWidth && mouseY >= curY && mouseY <= curY + bgH)
               {
                  IsDragging = true;
                  PanelX = curX; // On fixe la position
                  PanelY = curY;
                  DragOffsetX = mouseX - PanelX;
                  DragOffsetY = mouseY - PanelY;
                  
                  // Bloquer le défilement du graphique pendant le drag
                  ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
               }
            }
            else
            {
               // On est en train de dragger
               PanelX = mouseX - DragOffsetX;
               PanelY = mouseY - DragOffsetY;
               UpdateUIMode();
            }
         }
      }
      else
      {
         // MOUSE UP
         if(IsDragging)
         {
            IsDragging = false;
         }
         if(IsSettingsDragging)
         {
            IsSettingsDragging = false;
         }
         if(IsInfoDragging)
         {
            IsInfoDragging = false;
         }
         if(IsPositionsDragging)
         {
            IsPositionsDragging = false;
         }
         if(IsScrollDragging)
         {
             IsScrollDragging = false;
             g_BlockClick = true; // Block subsequent click event from this release
         }
         if(IsSettingsScrollDragging)
         {
             IsSettingsScrollDragging = false;
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

      if(IsListOpen && !IsDragging && !IsSettingsDragging && !IsScrollDragging)
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
      if(IsInfoPanelVisible && !IsDragging && !IsSettingsDragging && !IsScrollDragging && !IsInfoDragging)
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
   
      // --- TOGGLE RISK MODE (% / CURRENCY) ---
      if(sparam == PREFIX + "Label_RiskPerc")
      {
         RiskMode++;
         if(RiskMode > 2) RiskMode = 0;
         
         // RESET to Default Value
         if(RiskMode == 1) // Currency
         {
            ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, DoubleToString(g_DefaultRiskMoney, 2));
         }
         else if(RiskMode == 2) // R
         {
             ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, DoubleToString(g_DefaultRiskR, 2));
         }
         else // %
         {
            ObjectSetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT, DoubleToString(g_DefaultRisk, 1));
         }
         
         UpdateUIMode();
         UpdateCalculatedLot();
         // Petit effet visuel
         EffectButton(sparam);
         return;
      }
      
      // --- SETTINGS ---

      
      // --- MANAGER PANEL EVENTS ---
      
      // 1. Toggle Trading Panel
      if(sparam == PREFIX + "Mgr_Btn_Main")
      {
         IsMainPanelVisible = !IsMainPanelVisible;
         ToggleMainPanel(IsMainPanelVisible);
         UpdateManagerPanel(); // Refresh button state (color)
         EffectButton(sparam);
         return;
      }
      
      // 2. Button Positions Panel (Toggle Positions)
      if(sparam == PREFIX + "Mgr_Btn_Pos")
      {
         IsPositionsPanelVisible = !IsPositionsPanelVisible;
         TogglePositionsPanel(IsPositionsPanelVisible);
         UpdateManagerPanel(); // Refresh button state
         EffectButton(sparam);
         return;
      }

      // 3. Toggle Info Panel
      if(sparam == PREFIX + "Mgr_Btn_Info")
      {
         IsInfoPanelVisible = !IsInfoPanelVisible;
         ToggleInfoPanel(IsInfoPanelVisible);
         UpdateManagerPanel(); // Refresh button state
         EffectButton(sparam);
         return;
      }
      
      // 3. Toggle Settings (Shortcut)
      if(sparam == PREFIX + "Mgr_Btn_Settings")
      {
         ToggleSettings();
         UpdateManagerPanel(); // Refresh button state
         EffectButton(sparam);
         return;
      }

      // --- CLICK ON ACTIVE ORDER (INFO PANEL) ---
      if(StringFind(sparam, PREFIX + "Info_Ord_") >= 0)
      {
          string symObj = sparam;
          // Normalise to Symbol Object to extract text
          // We look for _Bg_ or _Typ_ because the suffix comes with an underscore (e.g. _0)
          // and the prefix part ends with underscore (Ord_). 
          // Pattern is: ...Info_Ord_Bg_X
          
          if(StringFind(symObj, "_Bg_") > 0) StringReplace(symObj, "_Bg_", "_Sym_");
          else if(StringFind(symObj, "_Typ_") > 0) StringReplace(symObj, "_Typ_", "_Sym_");
          
          string symbol = ObjectGetString(0, symObj, OBJPROP_TEXT);
          
          // Switch Chart if different
          if(symbol != "" && symbol != Symbol())
          {
             ChartSetSymbolPeriod(0, symbol, Period());
             // Note: Changing symbol triggers EA reload
          }
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
       if(sparam == PREFIX + "CP_Btn_Custom")
       {
           string hexStr = ObjectGetString(0, PREFIX + "CP_Edit_Custom", OBJPROP_TEXT);
           color pickedCol = HexStringToColor(hexStr);
           
           if(g_ColorPickerTarget != "")
           {
              ObjectSetInteger(0, g_ColorPickerTarget, OBJPROP_BGCOLOR, pickedCol);
              ObjectSetInteger(0, g_ColorPickerTarget, OBJPROP_BORDER_COLOR, pickedCol);
              
              // --- INSTANT SAVE ---
              if(StringFind(g_ColorPickerTarget, "_Bg") > 0)          g_ColorBg = (color)pickedCol;
              if(StringFind(g_ColorPickerTarget, "_Head") > 0)        g_ColorHeader = (color)pickedCol;
              if(StringFind(g_ColorPickerTarget, "_Input") > 0)       g_ColorInput = (color)pickedCol;
              if(StringFind(g_ColorPickerTarget, "_Txt") > 0)         g_ColorText = (color)pickedCol;
              if(StringFind(g_ColorPickerTarget, "_Lbl") > 0)         g_ColorLabel = (color)pickedCol;
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
              CreatePanel();
              CreateInfoPanel();
              CreateManagerPanel(); // Refresh Manager Colors
              UpdateUIMode();
              OpenSettings();
            }
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
            if(StringFind(g_ColorPickerTarget, "_Lbl") > 0)         g_ColorLabel = (color)pickedCol;
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
            CreatePanel();  // Refresh Main Panel Colors
            CreateInfoPanel(); // Refresh Info Panel Colors
            CreateManagerPanel(); // Refresh Manager Colors
            UpdateUIMode(); // Refresh Layout
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
      if(sparam == PREFIX + "Pos_Btn_25") ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "25");
      if(sparam == PREFIX + "Pos_Btn_50") ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "50");
      if(sparam == PREFIX + "Pos_Btn_100") ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "100");
      
      // --- BE BUTTON LOGIC ---
      if(sparam == PREFIX + "Pos_Btn_BE")
      {
         g_PosBE_Active = !g_PosBE_Active;
         
         color bg = g_PosBE_Active ? g_ColorBtnValid : g_ColorInput;
         color txt = g_PosBE_Active ? clrWhite : g_ColorText;
         
         ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, bg);
         ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_COLOR, txt);
         
         EffectButton(sparam);
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
                 if(pct > 0)
                 {
                     double lots = OrderLots();
                     double toClose = lots * (pct / 100.0);
                     
                     // Normalize Lots
                     double step = MarketInfo(OrderSymbol(), MODE_LOTSTEP);
                     double min = MarketInfo(OrderSymbol(), MODE_MINLOT);
                     
                     // Round to step
                     toClose = MathFloor(toClose / step) * step;
                     
                     if(toClose < min) toClose = min; // At least close min
                     if(toClose > lots) toClose = lots; // Max all
                     
                     // If 100%, ensure close all despite rounding issues
                     if(pct >= 99.9) toClose = lots; 
                     
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
                        closed = OrderClose(SelectedPositionTicket, toClose, closePrice, 10, clrGray);
                     }
                     if(closed)
                     {
                         ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "0"); // Reset
                         if(toClose >= lots) 
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
                         Alert("Close Error: " + IntegerToString(GetLastError()));
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
                         bool res = OrderModify(SelectedPositionTicket, inputOpen, inputSL, inputTP, (datetime)0, clrBlue);
                         if(res)
                         {
                             g_LastPosSL = inputSL;
                             g_LastPosTP = inputTP;
                             g_LastPosEntry = inputOpen;
                             
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
                             Alert("Modify Error: " + IntegerToString(GetLastError()));
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
         // Sécurité : Vérifier si le SL et Risk sont définis
         double sl = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
         double risk = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));
         
         if(sl <= 0 || risk <= 0) 
         {
            Alert("STOP LOSS ET RISQUE REQUIS !");
            return;
         }
         
         ExecuteOrder(OP_BUY);
         EffectButton(sparam);
      }
      
      if(sparam == PREFIX + "Btn_Sell" && CurrentTypeIndex == 0)
      {
         // Sécurité : Vérifier si le SL et Risk sont définis
         double sl = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
         double risk = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));

         if(sl <= 0 || risk <= 0) 
         {
            Alert("STOP LOSS ET RISQUE REQUIS !");
            return;
         }

         ExecuteOrder(OP_SELL);
         EffectButton(sparam);
      }

      if(sparam == PREFIX + "Btn_Action" && CurrentTypeIndex > 0)
      {
         // Sécurité : Validation complète pour Ordres Pending
         double sl = StringToDouble(ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
         double risk = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Risk", OBJPROP_TEXT));
         double price = StringToDouble(ObjectGetString(0, PREFIX + "Edit_Price", OBJPROP_TEXT));
         
         if(sl <= 0 || risk <= 0 || price <= 0)
         {
             Alert("PRIX, STOP LOSS ET RISQUE REQUIS !");
             return;
         }
      
         int opCmd = -1;
         if(CurrentTypeIndex == 1) opCmd = OP_BUYLIMIT;
         if(CurrentTypeIndex == 2) opCmd = OP_SELLLIMIT;
         if(CurrentTypeIndex == 3) opCmd = OP_BUYSTOP;
         if(CurrentTypeIndex == 4) opCmd = OP_SELLSTOP;
         
         if(opCmd != -1) ExecuteOrder(opCmd);
         EffectButton(sparam);
      }
   }
   
   // --- SYNCHRONISATION PANEL -> GRAPHIQUE (Édition Texte) ---
   if(id == CHARTEVENT_OBJECT_ENDEDIT)
   {
      // INSTANT SAVE RISK
      if(sparam == PREFIX + "Set_Edit_Risk")
      {
          double r = StringToDouble(ObjectGetString(0, PREFIX + "Set_Edit_Risk", OBJPROP_TEXT));
          if(r > 0) 
          {
             g_DefaultRisk = r;
             SaveConfigToFile();
             // Si on est en mode %, on met à jour immédiatemment le panneau principal si on n'a pas modifié manuellement (optionnel, mais propre)
             // ici on redessine juste le panel par simplicité
             CreatePanel(); 
             UpdateUIMode();
          }
      }
      
      if(sparam == PREFIX + "Set_Edit_RiskMoney")
      {
          double r = StringToDouble(ObjectGetString(0, PREFIX + "Set_Edit_RiskMoney", OBJPROP_TEXT));
          if(r > 0) 
          {
             g_DefaultRiskMoney = r;
             SaveConfigToFile();
             CreatePanel(); 
             UpdateUIMode();
          }
      }
      
      if(sparam == PREFIX + "Set_Edit_RiskR")
      {
          double r = StringToDouble(ObjectGetString(0, PREFIX + "Set_Edit_RiskR", OBJPROP_TEXT));
          if(r > 0) 
          {
             g_DefaultRiskR = r;
             SaveConfigToFile();
             CreatePanel(); 
             UpdateUIMode();
          }
      }
      
      if(sparam == PREFIX + "Set_Edit_OneRPercent")
      {
          double r = StringToDouble(ObjectGetString(0, PREFIX + "Set_Edit_OneRPercent", OBJPROP_TEXT));
          if(r > 0) 
          {
             g_OneRPercent = r;
             SaveConfigToFile();
             CreatePanel(); 
             UpdateUIMode();
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
