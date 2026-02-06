//+------------------------------------------------------------------+
//|                                           Panel_Auth_UI.mqh      |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _PANEL_AUTH_UI_MQH_
#define _PANEL_AUTH_UI_MQH_

#include "../Components/Components.mqh"

void CreateAuthUI()
{
   int chart_w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chart_h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   int w = g_PanelAuth.Width;
   int h = g_PanelAuth.Height;
   
   // Center position
   int x = (chart_w - w) / 2;
   int y = (chart_h - h) / 2;
   
   g_PanelAuth.X = x;
   g_PanelAuth.Y = y;

   string p = "Auth_";
   
   // Shadow/Outer Border
   CreateRect(p + "Shadow", x - 2, y - 2, w + 4, h + 4, C'10,10,10', BORDER_FLAT);
   
   // Main Background
   CreateRect(p + "Bg", x, y, w, h, g_ColorBg, BORDER_FLAT);
   
   // Accent Header Line (Mint Green)
   CreateRect(p + "Accent", x, y, w, 4, g_ColorGreen, BORDER_FLAT);
   
   // Title
   CreateLabel(p + "Title", "FANTOMEPAD - ACTIVATION", x + 30, y + 30, 12, g_ColorGreen, "Trebuchet MS");
   
   // Subtitle
   CreateLabel(p + "Subtitle", "Veuillez entrer votre code de licence", x + 30, y + 55, 9, clrGray);
   
   // License Input Field (Edit)
   // We use the g_ActivationCode as the default text if it exists
   CreateEdit(p + "Input", g_ActivationCode, x + 30, y + 85, w - 60, 35);
   
   // Info / Error Message Label
   CreateLabel(p + "StatusMsg", "En attente d'activation...", x + 30, y + 130, 8, g_ColorText);
   
   // Activate Button
   CreateButton(p + "BtnActive", "ACTIVER LA LICENCE", x + 30, y + h - 55, w - 60, 40, g_ColorGreen, clrWhite);
}

void ShowAuthPanel(bool show)
{
   string p = "Auth_";
   g_PanelAuth.IsVisible = show;
   
   SetObjVisible(p + "Shadow", show);
   SetObjVisible(p + "Bg", show);
   SetObjVisible(p + "Accent", show);
   SetObjVisible(p + "Title", show);
   SetObjVisible(p + "Subtitle", show);
   SetObjVisible(p + "Input", show);
   SetObjVisible(p + "StatusMsg", show);
   SetObjVisible(p + "BtnActive", show);
   
   ChartRedraw();
}

void UpdateAuthStatus(string msg, color col)
{
   ObjectSetString(0, PREFIX + "Auth_StatusMsg", OBJPROP_TEXT, msg);
   ObjectSetInteger(0, PREFIX + "Auth_StatusMsg", OBJPROP_COLOR, col);
   ChartRedraw();
}

#endif
