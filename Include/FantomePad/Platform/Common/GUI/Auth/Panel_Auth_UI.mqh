//+------------------------------------------------------------------+
//|                                           Panel_Auth_UI.mqh      |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _PANEL_AUTH_UI_MQH_
#define _PANEL_AUTH_UI_MQH_

#include "../Components/Components.mqh"

// --- BRANDING COLORS ---
#define COLOR_BRAND_BG      C'18,18,18'   // #121212
#define COLOR_BRAND_WHITE   C'255,255,255'// #FFFFFF
#define COLOR_BRAND_GRAY    C'120,120,120'// Subtle Gray
#define COLOR_BRAND_BORDER  C'35,35,35'   // Very subtle separation

void CreateAuthUI()
{
   int chart_w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chart_h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   // Professional Background Overlay
   CreateRect("Auth_Overlay", 0, 0, 5000, 5000, COLOR_BRAND_BG, BORDER_FLAT);
   FP_ObjectSetInteger(0, PREFIX + "Auth_Overlay", OBJPROP_ZORDER, 0);
   
   // Window size (Increased height slightly for the new spacing)
   g_PanelAuth.Width = 450;
   g_PanelAuth.Height = 350; 
   
   int w = g_PanelAuth.Width;
   int h = g_PanelAuth.Height;
   int x = (chart_w - w) / 2;
   int y = (chart_h - h) / 2;
   int centerX = x + (w / 2);
   
   g_PanelAuth.X = x;
   g_PanelAuth.Y = y;

   string p = "Auth_";
   
   // 1. Main Container
   CreateRect(p + "Bg", x, y, w, h, COLOR_BRAND_BG, BORDER_FLAT);
   FP_ObjectSetInteger(0, PREFIX + p + "Bg", OBJPROP_COLOR, COLOR_BRAND_BORDER); 
   
   // 2. Minimalist White Top Accent
   CreateRect(p + "Accent", x, y, w, 2, COLOR_BRAND_WHITE, BORDER_FLAT);
   
   // 3. BRANDING
   // "WELCOME TO FANTOMEPAD" REMOVED AS REQUESTED
   
   CreateLabel(p + "Title", "The new standard is here.", centerX, y + 60, 20, COLOR_BRAND_WHITE, "Trebuchet MS Bold");
   FP_ObjectSetInteger(0, PREFIX + p + "Title", OBJPROP_ANCHOR, ANCHOR_CENTER);
   
   // 4. ACTIVATION SECTION
   CreateLabel(p + "Notes", "Code d'Activation", centerX, y + 130, 8, COLOR_BRAND_GRAY, "Arial Bold");
   FP_ObjectSetInteger(0, PREFIX + p + "Notes", OBJPROP_ANCHOR, ANCHOR_CENTER);
   
   CreateEdit(p + "Input", "", x + 75, y + 147, w - 150, 35);
   FP_ObjectSetString(0, PREFIX + p + "Input", OBJPROP_TEXT, ""); // FORCE EMPTY
   FP_ObjectSetInteger(0, PREFIX + p + "Input", OBJPROP_BGCOLOR, C'28,28,28'); 
   FP_ObjectSetInteger(0, PREFIX + p + "Input", OBJPROP_BORDER_COLOR, COLOR_BRAND_BORDER);
   FP_ObjectSetInteger(0, PREFIX + p + "Input", OBJPROP_COLOR, COLOR_BRAND_WHITE);
   
   // 5. ACTION BUTTON
   CreateButton(p + "BtnActive", "ACTIVER FANTOMEPAD", x + 75, y + 210, w - 150, 45, COLOR_BRAND_WHITE, clrBlack);
   FP_ObjectSetString(0, PREFIX + p + "BtnActive", OBJPROP_FONT, "Segoe UI Bold");
   FP_ObjectSetInteger(0, PREFIX + p + "BtnActive", OBJPROP_FONTSIZE, 10);
   
   // 6. ERROR/STATUS AREA (No initial creation to avoid ghost labels)
   
   // 7. FOOTER (Moved up slightly to reduce gap from button)
   CreateLabel(p + "Help", "Besoin d'aide ? contact@fantomepad.com", centerX, y + 315, 9, COLOR_BRAND_GRAY, "Arial");
   FP_ObjectSetInteger(0, PREFIX + p + "Help", OBJPROP_ANCHOR, ANCHOR_CENTER);
}

void ShowAuthPanel(bool show)
{
   string p = "Auth_";
   g_PanelAuth.IsVisible = show;
   
   SetObjVisible(p + "Overlay", show);
   SetObjVisible(p + "Bg", show);
   SetObjVisible(p + "Accent", show);
   SetObjVisible(p + "Brand", show);
   SetObjVisible(p + "Title", show);
   SetObjVisible(p + "Notes", show);
   SetObjVisible(p + "Input", show);
   SetObjVisible(p + "BtnActive", show);
   SetObjVisible(p + "Help", show);
   
   for(int i=0; i<3; i++)
   {
      if(ObjectFind(0, PREFIX + p + "StatusMsg_" + IntegerToString(i)) >= 0)
         SetObjVisible(p + "StatusMsg_" + IntegerToString(i), show);
   }
   
   ChartRedraw();
}

void UpdateAuthStatus(string msg, color col)
{
   string p = "Auth_";
   int centerX = g_PanelAuth.X + (g_PanelAuth.Width / 2);
   for(int i=0; i<3; i++) ObjectDelete(0, PREFIX + p + "StatusMsg_" + IntegerToString(i));
   
   string parts[];
   int count = 0;
   string temp = msg;
   while(StringFind(temp, "|") >= 0)
   {
      int pos = StringFind(temp, "|");
      ArrayResize(parts, count + 1);
      parts[count] = StringSubstr(temp, 0, pos);
      temp = StringSubstr(temp, pos + 1);
      count++;
   }
   ArrayResize(parts, count + 1);
   parts[count] = temp;
   count++;
   
   // Center error messages BELOW the button at y + 270
   int startY = g_PanelAuth.Y + 270;
   for(int i=0; i<count && i<3; i++)
   {
      string name = p + "StatusMsg_" + IntegerToString(i);
      CreateLabel(name, parts[i], centerX, startY + (i * 18), 9, col, "Arial");
      FP_ObjectSetInteger(0, PREFIX + name, OBJPROP_ANCHOR, ANCHOR_CENTER);
   }
   
   ChartRedraw();
}

#endif
