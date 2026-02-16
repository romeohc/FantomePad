#ifndef ACCOUNT_GLOBALS_MQH
#define ACCOUNT_GLOBALS_MQH

#property strict

// GLOBAL pour suivre le nombre d'ordres affichés
int g_LastAccountOrderCount = 0;
int g_TotalAccountOrderCount = 0; // Total orders (including non-visible due to scroll)
long g_AccountOrdersTickets[];     // Tickets of currently visible orders (for click handling)

// Optimization: Cache history stats to avoid O(N) loop every tick
int    g_LastHistoryTotal = -1;
double g_CachedDeposit    = 0.0;
double g_CachedWithdraw   = 0.0;

#endif
