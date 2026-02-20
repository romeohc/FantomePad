//+------------------------------------------------------------------+
//|                                                  fantomepad.mq5  |
//|                                     Copyright 2026, FantomePad   |
//|                                          Designed for Aesthetics |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, FantomePad"
#property link      "https://fantomepad.com"
#property version   "1.00"

// NOTE: This file mirrors fantomepad.mq4 exactly.
// The Compatibility.mqh layer handles all platform differences.
// Both files share the same include chain and logic.
// If you modify fantomepad.mq4, apply the same changes here.

// Include the shared codebase (Compatibility.mqh handles MT4/MT5 differences)
#include "Include/FantomePad/Platform/Common/Core/Defines.mqh"
#include "Include/FantomePad/Platform/Common/Core/Config.mqh"
#include "Include/FantomePad/Platform/Bridge.mqh"
#include "Include/FantomePad/Platform/Common/GUI/GUI_Master.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // --- PRIORITY: ACCOUNT CHANGE DETECTION & AUTO-SWITCH ---
   // We check this at the very beginning to avoid running weightier logic/GUI on the "old" symbol.
   bool accountChanged = false;
   if(CheckAndSetNewAccount(accountChanged)) 
   {
      // If a symbol switch was triggered, we stop here. 
      // MT5 will automatically restart OnInit on the new symbol.
      return(INIT_SUCCEEDED); 
   }

   // --- CORE ENGINE INIT ---
   Bridge_InitEngine();

   // 1. Init Globals (Inputs -> Globals)
   InitGlobals();

   // 2. Load Config (File -> Globals override)
   LoadConfig();

   // --- GLOBAL STATE SAFETY ENFORCEMENT (SILENT CORRECTION) ---
   // Fix W3 & W1: One R Percent Safety
   if(g_OneRPercent <= 0) g_OneRPercent = 2.0; 
   
   // Fix W1: Max Risk Percent Safety (Cap at 100%, Floor at 0.1%)
   if(g_MaxRiskPercent <= 0) g_MaxRiskPercent = 2.0; 
   if(g_MaxRiskPercent > 100.0) g_MaxRiskPercent = 100.0;
   
   // Magic Number Check (Print only, no blocking return to avoid freeze)
   if(MagicNumber <= 0 && !IsTesting())
       Print("FantomePad Error: MagicNumber is invalid (<=0).");
   // -----------------------------------------------------------

   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   EventSetMillisecondTimer(200);

   // Chart Aesthetics
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, g_ColorChartBg);
   ChartSetInteger(0, CHART_COLOR_FOREGROUND, g_ColorChartFg);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, g_ColorCandleUp);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, g_ColorCandleDown);
   ChartSetInteger(0, CHART_COLOR_CHART_UP, g_ColorCandleUp);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, g_ColorCandleDown);
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   ChartSetInteger(0, CHART_SHOW_PERIOD_SEP, false);
   ChartSetInteger(0, CHART_SHOW_VOLUMES, false);
   ChartSetInteger(0, CHART_SHOW_OHLC, false);
   ChartSetInteger(0, CHART_SHOW_ONE_CLICK, false);
   ChartSetInteger(0, CHART_FOREGROUND, false);
   ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, false);
   ChartSetInteger(0, CHART_SHOW_BID_LINE, false);
   ChartSetInteger(0, CHART_SHOW_ASK_LINE, false);
   ChartSetInteger(0, CHART_AUTOSCROLL, false);

   // --- INSTANT AUTH BLACKOUT (MT5 FIX) ---
   HandleInitialLicenseCheck(); 
   if(!g_IsLicensed && g_LicenseState != LICENSE_REVOKED)
   {
      SyncChartUI(); 
   }

   // --- AUTO-SCROLL TO PRESENT ---
   // Par défaut on affiche toujours la fin du graphique (le présent) à chaque changement d'actif
   ChartNavigate(0, CHART_END, 0);

   ChartRedraw();

   GUI_OnInit();
   UpdateCalculatedLot();

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectsDeleteAll(0, PREFIX);
   ChartSetInteger(0, CHART_SHOW_PRICE_SCALE, true);
   ChartSetInteger(0, CHART_SHOW_DATE_SCALE, true);
   ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
   ChartSetInteger(0, CHART_KEYBOARD_CONTROL, true);
   Bridge_DeinitEngine();
}

void OnTick()
{
   if(!g_IsLicensed) { GUI_OnTick(); return; }
   UpdateOpenOrderLines();
   if(CurrentTypeIndex == 0) UpdateCalculatedLot();
   GUI_OnTick();
}

void OnTimer()
{
   GUI_OnTick();
   GUI_OnTimer();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   GUI_OnChartEvent(id, lparam, dparam, sparam);
}

//+------------------------------------------------------------------+
//| Helper: Check for Account Change & Auto-Select First Symbol      |
//+------------------------------------------------------------------+
bool CheckAndSetNewAccount(bool &accountChanged)
{
   accountChanged = false;
   if(IsTesting()) return false;
   
   long currentAccount = AccountNumber();
   if(currentAccount <= 0) return false;

   string gvName = "FantomePad_LastAccount";
   long lastAccount = 0;
   
   if(GlobalVariableCheck(gvName)) lastAccount = (long)GlobalVariableGet(gvName);
   
   if(currentAccount != lastAccount)
   {
      // Get the first symbol from the Market Watch (User's list)
      int total = SymbolsTotal(true); // true = only selected symbols
      if(total > 0)
      {
         string firstSymbol = SymbolName(0, true);
         
         // Only switch if we have a valid symbol and we are not already on it
         if(firstSymbol != "" && Symbol() != firstSymbol)
         {
            // We do NOT update the GV yet. The next OnInit (on the new symbol) 
            // will detect the account mismatch again and finalize the change.
            Print("FantomePad: Account Change Detected (", lastAccount, " -> ", currentAccount, "). Auto-switching to first symbol: ", firstSymbol);
            ChartSetSymbolPeriod(0, firstSymbol, Period());
            return true; // Urgent switch triggered, stop current execution!
         }
      }
      
      // If we reach here, we are either already on the correct symbol 
      // or there's no symbol to switch to. Finalize account change record.
      GlobalVariableSet(gvName, (double)currentAccount);
      accountChanged = true;
      return false; // No switch needed, continue normally
   }
   return false;
}
