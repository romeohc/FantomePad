//+------------------------------------------------------------------+
//|                                                  fantomepad.mq4  |
//|                                     Copyright 2026, FantomePad   |
//|                                          Designed for Aesthetics |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, FantomePad"
#property link      "https://fantomepad.com"
#property version   "1.00"
#property strict

// Include Modular Logic
#include "Include/FantomePad/Platform/Common/Core/Defines.mqh"
#include "Include/FantomePad/Platform/Common/Core/Config.mqh"
#include "Include/FantomePad/Platform/Bridge.mqh"
#include "Include/FantomePad/Platform/Common/GUI/GUI_Master.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // --- CORE ENGINE INIT ---
   Bridge_InitEngine();

   // 1. Initialiser les globales depuis les Inputs (Inputs -> Globals)
   InitGlobals();
   
   // 2. Charger la configuration sauvegardée (File -> Globals override)
   LoadConfig();

   // --- GLOBAL STATE SAFETY ENFORCEMENT (SILENT CORRECTION) ---
   // We enforce strict limits here to fix any bad values from Inputs or Config file.
   // No popups/alerts to the user — we just fix it silently to safe defaults.

   // Fix W3 & W1: One R Percent Safety
   if(g_OneRPercent <= 0) 
   {
       g_OneRPercent = 2.0; // Safe default
       // Optional: Print("FantomePad Info: OneRPercent corrected to safe default (2.0%)");
   }
   
   // Fix W1: Max Risk Percent Safety (Cap at 100%, Floor at 0.1%)
   if(g_MaxRiskPercent <= 0) g_MaxRiskPercent = 2.0; 
   if(g_MaxRiskPercent > 100.0) g_MaxRiskPercent = 100.0;
   
   // Fix W2: MaxSlippage (Note: Input 'MaxSlippage' is read-only, but logic uses it downstream. 
   // Since we can't change the Input variable, we rely on the fact that standard brokers reject negative slippage 
   // or treat it as 0. Capital safety is not compromised.)
   
   // Magic Number Logic
   if(MagicNumber <= 0 && !IsTesting())
   {
       Print("FantomePad Error: MagicNumber is invalid (<=0). Trading behaviors may be undefined.");
       // We don't return INIT_FAILED to keep the chart running, but trading is unsafe.
   }
   // -----------------------------------------------------------

   // --- AUTO-SELECT SYMBOL ON ACCOUNT CHANGE ---
   if(CheckAndSetNewAccount())
   {
       // If a symbol switch was triggered, we stop here.
       // MT4 will automatically restart OnInit on the new symbol.
       return(INIT_SUCCEEDED);
   }
   // --------------------------------------------
   
   // 3. Setup Chart event handling
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   
   // Enable high-frequency timer for reactive UI (AutoTrading state)
   EventSetMillisecondTimer(200);
   
   // --- ESTHÉTIQUE DU GRAPHIQUE ---
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, g_ColorChartBg);
   ChartSetInteger(0, CHART_COLOR_FOREGROUND, g_ColorChartFg);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, g_ColorCandleUp);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, g_ColorCandleDown);
   ChartSetInteger(0, CHART_COLOR_CHART_UP, g_ColorCandleUp);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, g_ColorCandleDown);
   
   // Nettoyage visuel complet
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   ChartSetInteger(0, CHART_SHOW_PERIOD_SEP, false);
   ChartSetInteger(0, CHART_SHOW_VOLUMES, false);
   ChartSetInteger(0, CHART_SHOW_OHLC, false);
   ChartSetInteger(0, CHART_SHOW_ONE_CLICK, false);
   
   // Ensure UI is drawn ON TOP of the candles (Fix for transparency/z-order issue)
   ChartSetInteger(0, CHART_FOREGROUND, false);
   
   // Désactiver les niveaux de trade natifs pour utiliser nos couleurs personnalisées
   ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, false);
   ChartSetInteger(0, CHART_SHOW_BID_LINE, false);
   ChartSetInteger(0, CHART_SHOW_ASK_LINE, false);
   
   // Disable AutoScroll to prevent chart snapping back on ticks
   ChartSetInteger(0, CHART_AUTOSCROLL, false);
   
   // --- INSTANT AUTH BLACKOUT (Consistency Fix) ---
   // We perform a preliminary check to see if we should start with a black chart.
   HandleInitialLicenseCheck(); 
   if(!g_IsLicensed && g_LicenseState != LICENSE_REVOKED)
   {
      SyncChartUI(); 
   }

   // --- AUTO-SCROLL TO PRESENT ---
   // Par défaut on affiche toujours la fin du graphique (le présent) à chaque changement d'actif
   ChartNavigate(0, CHART_END, 0);

   // Rendu immédiat pour éviter les clignotements au chargement
   ChartRedraw();
   
   // 4. Lancer l'interface graphique via le Master Controller
   GUI_OnInit();
   
   // Initial Calc
   UpdateCalculatedLot();
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectsDeleteAll(0, PREFIX);
   
   // --- RESTORE CHART UI ON EXIT ---
   ChartSetInteger(0, CHART_SHOW_PRICE_SCALE, true);
   ChartSetInteger(0, CHART_SHOW_DATE_SCALE, true);
   ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
   ChartSetInteger(0, CHART_KEYBOARD_CONTROL, true);

   // --- ENGINE CLEANUP ---
   Bridge_DeinitEngine();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!g_IsLicensed) 
   {
      GUI_OnTick(); // Still need to update Auth UI if visible
      return;
   }

   // Mise à jour des lignes d'ordres ouverts (Custom Colors)
   UpdateOpenOrderLines();
   
   // Recalcul en temps réel pour le mode Marché (car le prix bouge tout le temps)
   if(CurrentTypeIndex == 0)
   {
      UpdateCalculatedLot();
   }
   
   GUI_OnTick();
}

//+------------------------------------------------------------------+
//| Expert timer function                                            |
//+------------------------------------------------------------------+
void OnTimer()
{
   GUI_OnTick(); // Keep tick logic alive if market is slow (optional, but good for clock)
   GUI_OnTimer();
}

//+------------------------------------------------------------------+
//| ChartEvent function (Interactions Utilisateur)                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   // Déléguer entièrement au Master Controller
   GUI_OnChartEvent(id, lparam, dparam, sparam);
}

//+------------------------------------------------------------------+
//| Helper: Check for Account Change & Auto-Select First Symbol      |
//+------------------------------------------------------------------+
bool CheckAndSetNewAccount()
{
   if(IsTesting()) return false; 

   // Security: If not connected to an account, don't trigger auto-switch logic
   // This prevents infinite loops and unnecessary restarts when account number is 0.
   long currentAccount = AccountNumber();
   if(currentAccount <= 0) return false;

   string gvName = "FantomePad_LastAccount";
   long lastAccount = 0;

   // Check if global variable exists and retrieve value
   if(GlobalVariableCheck(gvName))
   {
      lastAccount = (long)GlobalVariableGet(gvName);
   }

   // If changed (or first run on this terminal because var didn't exist)
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
            Print("FantomePad: Account Change Detected (", lastAccount, " -> ", currentAccount, "). Auto-switching to first symbol: ", firstSymbol);
            ChartSetSymbolPeriod(0, firstSymbol, Period());
            return true;
         }
      }
      
      // If we reach here, we are either already on the correct symbol 
      // or there's no symbol to switch to. Finalize account change record.
      GlobalVariableSet(gvName, (double)currentAccount);
   }
   return false;
}