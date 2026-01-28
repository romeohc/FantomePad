//+------------------------------------------------------------------+
//|                                         Panel_Onboarding_UI.mqh |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _PANEL_ONBOARDING_UI_MQH_
#define _PANEL_ONBOARDING_UI_MQH_

#include "../Components/Components.mqh"

void CreateOnboardingUI()
{
   int chart_w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chart_h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   int w = g_PanelOnboarding.Width;
   int h = g_PanelOnboarding.Height;
   
   // Center position
   int x = (chart_w - w) / 2;
   int y = (chart_h - h) / 2;
   
   g_PanelOnboarding.X = x;
   g_PanelOnboarding.Y = y;

   string p = "Onboarding_";
   
   // Shadow/Outer Border
   CreateRect(p + "Shadow", x - 2, y - 2, w + 4, h + 4, C'10,10,10', BORDER_FLAT);
   
   // Main Background
   CreateRect(p + "Bg", x, y, w, h, g_ColorBg, BORDER_FLAT);
   
   // Accent Header Line (Mint Green)
   CreateRect(p + "Accent", x, y, w, 4, g_ColorGreen, BORDER_FLAT);
   
   // Welcome Title
   CreateLabel(p + "Title", "BIENVENUE SUR FANTOMEPAD", x + 40, y + 40, 16, g_ColorGreen, "Trebuchet MS");
   
   // Subtitle / Version
   CreateLabel(p + "Version", "Version 2.0 - The Trading OS", x + 40, y + 70, 9, clrGray);
   
   // Main Message
   string msg1 = "L'interface a été optimisée pour une clarté maximale.";
   string msg2 = "Votre graphique est maintenant prêt.";
   string msg3 = "Cliquez sur le bouton ci-dessous pour commencer.";
   
   CreateLabel(p + "Msg1", msg1, x + 40, y + 110, 10, g_ColorText);
   CreateLabel(p + "Msg2", msg2, x + 40, y + 130, 10, g_ColorText);
   CreateLabel(p + "Msg3", msg3, x + 40, y + 150, 10, g_ColorText);
   
   // Start Button
   CreateButton(p + "BtnStart", "DÉCOUVRIR L'INTERFACE", x + (w/2) - 100, y + h - 60, 200, 40, g_ColorGreen, clrWhite);
}

void ShowOnboarding(bool show)
{
   string p = "Onboarding_";
   g_PanelOnboarding.IsVisible = show;
   
   SetObjVisible(p + "Shadow", show);
   SetObjVisible(p + "Bg", show);
   SetObjVisible(p + "Accent", show);
   SetObjVisible(p + "Title", show);
   SetObjVisible(p + "Version", show);
   SetObjVisible(p + "Msg1", show);
   SetObjVisible(p + "Msg2", show);
   SetObjVisible(p + "Msg3", show);
   SetObjVisible(p + "BtnStart", show);
   
   ChartRedraw();
}

#endif
