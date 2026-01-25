//+------------------------------------------------------------------+
//|                                      FantomePad_TestRunner.mq4   |
//|                                    Copyright 2025, RomeoHC       |
//+------------------------------------------------------------------+
#property copyright "RomeoHC"
#property description "Automated Test Runner for FantomePad"
#property strict

// IMPORTANT: Relative paths assume this file is in MQL4/Experts/FantomePad/
#include "Include/FantomePad/Core/Defines.mqh"
#include "Include/FantomePad/Core/Config.mqh"
#include "Include/FantomePad/Trade/Trade.mqh"
#include "Include/FantomePad/GUI/GUI_Master.mqh"

#include "Include/FantomePad/Tests/Test_Framework.mqh"
#include "Include/FantomePad/Tests/Test_Risk.mqh"
#include "Include/FantomePad/Tests/Test_UI.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Allow some time for chart to load
   EventSetTimer(1); 
   
   Print("=== FANTOME PAD - TEST RUNNER STARTED ===");
   
   // 1. INIT CORE
   InitGlobals();
   
   // Initialize GUI (Real Environment Simulation)
   GUI_OnInit(); 
   ChartRedraw();
   
   // 2. RUN TESTS
   
   Print("--- EXECUTING RISK SUITE ---");
   Setup_RiskTest();
   Test_CalculateLotSize_RiskPercent();
   Test_CalculateLotSize_RiskMoney();
   Cleanup_RiskTest();
   
   Print("--- EXECUTING UI SUITE ---");
   Cleanup_UI();
   Test_UiToggle_Main();
   Test_UiToggle_Positions();
   Test_UiToggle_Settings();
   Cleanup_UI();
   
   // 3. REPORT
   PrintTestSummary();
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   // Cleanup Test Artifacts
   ObjectsDeleteAll(0, PREFIX);
   ObjectsDeleteAll(0, "TestReport_");
   Comment("");
}

void OnTick()
{
   // Idle
}

void OnTimer()
{
   // Optional: Auto-remove after 5 seconds?
   // ExpertRemove();
}
