//+------------------------------------------------------------------+
//|                                                  Settings_UI.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

// Helper to manage visibility based on scroll
bool IsItemVisible(int relY, int h)
{
   // Visible window relative to content start (0)
   int viewTop = g_ScrollSettings.ScrollY;
   int viewBottom = g_ScrollSettings.ScrollY + g_ScrollSettings.ViewportHeight;
   
   // Item range
   int itemTop = relY;
   int itemBottom = relY + h;
   
   // STRICT CHECK to avoid overflow bugs (Header/Footer bleeding)
   // We hide the item if it's not FULLY within the viewport
   if(itemTop < viewTop) return false; 
   if(itemBottom > viewBottom) return false;
   
   return true;
}

// Forward declarations helpers
void CreateColorRow(string suffix, string label, int x, int y, color col, bool visible)
{
   string lblName = "Set_Lbl_" + suffix;
   string btnName = "Set_Btn_Color_" + suffix;
   
   if(visible)
   {
      CreateLabel(lblName, label, x, y + 4, 8, g_ColorText, "Trebuchet MS");
      ObjectSetInteger(0, PREFIX + lblName, OBJPROP_ZORDER, 102);
      SetObjVisible(lblName, true);
      
      // Box at relative right of column (approx 130px width per col)
      int boxX = x + 110; 
      CreateButton(btnName, "", boxX, y, 25, 25, col, clrNONE);
      ObjectSetInteger(0, PREFIX + btnName, OBJPROP_ZORDER, 102);
      ObjectSetInteger(0, PREFIX + btnName, OBJPROP_BORDER_COLOR, C'100,100,100');
      SetObjVisible(btnName, true);
   }
   else
   {
      // Hide if exists, or don't create
      if(ObjectFind(0, PREFIX + lblName) >= 0) SetObjVisible(lblName, false);
      if(ObjectFind(0, PREFIX + btnName) >= 0) SetObjVisible(btnName, false);
   }
}

void DrawSettingsScrollbar(int x, int y)
{
   int scrollBarWidth = 10;
   int trackX = x + 340 - scrollBarWidth - 2; // Right aligned with slight padding
   int trackY = y + 50;
   int trackH = g_ScrollSettings.ViewportHeight;
   
   // 1. Track
   CreateRect("Set_ScrollTrack", trackX, trackY, scrollBarWidth, trackH, g_ColorBg, BORDER_FLAT);
   ObjectSetInteger(0, PREFIX + "Set_ScrollTrack", OBJPROP_ZORDER, 115);
   ObjectSetInteger(0, PREFIX + "Set_ScrollTrack", OBJPROP_BORDER_COLOR, g_ColorBg);
   
   // 2. Thumb
   // Calculate Height Ratio
   // If ContentHeight <= Viewport, Thumb = Track
   int contentH = MathMax(g_ScrollSettings.ContentHeight, 1);
   double ratio = (double)g_ScrollSettings.ViewportHeight / (double)contentH;
   if(ratio > 1.0) ratio = 1.0;
   
   int thumbH = (int)(trackH * ratio);
   if(thumbH < 30) thumbH = 30; // Min size
   
   // Position
   // ScrollY goes from 0 to (ContentH - ViewportH)
   // ThumbY goes from 0 to (TrackH - ThumbH)
   int maxScroll = contentH - g_ScrollSettings.ViewportHeight;
   if(maxScroll <= 0) maxScroll = 1;
   
   int maxThumb = trackH - thumbH;
   
   double p = (double)g_ScrollSettings.ScrollY / (double)maxScroll;
   if(p < 0) p = 0; 
   if(p > 1) p = 1;
   
   int thumbY = trackY + (int)(p * maxThumb);
   
   CreateButton("Set_ScrollThumb", "", trackX + 1, thumbY, scrollBarWidth - 2, thumbH, g_ColorText, clrNONE);
   ObjectSetInteger(0, PREFIX + "Set_ScrollThumb", OBJPROP_ZORDER, 116);
   ObjectSetInteger(0, PREFIX + "Set_ScrollThumb", OBJPROP_BORDER_COLOR, g_ColorText); 
}
