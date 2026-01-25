//+------------------------------------------------------------------+
//|                                                  fantomepad.mq4  |
//|                                     Copyright 2026, FantomePad   |
//|                                          Designed for Aesthetics |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, FantomePad"
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
   // 1. Initialiser les globales depuis les Inputs
   InitGlobals();
   
   // 2. Charger la configuration sauvegardée
   LoadConfig();
   
   // 3. Setup Chart event handling
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   
   // --- ESTHÉTIQUE DU GRAPHIQUE ---
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, g_ColorChartBg);
   ChartSetInteger(0, CHART_COLOR_FOREGROUND, g_ColorChartFg);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, g_ColorCandleUp);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, g_ColorCandleDown);
   ChartSetInteger(0, CHART_COLOR_CHART_UP, g_ColorCandleUp);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, g_ColorCandleDown);
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   ChartSetInteger(0, CHART_SHOW_OHLC, false);
   ChartSetInteger(0, CHART_SHOW_ONE_CLICK, false);
   
   // Désactiver les niveaux de trade natifs pour utiliser nos couleurs personnalisées
   ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, false);
   ChartSetInteger(0, CHART_SHOW_BID_LINE, false);
   ChartSetInteger(0, CHART_SHOW_ASK_LINE, false);
   
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
   ObjectsDeleteAll(0, PREFIX);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
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