//+------------------------------------------------------------------+
//|                                              GraphicWrappers.mqh |
//|                                              FantomePad Project  |
//|                                     Common Graphical Abstraction |
//+------------------------------------------------------------------+
#ifndef _GRAPHIC_WRAPPERS_MQH_
#define _GRAPHIC_WRAPPERS_MQH_

// Include the correct platform wrapper
#ifdef __MQL5__
   #include "../../MT5/Wrappers/Graphic_Wrapper.mqh"
#else
   #include "../../MT4/Wrappers/Graphic_Wrapper.mqh"
#endif

#endif
