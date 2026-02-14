//+------------------------------------------------------------------+
//|                                                Panel_Main.mqh    |
//|                                              FantomePad Project  |
//+------------------------------------------------------------------+
#property strict

// 1. Shared Prototypes (Resolve Circular Dependencies)
#include "Panel_Main_Shared.mqh"

// 2. Individual Components (Implementations)
// The order here matters less because they all see the Shared prototypes
#include "Panel_Main_Error.mqh"
#include "Panel_Main_Logic.mqh"
#include "Panel_Main_Layout.mqh"
#include "Panel_Main_Create.mqh"
#include "Panel_Main_Events.mqh"
