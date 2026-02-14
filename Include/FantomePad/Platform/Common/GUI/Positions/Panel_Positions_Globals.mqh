//+------------------------------------------------------------------+
//|                                     Panel_Positions_Globals.mqh  |
//|                                           FantomePad Project     |
//+------------------------------------------------------------------+
#property strict

// --- TRACKING GLOBALS ---
int    g_LastPosTicket = -1;
double g_LastPosSL = -1.0;
double g_LastPosTP = -1.0;
double g_LastPosEntry = -1.0;
bool   g_PosBE_Active = false;
int    g_PosPartialMode = 0; // 0, 25, 50, 100
