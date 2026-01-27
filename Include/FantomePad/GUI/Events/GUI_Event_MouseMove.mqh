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
   
   // --- DETECT HOVER ON LIST (UI UPDATES) ---
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
