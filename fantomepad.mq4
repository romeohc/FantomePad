//+------------------------------------------------------------------+
//|                                                  fantomepad.mq4  |
//|                                     Copyright 2026, FantomePad   |
//|                                          Designed for Aesthetics |
//+------------------------------------------------------------------+
#property copyright "Copyright qzfqfgzf2026, FantomePad"
#property link      "https://fantomepad.com"
#property version   "2.00"
#property strict

// Include Modular Logic
#include "Include/FantomePad/Core/Defines.mqh"
#include "Include/FantomePad/Core/Config.mqh"
#include "Include/FantomePad/GUI/GUI_Master.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // --- INPUT VALIDATION (SECURITY) ---
   if(MaxSlippage < 0)
   {
      Alert("FantomePad Error: MaxSlippage cannot be negative. Using default (10).");
   }
   
   if(OneRPercent <= 0)
   {
      Alert("FantomePad Error: OneRPercent must be greater than 0. Using default (2.0).");
   }
   
   if(MaxRiskPercent > 100.0 || MaxRiskPercent <= 0)
   {
      Alert("FantomePad Error: MaxRiskPercent must be between 0.1 and 100. Using default (2.0).");
      // On ne bloque pas l'init, mais on corrige la valeur pour éviter le crash
      // Note: La variable globale g_MaxRiskPercent sera écrasée par LoadConfig() plus tard, 
      // mais cette alerte prévient l'utilisateur s'il a mal configuré les Inputs.
   }
   
   if(MagicNumber <= 0)
   {
      Alert("FantomePad Error: MagicNumber must be a positive integer.");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   // --- SECURITY AUDIT FIX: MAGIC NUMBER CONFLICT ---
   if(MagicNumber == 123456 || MagicNumber == 11111 || MagicNumber == 123)
   {
      Print("FantomePad Warning: You are using a very common MagicNumber (" + IntegerToString(MagicNumber) + "). Ensure no other EAs use this ID.");
   }
   
   // --- END VALIDATION ---

   // 1. Initialiser les globales depuis les Inputs
   InitGlobals();
   
   // 2. Charger la configuration sauvegardée
   LoadConfig();

   // --- CONFIG SANITY CHECK ---
   // We validate the loaded config values to prevent dangerous edits in the text file
   if(g_MaxRiskPercent <= 0) g_MaxRiskPercent = 2.0;       // Default safe fallback
   if(g_MaxRiskPercent > 100.0) g_MaxRiskPercent = 100.0;  // Cap at 100% (Account Blowout Limit)
   // -----------------------------------------------
   
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