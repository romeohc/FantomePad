# TÂCHE : Implémenter le support MODE_HISTORY dans FP_OrderSelect pour MT5

## CONTEXTE DU PROJET
FantomePad est un Expert Advisor MQL4/MQL5 avec une architecture cross-platform. La compatibilité entre MT4 et MT5 est gérée par un fichier [Compatibility.mqh](cci:7://file:///Users/romeohc/Library/Application%20Support/net.metaquotes.wine.metatrader4/drive_c/Program%20Files%20%28x86%29/MetaTrader%204/MQL4/Experts/FantomePad/Include/FantomePad/Platform/Common/Compatibility.mqh:0:0-0:0) qui fournit des fonctions wrapper `FP_*` qui émulent l'API MT4 sur MT5 via des macros et fonctions.

Le fichier concerné est :
[Include/FantomePad/Platform/Common/Compatibility.mqh](cci:7://file:///Users/romeohc/Library/Application%20Support/net.metaquotes.wine.metatrader4/drive_c/Program%20Files%20%28x86%29/MetaTrader%204/MQL4/Experts/FantomePad/Include/FantomePad/Platform/Common/Compatibility.mqh:0:0-0:0)

## PROBLÈME
Dans la section MT5 de [Compatibility.mqh](cci:7://file:///Users/romeohc/Library/Application%20Support/net.metaquotes.wine.metatrader4/drive_c/Program%20Files%20%28x86%29/MetaTrader%204/MQL4/Experts/FantomePad/Include/FantomePad/Platform/Common/Compatibility.mqh:0:0-0:0), la fonction `FP_OrderSelect` ne gère que `pool == MODE_TRADES`. Si `pool == MODE_HISTORY`, la fonction retourne simplement `false` sans rien faire. Cela signifie que **tout l'accès à l'historique est cassé sur MT5** — notamment le panneau d'historique et la fonction `GetOriginalLotSize()` qui trace les tickets parents ("from #") pour le partial close.

## CE QUI EXISTE ACTUELLEMENT (Section MT5 uniquement)

```cpp
// Selection state tracking
static bool g_fp_is_position = false;
static ulong g_fp_selected_ticket = 0;

bool FP_OrderSelect(int index, int select, int pool=MODE_TRADES)
{
   g_fp_is_position = false;
   g_fp_selected_ticket = 0;

   if(pool == MODE_TRADES)
   {
      int posTotal = PositionsTotal();
      if(select == SELECT_BY_POS)
      {
         if(index < posTotal)
         {
            string sym = PositionGetSymbol(index);
            if(sym != "") 
            {
               g_fp_is_position = true;
               g_fp_selected_ticket = PositionGetInteger(POSITION_TICKET);
               return true;
            }
         }
         else
         {
            int ordIndex = index - posTotal;
            if(ordIndex < OrdersTotal())
            {
               ulong ticket = OrderGetTicket(ordIndex);
               if(ticket > 0)
               {
                  g_fp_selected_ticket = ticket;
                  return true;
               }
            }
         }
      }
      else // BY_TICKET
      {
         if(PositionSelectByTicket((ulong)index))
         {
            g_fp_is_position = true;
            g_fp_selected_ticket = (ulong)index;
            return true;
         }
         if(OrderSelect((ulong)index))
         {
            g_fp_selected_ticket = (ulong)index;
            return true;
         }
      }
   }
   // MODE_HISTORY N'EST PAS GÉRÉ ! → retourne false
   return false; 
}

Il y a aussi un état global qui doit être étendu pour distinguer un deal historique :

static bool g_fp_is_position = false;  // true = position, false = pending order
static ulong g_fp_selected_ticket = 0;

Les fonctions de lecture des propriétés utilisent g_fp_is_position pour décider s'il faut lire depuis PositionGet* ou OrderGet*. Il faudra ajouter un troisième état pour les deals historiques (lecture via HistoryDealGet* ou HistoryOrderGet*).

Les fonctions de propriétés impactées (section MT5) :

FP_OrderOpenPrice() — doit retourner le prix du deal historique
FP_OrderStopLoss() — impossible via HistoryDeal, il faut chercher dans HistoryOrder
FP_OrderTakeProfit() — idem
FP_OrderLots() — doit retourner DEAL_VOLUME
FP_OrderTicket() — le ticket du deal
FP_OrderSymbol() — DEAL_SYMBOL
FP_OrderType() — mapper DEAL_TYPE vers OP_BUY/OP_SELL
FP_OrderProfit() — DEAL_PROFIT
FP_OrderSwap() — DEAL_SWAP
FP_OrderCommission() — DEAL_COMMISSION
FP_OrderComment() — DEAL_COMMENT
FP_OrderCloseTime() — DEAL_TIME pour les deals de clôture
FP_OrderOpenTime() — DEAL_TIME pour les deals d'ouverture
FP_OrderMagic() — DEAL_MAGIC
Il y a aussi FP_OrdersHistoryTotal() qui retourne HistoryDealsTotal() — c'est un bon début mais il faut s'assurer que HistorySelect() est appelé au préalable pour charger l'historique.

CE QUE TU DOIS FAIRE
Ajouter un troisième état : Créer un static bool g_fp_is_history_deal = false; ou un enum pour distinguer les 3 cas (position, pending order, history deal).

Implémenter MODE_HISTORY dans FP_OrderSelect :

Pour SELECT_BY_POS : Appeler HistorySelect(0, TimeCurrent()) d'abord pour charger l'historique, puis utiliser HistoryDealGetTicket(index).
Pour SELECT_BY_TICKET : Appeler HistorySelect(0, TimeCurrent()) puis HistoryDealSelect(ticket).
Mettre à jour les flags d'état.
Mettre à jour TOUTES les fonctions FP_Order* pour gérer le cas historique (utiliser HistoryDealGet* quand g_fp_is_history_deal == true).

Cas spéciaux MT5 :

En MT5 les deals n'ont pas de SL/TP directement. Pour avoir le SL/TP d'un deal clôturé, il faut trouver l'ordre original associé via DEAL_ORDER → HistoryOrderSelect() → ORDER_SL / ORDER_TP.
Le OrderType pour l'historique doit mapper DEAL_TYPE_BUY → OP_BUY, DEAL_TYPE_SELL → OP_SELL.
Le OrderComment doit venir de HistoryDealGetString(ticket, DEAL_COMMENT).
CONTRAINTES
NE PAS casser le code existant pour MODE_TRADES
Le fichier doit compiler en MT4 ET MT5 (la section MT4 ne doit pas être touchée)
Utiliser les include guards existants (#ifndef _COMPATIBILITY_MQH_)
Rester dans le même fichier Compatibility.mqh