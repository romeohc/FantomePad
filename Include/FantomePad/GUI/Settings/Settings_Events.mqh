//+------------------------------------------------------------------+
//|                                              Settings_Events.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

//+------------------------------------------------------------------+
//| EVENT MANAGER                                                    |
//+------------------------------------------------------------------+
bool PanelSettings_OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(!g_PanelSettings.IsVisible && !g_IsColorPickerOpen) return false;
   
   // 1. SCROLL & DRAG
   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int mouseX = (int)lparam;
      int mouseY = (int)dparam;
      int buttons = (int)sparam;
      
      if((buttons & 1) == 1) // Dragging
      {
          // --- SCROLLBAR ---
          // Priorité: Si on drag déjà ou si on démarre
          bool canScroll = g_PanelSettings.IsVisible && !IsScrollDragging && !g_PanelMain.IsDragging;
          
          if(canScroll) 
          { 
             // Start or Continue
             if(g_ScrollSettings.IsDragging || (mouseX > g_PanelSettings.X + 300)) // Simplistic check, HandleScrollDrag does precise
             {
                 int maxScroll = g_ScrollSettings.ContentHeight - g_ScrollSettings.ViewportHeight;
                 if(maxScroll < 0) maxScroll = 0;
                 if(HandleScrollDrag(g_ScrollSettings.IsDragging, g_ScrollSettings.DragAnchorY, g_ScrollSettings.ScrollY, mouseX, mouseY, "Set_ScrollThumb", g_ScrollSettings.ViewportHeight, maxScroll))
                 {
                     OpenSettings(); return true;
                 }
             }
          }
          
          // --- PANEL DRAG ---
          if(g_PanelSettings.IsVisible && !g_ScrollSettings.IsDragging && !g_PanelMain.IsDragging)
          {
              if(HandlePanelDrag(g_PanelSettings.IsDragging, g_PanelSettings.X, g_PanelSettings.Y, g_PanelSettings.DragOffsetX, g_PanelSettings.DragOffsetY, mouseX, mouseY, 340, 50 + g_ScrollSettings.ViewportHeight))
              {
                 OpenSettings(); return true;
              }
          }
      }
      else // Mouse Up
      {
           if(g_PanelSettings.IsDragging) {
                int h = 50 + g_ScrollSettings.ViewportHeight;
                ApplyPanelSafety(g_PanelSettings.X, g_PanelSettings.Y, 340, h); 
                g_PanelSettings.IsDragging = false;
                OpenSettings();
                SaveConfigToFile();
                return true;
           }
           if(g_ScrollSettings.IsDragging) {
               g_ScrollSettings.IsDragging = false;
               g_BlockClick = true; 
               return true;
           }
      }
   }
   
   // 2. CLICKS
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
       // Basic Settings Buttons
       if(sparam == PREFIX + "Set_Btn_MgrPos")
       {
           g_ManagerPosition++;
           if(g_ManagerPosition > 5) g_ManagerPosition = 0;
           ObjectSetString(0, PREFIX + "Set_Btn_MgrPos", OBJPROP_TEXT, ManagerPositions[g_ManagerPosition]);
           UpdateManagerPanel(); 
           EffectButton(sparam);
           return true; 
       }
       
       // Color Picker Open
       if(StringFind(sparam, PREFIX + "Set_Btn_Color_") >= 0)
       {
          g_ColorPickerTarget = sparam;
          CreateColorPicker();
          return true;
       }
       
       // Color Picker Internals
       if(g_IsColorPickerOpen)
       {
           if(sparam == PREFIX + "CP_Btn_Custom")
           {
               string hexStr = ObjectGetString(0, PREFIX + "CP_Edit_Custom", OBJPROP_TEXT);
               color pickedCol = HexStringToColor(hexStr); 
               
               // Add to palette
               bool exists = false;
               for(int i=0; i<ArraySize(g_ColorPalette); i++) { if(g_ColorPalette[i] == pickedCol) { exists = true; break; } }
               if(!exists) {
                   int size = ArraySize(g_ColorPalette);
                   ArrayResize(g_ColorPalette, size + 1);
                   g_ColorPalette[size] = pickedCol;
                   SaveConfigToFile(); // Save updated palette
                   CreateColorPicker(); ChartRedraw();
               }
               
               ApplyColorChange(pickedCol); 
               CloseColorPicker();
               return true;
           }
           
           if(StringFind(sparam, PREFIX + "CP_Item_") >= 0)
           {
               long pickedCol = ObjectGetInteger(0, sparam, OBJPROP_BGCOLOR);
               ApplyColorChange((color)pickedCol);
               CloseColorPicker();
               return true;
           }
           
           // Click Outside
           if(StringFind(sparam, PREFIX + "CP_") < 0)
           {
               CloseColorPicker();
               // Do NOT return true
           }
       }
   }
   
   // 3. EDIT EVENTS
   if(id == CHARTEVENT_OBJECT_ENDEDIT)
   {
       // Removed Default Risk Handlers
       
       if(sparam == PREFIX + "Set_Edit_OneRPercent") {
           double r = StringToDouble(ObjectGetString(0, PREFIX + "Set_Edit_OneRPercent", OBJPROP_TEXT));
           if(r > 0) { g_OneRPercent = r; SaveConfigToFile(); RefreshAllPanels(); }
           return true;
       }
   }
   
   return false;
}
