//+------------------------------------------------------------------+
//|                                         Panel_Main_Shared.mqh    |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#ifndef _PANEL_MAIN_SHARED_MQH_
#define _PANEL_MAIN_SHARED_MQH_
#property strict

// --- FORWARD DECLARATIONS WRAPPER ---
// Using a class prevents "no #import declaration" warnings in MQL4 strict mode
class CPanel_Main
{
public:
   // From Logic
   static void AutoSwitchOrderType();
   static void ApplyDefaultTradeValues();
   static void GetVisibleChartPriceRange(double &minP, double &maxP);
   
   // From Layout
   static void UpdateUIMode();
   static void ToggleMainPanel(bool visible);
   
   // From Create
   static void CreatePanel();
   
   // From Error
   static void ShowValidationError(string msg);
   static void HideValidationError();
   
   // From Events
   static bool PanelMain_OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
};

// --- MULTI-FILE REDIRECTS ---
// This trick maps global calls to the static class methods, 
// resolving both the circular dependency and the "no #import" warning.
#define AutoSwitchOrderType        CPanel_Main::AutoSwitchOrderType
#define ApplyDefaultTradeValues    CPanel_Main::ApplyDefaultTradeValues
#define GetVisibleChartPriceRange  CPanel_Main::GetVisibleChartPriceRange
#define UpdateUIMode               CPanel_Main::UpdateUIMode
#define ToggleMainPanel            CPanel_Main::ToggleMainPanel
#define CreatePanel                CPanel_Main::CreatePanel
#define ShowValidationError        CPanel_Main::ShowValidationError
#define HideValidationError        CPanel_Main::HideValidationError
#define PanelMain_OnEvent          CPanel_Main::PanelMain_OnEvent


#endif

