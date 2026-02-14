//+------------------------------------------------------------------+
//|                                              Panel_Settings.mqh  |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

/*
   This file has been refactored to separate logic into smaller, manageable files.
   - Settings_UI.mqh: Helper functions for UI drawing (Scrollbar, ColorRows, etc.)
   - Settings_ColorPicker.mqh: Implementation of the Color Picker popup
   - Settings_View.mqh: Main Settings Panel layout and state (Open/Close/Toggle)
   - Settings_Events.mqh: Event handling for the Settings Panel
*/

#include "Settings_UI.mqh"
#include "Settings_ColorPicker.mqh"
#include "Settings_View.mqh"
#include "Settings_Events.mqh"
