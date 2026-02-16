#ifndef _INIT_MQH_
#define _INIT_MQH_
#property strict

#include "Globals.mqh"

// --- INITIALIZATION HELPER ---
void InitGlobals()
{
   // Init State Structs
   g_PanelAuth.Width = 320;
   g_PanelAuth.Height = 220;
   g_PanelAuth.IsVisible = false;
   g_PanelMain.Width = 280; // Default
   g_PanelMain.IsVisible = true;
   g_PanelMain.X = -1;
   g_PanelMain.Y = -1;
   
   g_PanelAccount.IsVisible = true;
   g_PanelAccount.X = 20;
   g_PanelAccount.Y = 70;
   
   g_PanelPositions.IsVisible = false;
   g_PanelPositions.X = 260; // Default
   g_PanelPositions.Y = 70;
   
   g_PanelHistory.IsVisible = false;
   g_PanelHistory.X = 50;
   g_PanelHistory.Y = 100;
   
   g_PanelSettings.IsVisible = false;
   g_PanelSettings.X = -1;
   g_PanelSettings.Y = -1;
   
   g_PanelNavigation.IsVisible = false;
   
   g_PanelSymbolManager.Width = 600;
   g_PanelSymbolManager.Height = 400;
   g_PanelSymbolManager.IsVisible = false;
   g_PanelSymbolManager.X = -1; // Center dynamically
   g_PanelSymbolManager.Y = -1;
   
   g_ScrollSettings.ViewportHeight = 400;
   g_ScrollSettings.ContentHeight = 620; 
   g_ScrollHistory.ViewportHeight = 400;
   g_ScrollHistory.ContentHeight = 0;
   g_ScrollSymbolManager.ViewportHeight = 0; // Set dynamically in drawing
   g_ScrollSymbolManager.ContentHeight = 0;

   // Default Risk Init removed
   g_OneRPercent = OneRPercent;
   g_MaxRiskPercent = MaxRiskPercent;
   g_NavigationPosition = DefaultNavigationPosition;
   g_ColorBg     = ColorBg;
   g_ColorHeader = ColorHeader;
   g_ColorInput  = ColorInput;
   g_ColorText   = ColorText;
   // g_ColorLabel removed
   g_ColorGreen  = ColorGreen;
   g_ColorRed    = ColorRed;
   g_ColorBtnValid = ColorBtnValid;
   g_ColorBtnInvalid = ColorBtnInvalid;
   g_ColorBtnActive  = ColorBtnActive;
   g_ColorChartBg= ColorChartBg;
   g_ColorChartFg = ColorChartFg;
   g_ColorEntryLine = ColorEntryLine;
   g_ColorSLLine = ColorSLLine;
   g_ColorTPLine = ColorTPLine;
   g_ColorCandleUp = ColorCandleUp;
   g_ColorCandleDown = ColorCandleDown;
   g_ColorListNormal = ColorListNormal;
   g_ColorListHover = ColorListHover;
   
   // Init Dynamic Indicators Defaults
   g_ColorPositive = g_ColorGreen; 
   g_ColorNegative = g_ColorRed;
   
   g_ShowOrderLines = true; // Default to ON
   g_ShowPositionLines = true; // Default to ON
   g_MaxSpread = MaxSpread;

   // Init default custom dates (last 7 days by default)
   g_HistoryCustomStart = TimeCurrent() - 7 * 24 * 3600;
   g_HistoryCustomEnd = TimeCurrent() + 24 * 3600;
   
   // Init Color Palette
   color Defaults[] = {
      // Darks
      C'21,23,28', C'34,38,46', C'45,52,60', clrDimGray, clrBlack,
      // Lights
      clrWhite, clrWhiteSmoke, clrSilver, clrLightGray, clrAliceBlue,
      // Greens
      C'0,184,148', clrSeaGreen, clrMediumSeaGreen, clrLimeGreen, clrSpringGreen,
      // Reds
      C'214,48,49', clrCrimson, clrFireBrick, clrRed, clrTomato,
      // Blues
      C'0,90,180', clrRoyalBlue, clrDodgerBlue, clrCornflowerBlue, clrDeepSkyBlue,
      // Extra
      clrGold, clrOrange, clrOrchid, clrMagenta, clrSlateBlue
   };
   ArrayResize(g_ColorPalette, ArraySize(Defaults));
   for(int i=0; i<ArraySize(Defaults); i++) g_ColorPalette[i] = Defaults[i];
}

#endif
