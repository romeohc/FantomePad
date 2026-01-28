//+------------------------------------------------------------------+
//|                                        GUI_Event_ObjectClick.mqh |
//+------------------------------------------------------------------+
#property strict

// Includes specialized event handlers
#include "Handlers/Handler_Validation.mqh"
#include "Handlers/Handler_Settings.mqh"
#include "Handlers/Handler_Navigation.mqh"
#include "Handlers/Handler_History.mqh"
#include "Handlers/Handler_SymbolList.mqh"
#include "Handlers/Handler_ColorPicker.mqh"
#include "Handlers/Handler_PositionList.mqh"
#include "Handlers/Handler_PositionActions.mqh"
#include "Handlers/Handler_Trading.mqh"

//+------------------------------------------------------------------+
//| EVENT: OBJECT CLICK                                              |
//+------------------------------------------------------------------+
void OnEvent_ObjectClick(string sparam)
{
    LastClickTime = GetTickCount(); // Enregistrer l'heure du clic sur un objet
    
    // --- SAFETY BLOCK AFTER DRAG ---
    if(g_BlockClick || IsScrollDragging)
    {
        g_BlockClick = false;
        ObjectSetInteger(0, sparam, OBJPROP_STATE, false); // Reset visual state
        ChartRedraw();
        return;
    }

    // 0. Onboarding logic
    if(sparam == PREFIX + "Onboarding_BtnStart")
    {
        OnClick_OnboardingStart();
        return;
    }
    
    // 1. Validation Logic (Errors)
    if(Handle_Validation_Events(sparam)) return;
    
    // 2. Settings Logic (Risk Mode, Toggles)
    if(Handle_Settings_Events(sparam)) return;
    
    // 3. Navigation Panel Logic (Open/Close Panels, Account Click)
    if(Handle_Navigation_Events(sparam)) return;

    // 4. History Logic (Filters)
    if(Handle_History_Events(sparam)) return;

    // 5. Symbol List Logic
    // Note: Called before Color Picker to preserve original precedence where Symbol Click returns early
    if(Handle_SymbolList_Events(sparam)) return;

    // 6. Color Picker Logic (Events + Outside Check)
    if(Handle_ColorPicker_Events(sparam)) return;

    // 7. Position List Logic (Selection)
    if(Handle_PositionList_Events(sparam)) return;

    // 8. Position Actions (Close, Modif, BE, Valid)
    if(Handle_PositionActions_Events(sparam)) return;

    // 9. Trading Actions (Buy/Sell, Type Cycle)
    if(Handle_Trading_Events(sparam)) return;
}
