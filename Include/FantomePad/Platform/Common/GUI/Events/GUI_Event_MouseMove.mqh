//+------------------------------------------------------------------+
//|                                          GUI_Event_MouseMove.mqh |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| EVENT: MOUSE MOVE                                                |
//+------------------------------------------------------------------+
void OnEvent_MouseMove(int mouseX, int mouseY, int buttons)
{
   // Update Globals
   LastMouseX = mouseX;
   LastMouseY = mouseY;
   
   // --- LOGIC: DRAG AND DROP ---
   if((buttons & 1) == 1) // Clic gauche enfoncé
   {
      ProcessDragLogic(mouseX, mouseY);
   }
   else
   {
      // MOUSE UP
      ProcessDragEnd();
   }
   
   bool needsRedraw = false;

   // --- DETECT HOVER ON LIST (UI UPDATES) ---
   if(IsListOpen && !g_PanelMain.IsDragging && !g_PanelSettings.IsDragging && !IsScrollDragging)
   {
      // On boucle uniquement sur les items visibles pour optimiser
      for(int i = 0; i < VisibleListItems; i++)
      {
         string btnName = PREFIX + "ListItem_" + IntegerToString(i);
         if(ObjectFind(0, btnName) < 0) continue;
         
         // Récupération des coordonnées de l'objet
         long x = ObjectGetInteger(0, btnName, OBJPROP_XDISTANCE);
         long y = ObjectGetInteger(0, btnName, OBJPROP_YDISTANCE);
         long w = ObjectGetInteger(0, btnName, OBJPROP_XSIZE);
         long h = ObjectGetInteger(0, btnName, OBJPROP_YSIZE);
         
         // Détection si la souris est dessus
         color targetColor = (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) ? g_ColorListHover : g_ColorInput;
         if((color)ObjectGetInteger(0, btnName, OBJPROP_BGCOLOR) != targetColor)
         {
            ObjectSetInteger(0, btnName, OBJPROP_BGCOLOR, targetColor);
            needsRedraw = true;
         }
      }
   }

   // --- HOVER ACTIVE ORDERS (ACCOUNT PANEL) ---
   if(g_PanelAccount.IsVisible && !g_PanelMain.IsDragging && !g_PanelSettings.IsDragging && !IsScrollDragging && !g_PanelAccount.IsDragging)
   {
       for(int i=0; i<g_LastAccountOrderCount; i++)
       {
          string cardName = PREFIX + "Account_Ord_Bg_" + IntegerToString(i);
          if(ObjectFind(0, cardName) < 0) continue;
          
          long x = ObjectGetInteger(0, cardName, OBJPROP_XDISTANCE);
          long y = ObjectGetInteger(0, cardName, OBJPROP_YDISTANCE);
          long w = ObjectGetInteger(0, cardName, OBJPROP_XSIZE);
          long h = ObjectGetInteger(0, cardName, OBJPROP_YSIZE);
          
          color targetColor = (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) ? g_ColorListHover : g_ColorInput;
          
          if((color)ObjectGetInteger(0, cardName, OBJPROP_BGCOLOR) != targetColor)
          {
             ObjectSetInteger(0, cardName, OBJPROP_BGCOLOR, targetColor);
             needsRedraw = true;
          }
       }
   }

   // --- HOVER POSITIONS LIST ---
   if(IsPosListOpen && !g_PanelMain.IsDragging && !g_PanelSettings.IsDragging && !IsScrollDragging)
   {
      for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
      {
         string name = ObjectName(0, i);
         if(StringFind(name, PREFIX + "PosListItem_") >= 0)
         {
            long x = ObjectGetInteger(0, name, OBJPROP_XDISTANCE);
            long y = ObjectGetInteger(0, name, OBJPROP_YDISTANCE);
            long w = ObjectGetInteger(0, name, OBJPROP_XSIZE);
            long h = ObjectGetInteger(0, name, OBJPROP_YSIZE);
            
            color targetColor = (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) ? g_ColorListHover : g_ColorInput;
            
            if((color)ObjectGetInteger(0, name, OBJPROP_BGCOLOR) != targetColor)
            {
               ObjectSetInteger(0, name, OBJPROP_BGCOLOR, targetColor);
               needsRedraw = true;
            }
         }
      }
   }

   // --- HOVER SYMBOL MANAGER ---
   if(g_PanelSymbolManager.IsVisible && !g_PanelMain.IsDragging && !g_PanelSettings.IsDragging && !IsScrollDragging && !g_PanelSymbolManager.IsDragging)
   {
      // 1. Categories
      for(int i=0; i<g_SymMgr_CategoryCount; i++)
      {
         string name = PREFIX + "SYM_Cat_" + IntegerToString(i);
         if(ObjectFind(0, name) < 0) continue;
         
         long x = ObjectGetInteger(0, name, OBJPROP_XDISTANCE);
         long y = ObjectGetInteger(0, name, OBJPROP_YDISTANCE);
         long w = ObjectGetInteger(0, name, OBJPROP_XSIZE);
         long h = ObjectGetInteger(0, name, OBJPROP_YSIZE);
         
         color normalColor = (g_SymMgr_Categories[i] == g_SymMgr_CurrentCategory) ? g_ColorBtnActive : g_ColorBg;
         color targetColor = (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h && g_SymMgr_Categories[i] != g_SymMgr_CurrentCategory) ? g_ColorListHover : normalColor;
         
         if((color)ObjectGetInteger(0, name, OBJPROP_BGCOLOR) != targetColor)
         {
            ObjectSetInteger(0, name, OBJPROP_BGCOLOR, targetColor);
            needsRedraw = true;
         }
      }
      
      // 2. Symbols
      for(int i=0; i<g_SymMgr_MaxVisible; i++)
      {
         string name = PREFIX + "SYM_Sym_" + IntegerToString(i);
         if(ObjectFind(0, name) < 0) continue;
         
         int dataIdx = g_SymMgr_ScrollOffset + i;
         if(dataIdx >= g_SymMgr_SymbolCount) break;
         
         long x = ObjectGetInteger(0, name, OBJPROP_XDISTANCE);
         long y = ObjectGetInteger(0, name, OBJPROP_YDISTANCE);
         long w = ObjectGetInteger(0, name, OBJPROP_XSIZE);
         long h = ObjectGetInteger(0, name, OBJPROP_YSIZE);
         
         string sym = g_SymMgr_SymbolsInCat[dataIdx];
         bool isInMarket = (bool)SymbolInfoInteger(sym, SYMBOL_SELECT);
         color normalColor = isInMarket ? g_ColorBtnActive : g_ColorBg;
         color targetColor = (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h && !isInMarket) ? g_ColorListHover : normalColor;
         
         if((color)ObjectGetInteger(0, name, OBJPROP_BGCOLOR) != targetColor)
         {
            ObjectSetInteger(0, name, OBJPROP_BGCOLOR, targetColor);
            needsRedraw = true;
         }
      }
   }

   if(needsRedraw) ChartRedraw();
}
