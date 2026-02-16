// Bridge.mqh - Platform Bridge
#property strict

// 1. Common Data Structures (DTO)
#include "Common/Core/DataTypes.mqh"

// 2. Graphic Abstraction
#include "Common/GUI/GraphicWrappers.mqh"

// 2.5 CORE ENGINE INTERFACE (Must be before implementations)
#include "Common/Core/Engine/ITradeEngine.mqh"

// New Engine System
#include "Common/Core/Engine/TradeErrorHandler.mqh"
#include "Common/Core/Engine/TradeValidator.mqh"
#include "Common/Core/Engine/TradeOrchestrator.mqh"

// --- GLOBAL TRADE ENGINE POINTER ---
ITradeEngine *g_TradeEngine = NULL;

// 3. Platform Specific Implementations
#ifdef __MQL4__
   #include "MT4/Wrappers/Data_Wrapper.mqh"
   // Engine Implementation first
   #include "MT4/Engine/TradeEngineMT4.mqh"
#else
   #include "MT5/Wrappers/Data_Wrapper.mqh"
   // Engine Implementation first
   #include "MT5/Engine/TradeEngineMT5.mqh"
#endif

// --- ENGINE LIFECYCLE MANAGEMENT ---
void Bridge_InitEngine()
{
   if(CheckPointer(g_TradeEngine) != POINTER_INVALID)
      return;

   #ifdef __MQL4__
      g_TradeEngine = new C_TradeEngineMT4();
   #else
      g_TradeEngine = new C_TradeEngineMT5();
   #endif
   
   Print("Bridge: Trade Engine Initialized for ", 
         #ifdef __MQL4__ "MT4" #else "MT5" #endif);
}

void Bridge_DeinitEngine()
{
   if(CheckPointer(g_TradeEngine) == POINTER_DYNAMIC)
   {
      delete g_TradeEngine;
      g_TradeEngine = NULL;
   }
}
