//+------------------------------------------------------------------+
//|                                           Panel_Onboarding.mqh   |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _PANEL_ONBOARDING_MQH_
#define _PANEL_ONBOARDING_MQH_

#include "Panel_Onboarding_UI.mqh"
#include "../../Core/Config.mqh"

// Forward declaration of RefreshAllPanels to avoid circular dependency
void RefreshAllPanels();

void OnClick_OnboardingStart()
{
   // 1. Hide Onboarding
   ShowOnboarding(false);
   g_IsFirstRun = false;
   
   // 2. Objects delete the onboarding specific ones explicitly to be clean
   ObjectsDeleteAll(0, PREFIX + "Onboarding_");
   
   // 3. UI Positioning for First Run
   int chart_w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chart_h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

   // Trade Panel (Main) -> Centered
   g_PanelMain.Width = 280; 
   g_PanelMain.X = (chart_w - g_PanelMain.Width) / 2;
   g_PanelMain.Y = (chart_h / 2) - 200; // Shifted slightly up from center for aesthetics
   g_PanelMain.IsVisible = true;

   // Account Panel -> Top Right
   int accWidth = 260; 
   g_PanelAccount.X = chart_w - accWidth - 30; // 30px margin from right
   g_PanelAccount.Y = 80; // Below navigation if at top
   g_PanelAccount.IsVisible = true;

   // Global Controls
   g_PanelNavigation.IsVisible = true;
   g_PanelPositions.IsVisible = false;
   g_PanelHistory.IsVisible = false;
   
   // 4. Save config so it doesn't show again and remembers coordinates
   SaveConfigToFile();
   
   // 5. Trigger full UI render (will use the new coordinates above)
   RefreshAllPanels();
   
   ChartRedraw();
}

#endif
