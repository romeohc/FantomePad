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
   Bridge_InitEngine();

   // Input Validation
   if(MaxSlippage < 0) Alert("FantomePad Error: MaxSlippage cannot be negative. Using default (10).");
   if(OneRPercent <= 0) Alert("FantomePad Error: OneRPercent must be greater than 0.");
   if(MaxRiskPercent > 100.0 || MaxRiskPercent <= 0) Alert("FantomePad Error: MaxRiskPercent must be between 0.1 and 100.");
   if(MagicNumber <= 0) { Alert("FantomePad Error: MagicNumber must be a positive integer."); return INIT_PARAMETERS_INCORRECT; }
   if(MagicNumber == 123456 || MagicNumber == 11111 || MagicNumber == 123)
      Print("FantomePad Warning: Common MagicNumber (" + IntegerToString(MagicNumber) + "). Ensure uniqueness.");

   InitGlobals();
   LoadConfig();

   bool accountChanged = CheckAndSetNewAccount();
   if(accountChanged && !TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
      Print("FantomePad Info: AutoTrading disabled by MT security setting.");

   if(g_MaxRiskPercent <= 0) g_MaxRiskPercent = 2.0;
   if(g_MaxRiskPercent > 100.0) g_MaxRiskPercent = 100.0;

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
//| Helper: Check for Account Change                                 |
//+------------------------------------------------------------------+
bool CheckAndSetNewAccount()
{
   if(IsTesting()) return false;
   string gvName = "FantomePad_LastAccount";
   int currentAccount = (int)AccountNumber();
   int lastAccount = 0;
   if(GlobalVariableCheck(gvName)) lastAccount = (int)GlobalVariableGet(gvName);
   if(currentAccount != lastAccount)
   {
      GlobalVariableSet(gvName, (double)currentAccount);
      int total = SymbolsTotal(true);
      if(total > 0)
      {
         string firstSymbol = SymbolName(0, true);
         if(Symbol() != firstSymbol)
         {
            Print("FantomePad: Account Change (" + IntegerToString(lastAccount) + " -> " + IntegerToString(currentAccount) + "). Switching to: " + firstSymbol);
            ChartSetSymbolPeriod(0, firstSymbol, Period());
            return true;
         }
      }
   }
   return false;
}
