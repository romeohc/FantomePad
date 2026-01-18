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

//+------------------------------------------------------------------+
//| INITIALISATION GUI GLOBALE                                       |
//+------------------------------------------------------------------+
void GUI_OnInit()
{
   CreatePanel();
   UpdateUIMode(); 
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
      UpdateUIMode();
      if(IsSettingsOpen) OpenSettings(); // Redraw settings if open
   }
   
   // --- GESTION DU HOVER ET DRAG ---
   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int mouseX = (int)lparam;
      int mouseY = (int)dparam;
      int buttons = (int)sparam;
      
      // LOGIQUE DE DRAG AND DROP
      if((buttons & 1) == 1) // Clic gauche enfoncé
      {
         // --- 1. DRAG SETTINGS PANEL ---
         bool processedSettings = false;
         if(IsSettingsOpen && !IsDragging)
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
               
               // Detection Header Settings (Taille approx 300x40)
               if(mouseX >= SettingsX && mouseX <= SettingsX + 300 && mouseY >= SettingsY && mouseY <= SettingsY + 40)
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
         
         // --- 2. DRAG MAIN PANEL ---
         if(!processedSettings && !IsSettingsDragging)
         {
            if(!IsDragging)
            {
               // Calculer la position actuelle (soit fixée, soit centrée par défaut)
               int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
               int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
               int curX = (PanelX == -1) ? (chartW / 2) - (PanelWidth / 2) : PanelX;
               int curY = (PanelY == -1) ? (chartH / 2) - (200) : PanelY;
   
               // On vérifie si on est sur le Header pour commencer le drag
               if(mouseX >= curX && mouseX <= curX + PanelWidth && mouseY >= curY && mouseY <= curY + 40)
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
         if(IsDragging)
         {
            IsDragging = false;
            ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
         }
         if(IsSettingsDragging)
         {
            IsSettingsDragging = false;
            ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
         }
      }

      if(IsListOpen && !IsDragging)
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
   }

   // Gestion des clics boutons
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      // --- SETTINGS ---
      if(sparam == PREFIX + "Btn_Settings")
      {
         ToggleSettings();
         EffectButton(sparam);
         return;
      }
      
      if(sparam == PREFIX + "Set_Btn_Close")
      {
         CloseSettings();
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
            UpdateUIMode(); // Refresh Layout
            OpenSettings(); // Refresh Settings (incl. bg)
         }
         CloseColorPicker();
         return;
      }
      
      // 1. Clic sur le bouton principal de l'actif
      if(sparam == PREFIX + "Btn_SymbolSelect")
      {
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
      if(IsListOpen && StringFind(sparam, PREFIX + "ListItem_") < 0 && sparam != PREFIX + "Btn_SymbolSelect")
      {
         CloseSymbolList();
      }

      // --- FIN GESTION SÉLECTEUR ---

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
             CreatePanel(); // Logic to propagate if needed
             UpdateUIMode();
          }
      }
      
      if(StringFind(sparam, PREFIX + "Edit_") >= 0)
      {
         UpdateChartLines(); 
         AutoSwitchOrderType(); // Vérification logique après édition manuelle
         UpdateCalculatedLot(); // Recalcul si SL, TP, Entry ou Risk change
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
