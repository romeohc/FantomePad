
---

## Prompt 2 — Fix 4.3 : [Handler_PositionActions.mqh](cci:7://file:///Users/romeohc/Library/Application%20Support/net.metaquotes.wine.metatrader4/drive_c/Program%20Files%20%28x86%29/MetaTrader%204/MQL4/Experts/FantomePad/Include/FantomePad/Platform/Common/GUI/Events/Handlers/Handler_PositionActions.mqh:0:0-0:0) — Remplacer les appels natifs par `FP_*`

TÂCHE : Remplacer tous les appels directs Object* par FP_Object* dans Handler_PositionActions.mqh
CONTEXTE DU PROJET
FantomePad est un Expert Advisor cross-platform MQL4/MQL5. Pour assurer la compatibilité MT4↔MT5, toutes les fonctions graphiques (ObjectSetString, ObjectGetString, ObjectSetInteger, ObjectGetInteger, ObjectCreate, ObjectDelete, ObjectFind) sont wrappées dans des fonctions FP_Object* définies dans des fichiers Graphic_Wrapper.mqh spécifiques à chaque plateforme.

Le fichier concerné est : 

Include/FantomePad/Platform/Common/GUI/Events/Handlers/Handler_PositionActions.mqh

PROBLÈME
Ce fichier utilise parfois les fonctions natives ObjectSetString(0, ...), ObjectGetString(0, ...), ObjectSetInteger(0, ...) au lieu de leurs wrappers FP_ObjectSetString(0, ...), FP_ObjectGetString(0, ...), FP_ObjectSetInteger(0, ...). Sur MT4 c'est transparent (les wrappers appellent les natifs directement), mais sur MT5 ça peut causer des problèmes de compatibilité.

CE QUE TU DOIS FAIRE
Remplace chaque occurrence suivante par son wrapper FP_ :

ObjectSetString(0, ...) → FP_ObjectSetString(0, ...)
ObjectGetString(0, ...) → FP_ObjectGetString(0, ...)
ObjectSetInteger(0, ...) → FP_ObjectSetInteger(0, ...)
ObjectGetInteger(0, ...) → FP_ObjectGetInteger(0, ...)
Les lignes impactées dans le fichier actuel (316 lignes) sont approximativement :

Ligne 19 : ObjectSetString(0, PREFIX + "Pos_Edit_Close", OBJPROP_TEXT, "0");
Ligne 32 : idem
Ligne 45 : idem
Lignes 78-81 : ObjectSetInteger(0, PREFIX + "Pos_Btn_BE", OBJPROP_BGCOLOR, ...) et ObjectSetString
Lignes 85-87 : idem
Lignes 149-153 : ObjectGetString(0, PREFIX + "Pos_Edit_SL", ...), SL, TP, Entry, Close
Ligne 184 : ObjectGetString
Ligne 228 : ObjectSetString
Lignes 264-266 : ObjectGetString
Ligne 271 : ObjectGetString
Lignes 280, 296-297 : ObjectSetInteger, ObjectSetString
CONTRAINTES
Ne changer QUE les appels Object* natifs → FP_Object*
Ne PAS modifier la logique métier, les conditions, ou les valeurs
Le fichier commence par #property strict et inclut 

TradeOrchestrator.mqh
 et 

TradeErrorHandler.mqh
Vérifier qu'il n'y a AUCUN ObjectSetString / ObjectGetString / ObjectSetInteger (sans préfixe FP_) restant à la fin