// Bridge.mqh - Platform Bridge
#property strict

// 1. Common Data Structures (DTO)
#include "Common/Core/DataTypes.mqh"

// 2. Graphic Abstraction
#include "Common/GUI/GraphicWrappers.mqh"

// 3. Platform Specific Implementations
#ifdef __MQL4__
   #include "MT4/Wrappers/Data_Wrapper.mqh"
   #include "MT4/Trade/Trade.mqh"
#else
   #include "MT5/Wrappers/Data_Wrapper.mqh"
   #include "MT5/Trade/Trade_Stubs.mqh"
   // MT5 Trade Implementation will be added here
#endif
