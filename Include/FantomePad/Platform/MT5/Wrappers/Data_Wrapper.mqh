//+------------------------------------------------------------------+
//|                                              Data_Wrapper.mqh    |
//|                                              FantomePad Project  |
//|                                                  (MT5 Specific)  |
//+------------------------------------------------------------------+
#property strict
#include "../../Common/Core/DataTypes.mqh"

//+------------------------------------------------------------------+
//| STUB: Remplir la structure FantomeTrade                          |
//| Pre-condition: Position ou Ordre déjà sélectionné par le caller  |
//+------------------------------------------------------------------+
void FP_GetTrade(FantomeTrade &trade)
{
   // TODO MT5: Implémenter la logique de récupération
   // Utiliser PositionGetInteger, PositionGetDouble, etc.
   trade.Ticket = 0;
}

//+------------------------------------------------------------------+
//| STUB: Remplir la structure FantomeAccount                        |
//+------------------------------------------------------------------+
void FP_GetAccount(FantomeAccount &account)
{
   // TODO MT5: Implémenter AccountInfo*
   account.Login = 0;
}
