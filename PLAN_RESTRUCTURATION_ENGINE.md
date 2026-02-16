# PLAN DIRECTEUR : UNIFICATION DU MOTEUR DE TRADING (FANTOMEPAD)

**Version :** 6.0 (Production-Grade, Secure, Hardened)
**Date :** 16 Février 2026
**Statut :** CORRIGÉ & PRÊT POUR EXÉCUTION
**Objectif :** Créer un moteur de trading **Single Source of Truth**, découplé du GUI, intégrant 100% des sécurités existantes (Busy, Retry, Margin, Spread, StopLevel), supportant MT4 et MT5 avec une seule logique.

---

## 1. VISION ARCHITECTURALE : LE "FANTOME ENGINE"

L'architecture suit strictement le principe de séparation des responsabilités. Le Moteur ne connait **RIEN** de l'Interface Utilisateur.

### 🔄 Flux d'Exécution Standard

1. **UI Layer (`Handler`)** : Récupère les inputs utilisateur → Construit un DTO `TradeRequest`. **AUCUNE validation métier ici** (sauf vérification basique que les champs sont non-vides pour le feedback immédiat).
2. **Orchestrator (`Core`)** : Reçoit `TradeRequest` → Appelle `TradeValidator` → Appelle `TradeEngine` → Retourne `TradeResult`.
3. **Engine Layer (`Impl`)** : Exécute l'ordre sur le marché (MT4/MT5) avec robustesse (Retries/Busy/Margin).
4. **UI Layer (`Handler`)** : Reçoit `TradeResult` → Affiche Toast/Error Succès/Erreur → Reset UI si succès.

### 📂 Structure de Fichiers Cible

```text
Include/FantomePad/Platform/
├── Common/
│   ├── Compatibility.mqh                # Macros MT4↔MT5 (existant, à maintenir)
│   ├── Core/
│   │   ├── DataTypes.mqh                # (UPDATE) Struct TradeRequest + TradeResult + Enums + FantomeTrade/FantomeAccount (existant)
│   │   ├── Defines.mqh                  # (EXISTANT) Globals + Inputs + Structs + constantes communes
│   │   ├── Config.mqh                   # (EXISTANT) Save/Load configuration
│   │   ├── Security.mqh                 # (EXISTANT)
│   │   ├── TradeLogic/                  # (NOUVEAU DOSSIER - Remplace TradeLogic.mqh monolithique)
│   │   │   ├── TradeCalc.mqh           # [PURE] Maths only (CalculateLotSize, GetRiskPercentage, ValidateSlDirection, GetSlippagePoints). AUCUNE dépendance GUI/UI.
│   │   │   ├── TradeVisuals.mqh        # [VIEW] Gestion des lignes sur le chart (UpdateChartLines, UpdateSingleLine, CreateHLine, UpdateOpenOrderLines). Dépend de GraphicWrappers.
│   │   │   └── TradeUIInteraction.mqh  # [INTERACTION] Logique UI complexe (AutoSwitchOrderType, UpdateCalculatedLot, UpdateCalculatedRisk). Lit l'UI. N'est PAS du Core pur.
│   │   ├── Engine/
│   │   │   ├── ITradeEngine.mqh        # (INTERFACE) Contrat strict retournant TradeResult.
│   │   │   ├── TradeValidator.mqh      # (LOGIC) Centralisation de TOUTE la validation pré-exécution.
│   │   │   ├── TradeOrchestrator.mqh   # (CONTROLLER) Validate → Execute → Result. Point d'entrée unique.
│   │   │   └── TradeErrorHandler.mqh   # (UTILITY) Formatage des messages d'erreur techniques + user-friendly.
│   │   └── IO/
│   │       ├── FileManager.mqh         # (EXISTANT)
│   │       └── HttpManager.mqh         # (EXISTANT)
│   └── GUI/Events/Handlers/
│       ├── Handler_Trading.mqh         # (CLIENT) Construit TradeRequest → Appelle Orchestrator → Lit TradeResult.
│       ├── Handler_PositionActions.mqh # (CLIENT) Calcul Partial Close → Appelle Engine.Close/Modify/Delete.
│       └── ... (autres handlers inchangés)
│
├── MT4/
│   ├── Engine/
│   │   └── TradeEngineMT4.mqh          # (IMPL) Robuste : Busy Loop, Retries, RefreshRates, Margin Check, StopLevel Check.
│   ├── Trade/                           # (LEGACY - À SUPPRIMER EN FIN)
│   │   ├── Trade.mqh                   # Agrégateur legacy
│   │   ├── Trade_Constants.mqh         # MAX_RETRIES, RETRY_DELAY → Migré dans TradeEngineMT4
│   │   ├── Trade_Calculations.mqh      # Proxy vers TradeLogic.mqh → Supprimé
│   │   ├── Trade_Execution.mqh         # SafeOrderSend/Close/Modify/Delete → Migré dans TradeEngineMT4
│   │   ├── Trade_Lines.mqh             # Proxy vers TradeLogic.mqh → Supprimé
│   │   └── Trade_Manager.mqh           # ExecuteOrder() → Migré dans TradeOrchestrator
│   └── Wrappers/
│       ├── Data_Wrapper.mqh            # (EXISTANT)
│       └── Graphic_Wrapper.mqh         # (EXISTANT)
│
├── MT5/
│   ├── Engine/
│   │   └── TradeEngineMT5.mqh          # (IMPL) Wrapper CTrade + Mapping RetCodes vers TradeResult.
│   ├── Trade/
│   │   └── Trade_Stubs.mqh             # (LEGACY - À SUPPRIMER EN FIN)
│   └── Wrappers/
│       ├── Data_Wrapper.mqh            # (EXISTANT)
│       └── Graphic_Wrapper.mqh         # (EXISTANT)
│
├── Bridge.mqh                           # Point d'entrée unique (mise à jour pour supprimer les imports legacy)
```

## 2. ÉTAT ACTUEL DU CODE (DIAGNOSTIC PRÉ-RESTRUCTURATION)

### 🟡 État Hybride Identifié
Le code est dans un état hybride dangereux :

*   `Trade_Manager.mqh::ExecuteOrder()` fait **TOUTE** la validation (SL, Risk, Margin, Spread) **ET** utilise déjà `g_TradeEngine.OpenMarket()` / `g_TradeEngine.OpenPending()`.
*   `Handler_Trading.mqh` fait **AUSSI** des validations (SL, Risk, MaxRisk, LotSize, SL Direction) **AVANT** d'appeler `ExecuteOrder()`.
    *   → **Duplication de validation = Risque de divergence + Double-maintenance.**
*   `Handler_PositionActions.mqh` appelle les fonctions legacy `SafeOrderClose()`, `SafeOrderDelete()`, `SafeOrderModify()`.
*   `TradeEngineMT4.mqh` actuel est naïf : simple `OrderSend` sans retry/busy/margin.
*   `TradeLogic.mqh` est un fichier monolithique de 534 lignes mélangeant calculs purs, lignes graphiques et interaction UI.

### 🔴 Problèmes Critiques Non Couverts par le Plan v5
*   `MODE_MARGINREQUIRED` est un placeholder (= 0) dans `Compatibility.mqh` pour MT5.
*   `UpdateOpenOrderLines()` utilise `OrdersTotal()`/`OrderSelect()` qui ne gèrent que les positions en MT5, pas les ordres pendants.
*   Les stubs MT5 ont des signatures incompatibles (`int` au lieu de `color`).
*   `HandleTradeError()`/`HandleTradeMessage()` ne sont pas migrées.

---

## 3. PROTOCOLE D'EXÉCUTION CHIRURGICAL (17 ÉTAPES)
Règle d'Or : À la fin de chaque étape, le projet DOIT compiler sur MT4 ET MT5 (0 Error).

### PHASE 1 : FONDATIONS (DATA & CONTRATS)

#### ✅ [TERMINÉ] ÉTAPE 1 : Enrichissement des Données (`DataTypes.mqh`)
**Localisation :** `Common/Core/DataTypes.mqh`

**Action :** Ajouter les structures SANS toucher aux existantes `FantomeTrade`/`FantomeAccount`.

```cpp
// --- Enum pour les types de résultat ---
enum ENUM_TRADE_ERROR_TYPE {
   TRADE_ERR_NONE = 0,
   TRADE_ERR_VALIDATION,     // Pre-flight check failed
   TRADE_ERR_BROKER,         // Broker rejected
   TRADE_ERR_MARKET,         // Market conditions (spread, closed)
   TRADE_ERR_MARGIN,         // Insufficient margin
   TRADE_ERR_STOPLEVEL,      // SL/TP/Entry too close
   TRADE_ERR_PERMISSION,     // Trading disabled
   TRADE_ERR_RETRY_EXHAUSTED,// All retries failed
   TRADE_ERR_BUSY,           // Trade context busy (MT4 only)
   TRADE_ERR_UNKNOWN
};

// DTO pour une demande d'exécution
struct TradeRequest {
   string   Symbol;
   int      Type;         // OP_BUY, OP_SELL, OP_BUYLIMIT, etc.
   double   Lots;
   double   Price;
   double   SL;
   double   TP;
   string   Comment;
   int      Magic;
   datetime Expiration;
   double   RiskPercent;  // Pour validation interne (optionnel)
};

// DTO pour le résultat
struct TradeResult {
   bool     Success;
   long     Ticket;
   int      ErrorCode;       // Code d'erreur natif broker
   ENUM_TRADE_ERROR_TYPE ErrorType;
   string   Message;         // Message user-friendly
   string   TechnicalDetail; // Détail technique (pour Print/Log)
};

// Helper constructors (fonctions statiques car MQL ne supporte pas les constructeurs complexes)
TradeResult MakeSuccessResult(long ticket, string msg = "")
{
   TradeResult r;
   r.Success = true;
   r.Ticket = ticket;
   r.ErrorCode = 0;
   r.ErrorType = TRADE_ERR_NONE;
   r.Message = (msg != "") ? msg : "Order executed successfully.";
   r.TechnicalDetail = "";
   return r;
}

TradeResult MakeErrorResult(int errCode, ENUM_TRADE_ERROR_TYPE errType, string userMsg, string techDetail = "")
{
   TradeResult r;
   r.Success = false;
   r.Ticket = -1;
   r.ErrorCode = errCode;
   r.ErrorType = errType;
   r.Message = userMsg;
   r.TechnicalDetail = techDetail;
   return r;
}
```
**Vérification :** Compile MT4 ✅, Compile MT5 ✅. Aucun fichier existant touché.

#### ✅ [TERMINÉ] ÉTAPE 2 : Mise à jour de l'Interface (`ITradeEngine.mqh`)
**Localisation :** `Common/Core/Engine/ITradeEngine.mqh`

**Breaking Change :** Remplacer les retours `long`/`bool` par `TradeResult`.

```cpp
virtual TradeResult OpenMarket(string symbol, int type, double lots, double price,
                                double sl, double tp, string comment, int magic) = 0;
virtual TradeResult OpenPending(string symbol, int type, double lots, double price,
                                 double sl, double tp, string comment, int magic, datetime expiration) = 0;
virtual TradeResult Modify(long ticket, double sl, double tp) = 0;
virtual TradeResult Close(long ticket, double lots, string comment) = 0;
virtual TradeResult Delete(long ticket) = 0;
```

**Action immédiate :**
1. Mettre à jour `TradeEngineMT4.mqh` et `TradeEngineMT5.mqh` avec ces nouvelles signatures (retourner `MakeErrorResult(0, TRADE_ERR_NONE, "NOT_IMPL")` temporairement pour les méthodes non migrées).
2. Adapter `Trade_Manager.mqh` : Les appels `g_TradeEngine.OpenMarket/OpenPending` retournent maintenant `TradeResult`. Adapter `ExecuteOrder()` pour lire `result.Success` et `result.Ticket` au lieu de `ticket >= 0`.

**Vérification :** Compile MT4 ✅, Compile MT5 ✅.

---

### PHASE 2 : LOGIQUE MÉTIER PURE

#### ✅ [TERMINÉ] ÉTAPE 3 : Éclatement de `TradeLogic.mqh` → Dossier `TradeLogic/`
**Localisation :** `Common/Core/TradeLogic/` (NOUVEAU DOSSIER)

**3A — `TradeCalc.mqh` (PURE MATH, 0 UI)**
*   **Source :** `TradeLogic.mqh` Section 1 (lignes 16-101) + `GetSlippagePoints` (ligne 227-232).
*   **Extraire :**
    *   `GetRiskPercentage(double riskValue)` — ⚠️ Dépend de `RiskMode` et `g_OneRPercent` (globales de `Defines.mqh`). Acceptable car ce sont des paramètres de configuration, pas de l'UI.
    *   `ValidateSlDirection(int cmd, double entry, double sl)` — Pur.
    *   `CalculateLotSize(double entryPrice, double slPrice, double riskValue)` — ⚠️ Contient `FP_ObjectGetString()` pour lire le symbole depuis l'UI ! → **CORRECTION :** Ajouter un paramètre `string symbol` et supprimer l'appel UI. Le caller passera le symbole.
    *   `GetSlippagePoints(int slippagePips)` — Pur.
*   **Contrainte :** AUCUN appel à `FP_ObjectGetString`, `ObjectGetString`, ou toute fonction UI.

**3B — `TradeVisuals.mqh` (LIGNES GRAPHIQUES)**
*   **Source :** `TradeLogic.mqh` Section 2 (lignes 234-406).
*   **Extraire :**
    *   `UpdateSingleLine(...)` — Dépend de `FP_ObjectCreate/Set/Get`, acceptable.
    *   `UpdateChartLines()` — Dépend de globales UI (`g_ShowOrderLines`, `g_PanelMain.IsVisible`, etc.).
    *   `CreateHLine(...)` — OK.
    *   `UpdateOpenOrderLines()` — ⚠️ ATTENTION MT5 : Utilise `OrdersTotal()`/`OrderSelect()` qui via `Compatibility` ne couvrent que `PositionsTotal()`. Les ordres pendants MT5 ne sont PAS gérés. → **NOTE POUR LE FUTUR (Phase 7) :** Ajouter une branche `#ifdef __MQL5__` pour itérer aussi `OrdersTotal()` natif MT5 (pendants).
*   **Include requis :** `../Defines.mqh`, `../../GUI/GraphicWrappers.mqh`

**3C — `TradeUIInteraction.mqh` (LOGIQUE UI)**
*   **Source :** `TradeLogic.mqh` Section 3 (lignes 103-531).
*   **Extraire :**
    *   `UpdateCalculatedLot()` — Lit l'UI, écrit l'UI. Parfait pour cette couche.
    *   `UpdateCalculatedRisk()` — Idem.
    *   `AutoSwitchOrderType()` — Lit l'UI, modifie `CurrentTypeIndex`/`CurrentDirection`. ⚠️ Ne peut PAS appeler `UpdateUIMode()` (qui est dans `Panel_Main_Layout.mqh`). **Solution :** Retourner un `bool changed` et laisser le caller appeler `UpdateUIMode()`.
*   **Include requis :** `TradeCalc.mqh`, `TradeVisuals.mqh`, `../../GUI/GraphicWrappers.mqh`

**Transition :** Remplacer l'ancien `TradeLogic.mqh` par un fichier-agrégateur :
```cpp
// TradeLogic.mqh (TRANSITION - redirige vers les nouveaux fichiers)
#ifndef _TRADE_LOGIC_MQH_
#define _TRADE_LOGIC_MQH_
#include "TradeLogic/TradeCalc.mqh"
#include "TradeLogic/TradeVisuals.mqh"
#include "TradeLogic/TradeUIInteraction.mqh"
#endif
```
**Vérification :** Compile MT4 ✅, Compile MT5 ✅. Comportement identique.

#### ✅ [TERMINÉ] ÉTAPE 4 : Création `TradeErrorHandler.mqh`
**Localisation :** `Common/Core/Engine/TradeErrorHandler.mqh`
**Source :** `Trade_Execution.mqh` (lignes 15-46) : `HandleTradeError()`, `HandleTradeMessage()`.

**Action :** Migrer + enrichir :
```cpp
class TradeErrorHandler {
public:
   // Convertit un code d'erreur natif en TradeResult user-friendly
   static TradeResult FromBrokerError(int error, string context = "");
   
   // Mappe les RetCodes MT5 en messages lisibles
   static TradeResult FromMT5RetCode(uint retcode, string context = "");
   
   // Affiche un Toast dans la GUI (SEUL point de contact avec la GUI)
   static void ShowTradeToast(const TradeResult &result);
};
```
**Pourquoi une classe :** Permet le namespace et évite la pollution globale.
**Vérification :** Compile MT4 ✅, Compile MT5 ✅.

#### ✅ [TERMINÉ] ÉTAPE 5 : Centralisation Validation (`TradeValidator.mqh`)
**Localisation :** `Common/Core/Engine/TradeValidator.mqh`
**Source :** Fusion de la validation de `Trade_Manager.mqh::ExecuteOrder()` (lignes 16-113) ET partielle de `Handler_Trading.mqh`.

**Action :** Créer une classe statique avec 6 niveaux de validation :

| Niveau | Check | Source actuelle |
| :--- | :--- | :--- |
| **1** | **Input** | Price > 0 (Market: auto-fill Ask/Bid), Volume > 0, Symbol non-vide | Handler + Manager |
| **2** | **SL Logic** | SL correctement placé (Below for BUY, Above for SELL) via `ValidateSlDirection()` | Handler |
| **3** | **Risk** | RiskPercent <= MaxRiskPercent — Calcul indépendant du mode (%, Currency, R) | Manager (lignes 68-84) |
| **4** | **Broker Rules** | MinLot <= Volume <= MaxLot, LotStep normalization | Manager (lignes 87-92) |
| **5** | **Market** | MarginRequired < FreeMargin (avec buffer 10%), Spread < MaxSpread, StopLevel check (SL/TP/Entry distance) | Manager + Execution (lignes 73-108) |
| **6** | **Permission** | `IsTradeAllowed()`, `IsExpertEnabled()`, `AccountLogin != 0`, `LicenseState == LICENSE_OK` | Manager (lignes 19-34) + Handler (lignes 9-16) |

**Signature :**
```cpp
class TradeValidator {
public:
   // Retourne TradeResult.Success = true si tout est OK, sinon un TradeResult avec message d'erreur détaillé
   static TradeResult Validate(const TradeRequest &req);
};
```
**⚠️ IMPORTANT pour MT5 :** Le check `MODE_MARGINREQUIRED` actuel ne fonctionne pas en MT5 (`Compatibility.mqh` retourne 0). → Utiliser `OrderCalcMargin()` pour MT5 avec un `#ifdef` :
```cpp
#ifdef __MQL5__
   double marginNeeded = 0;
   if(!OrderCalcMargin((ENUM_ORDER_TYPE)req.Type, req.Symbol, req.Lots, req.Price, marginNeeded))
      return MakeErrorResult(0, TRADE_ERR_MARGIN, "Cannot calculate margin");
   marginNeeded *= 1.10; // Safety buffer
#else
   double marginNeeded = MarketInfo(req.Symbol, MODE_MARGINREQUIRED) * req.Lots * 1.10;
#endif
```
**Vérification :** Compile MT4 ✅, Compile MT5 ✅.

---

### PHASE 3 : IMPLÉMENTATION MOTEUR ROBUSTE

#### ✅ [TERMINÉ] ÉTAPE 6 : Robustesse complète `TradeEngineMT4.mqh`
**Localisation :** `MT4/Engine/TradeEngineMT4.mqh`

**CRITIQUE :** Le code actuel est NAÏF. Il faut importer TOUTE la logique de `Trade_Execution.mqh`.

**Pour `OpenMarket` et `OpenPending` :**
1. Boucle `for(i=0; i<MAX_RETRIES)`.
2. Check `IsTradeContextBusy()` + `Sleep(RETRY_DELAY)`.
3. `RefreshRates()` + Re-fetch prix (Ask/Bid) avant chaque tentative.
4. `NormalizeDouble(price, digits)`.
5. StopLevel validation (pré-check interne).
6. Mapping résultat `OrderSend` vers `TradeResult` via `TradeErrorHandler`.
7. Erreurs retryables : 135, 136, 137, 138, 146.

**Pour `Close` :** (Source : `SafeOrderClose` lignes 127-156)
1. `RefreshRates()` + `OrderSelect` + re-fetch close price.
2. Boucle retry.
3. Retour `TradeResult`.

**Pour `Modify` :** (Source : `SafeOrderModify` lignes 158-187)
1. Check `IsTradeContextBusy()`.
2. Erreur 1 = "no changes" → `TradeResult.Success = true`.
3. Boucle retry.

**Pour `Delete` :** (Source : `SafeOrderDelete` lignes 189-216)
1. Check `IsTradeContextBusy()`.
2. Boucle retry.

**Constantes :** `MAX_RETRIES = 3`, `RETRY_DELAY = 100` définies localement dans la classe (private members), plus besoin de `Trade_Constants.mqh`.

#### ✅ [TERMINÉ] ÉTAPE 7 : Enrichissement `TradeEngineMT5.mqh`
**Localisation :** `MT5/Engine/TradeEngineMT5.mqh`

Le code actuel est DÉJÀ bon pour l'essentiel.
**À ajouter :**
1. Mapper `CTrade::ResultRetcode()` vers `TradeResult` via `TradeErrorHandler::FromMT5RetCode()`.
2. Pour `Close` : Le partial close via `MqlTradeRequest` directe est OK, mais wrapper le résultat en `TradeResult`.

**Vérification :** Compile MT5 ✅.

---

### PHASE 4 : INTELLIGENCE & ORCHESTRATION

#### ✅ [TERMINÉ] ÉTAPE 8 : L'Orchestrateur (`TradeOrchestrator.mqh`)
**Localisation :** `Common/Core/Engine/TradeOrchestrator.mqh`
**Source principale :** `Trade_Manager.mqh::ExecuteOrder()` (lignes 16-156) est de facto l'orchestrateur actuel.

**Pattern :**
```cpp
class TradeOrchestrator {
public:
   // Point d'entrée unique pour OUVRIR un trade
   static TradeResult Execute(TradeRequest &req) {
      // 1. Validation complète
      TradeResult valResult = TradeValidator::Validate(req);
      if(!valResult.Success) return valResult;
      
      // 2. Select Engine
      if(CheckPointer(g_TradeEngine) == POINTER_INVALID) {
         return MakeErrorResult(0, TRADE_ERR_UNKNOWN, "Engine not initialized!");
      }
      
      // 3. Execution
      TradeResult res;
      if(req.Type == OP_BUY || req.Type == OP_SELL)
         res = g_TradeEngine.OpenMarket(req.Symbol, req.Type, req.Lots, req.Price,
                                         req.SL, req.TP, req.Comment, req.Magic);
      else
         res = g_TradeEngine.OpenPending(req.Symbol, req.Type, req.Lots, req.Price,
                                          req.SL, req.TP, req.Comment, req.Magic, req.Expiration);
      
      // 4. Return (Pas de Toast ici ! Le Handler s'en occupe)
      return res;
   }
   
   // Helpers pour les opérations sur positions existantes
   static TradeResult ClosePosition(long ticket, double lots, string comment) {
      if(CheckPointer(g_TradeEngine) == POINTER_INVALID)
         return MakeErrorResult(0, TRADE_ERR_UNKNOWN, "Engine not initialized!");
      return g_TradeEngine.Close(ticket, lots, comment);
   }
   
   static TradeResult ModifyPosition(long ticket, double sl, double tp) {
      if(CheckPointer(g_TradeEngine) == POINTER_INVALID)
         return MakeErrorResult(0, TRADE_ERR_UNKNOWN, "Engine not initialized!");
      return g_TradeEngine.Modify(ticket, sl, tp);
   }
   
   static TradeResult DeleteOrder(long ticket) {
      if(CheckPointer(g_TradeEngine) == POINTER_INVALID)
         return MakeErrorResult(0, TRADE_ERR_UNKNOWN, "Engine not initialized!");
      return g_TradeEngine.Delete(ticket);
   }
};
```
**⚠️ KEY DECISION :** L'Orchestrateur gère aussi `Close`, `Modify`, `Delete` en plus de `Execute`. Cela permet à `Handler_PositionActions.mqh` de passer par l'Orchestrateur plutôt que d'appeler le moteur directement (meilleure traçabilité).

---

### PHASE 5 : LA MIGRATION (LE "SWITCH")

#### ✅ [TERMINÉ] ÉTAPE 9 : Refonte `Handler_Trading.mqh`
**Localisation :** `Common/GUI/Events/Handlers/Handler_Trading.mqh`

**Action :**
1. **SUPPRIMER** toute la validation métier dupliquée (SL check, Risk check, MaxRisk, LotSize, SL Direction) → Cette logique est maintenant dans `TradeValidator`.
2. **GARDER** uniquement le feedback UX immédiat (champs vides → message spécifique).
3. Construire `TradeRequest` depuis l'UI.
4. Appeler `TradeOrchestrator::Execute(req)`.
5. Lire `TradeResult` :
    *   Si **Success** : Reset UI (Edit_SL, Edit_TP, Edit_Risk, Edit_Price → "0"), `UpdateChartLines()`, `UpdateOpenOrderLines()`, `UpdateCalculatedLot()`, jouer un son succès.
    *   Si **Échec** : `TradeErrorHandler::ShowTradeToast(result)`.

**Pattern simplifié :**
```cpp
if(sparam == PREFIX + "Btn_Buy" && CurrentTypeIndex == 0)
{
   EffectButton(sparam);
   HideValidationError();
   
   TradeRequest req;
   req.Symbol = FP_ObjectGetString(0, PREFIX + "Btn_SymbolSelect", OBJPROP_TEXT);
   if(req.Symbol == "") req.Symbol = Symbol();
   req.Type = OP_BUY;
   req.Price = MarketInfo(req.Symbol, MODE_ASK);
   req.SL = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_SL", OBJPROP_TEXT));
   req.TP = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_TP", OBJPROP_TEXT));
   req.Lots = StringToDouble(FP_ObjectGetString(0, PREFIX + "Edit_Lot", OBJPROP_TEXT));
   req.Comment = "FantomePad";
   req.Magic = MagicNumber;
   req.Expiration = 0;
   
   TradeResult result = TradeOrchestrator::Execute(req);
   
   if(result.Success) {
      ResetTradeUI();  // Fonction helper à créer
      UpdateChartLines();
      UpdateOpenOrderLines();
      UpdateCalculatedLot();
   } else {
      ShowValidationError(result.Message);
   }
   return true;
}
```

#### ✅ [TERMINÉ] ÉTAPE 10 : Refonte `Handler_PositionActions.mqh` (Partial Close / Modify / Delete)
**Localisation :** `Common/GUI/Events/Handlers/Handler_PositionActions.mqh`

**Important :** Conserver intacte la logique de calcul de pourcentage (25%, 50%, 100%, BE).

**Action :**
1. Remplacer `SafeOrderClose(...)` par `TradeOrchestrator::ClosePosition(ticket, lots, "Partial Close")`.
2. Remplacer `SafeOrderModify(...)` par `TradeOrchestrator::ModifyPosition(ticket, sl, tp)`.
3. Remplacer `SafeOrderDelete(...)` par `TradeOrchestrator::DeleteOrder(ticket)`.
4. Lire les `TradeResult` retournés pour afficher les erreurs via `ShowPosValidationError(result.Message)`.

#### ✅ [TERMINÉ] ÉTAPE 11 : Mise à jour de `Trade_Stubs.mqh` (MT5 Temporaire)
**Localisation :** `MT5/Trade/Trade_Stubs.mqh`

**Action :** Adapter les stubs pour utiliser les nouvelles signatures `TradeResult` OU supprimer si plus utilisé (car `Handler_PositionActions` passe maintenant par l'Orchestrateur).
**⚠️ Vérifier :** Si quelque chose appelle encore `ExecuteOrder()`, `SafeOrderClose()`, etc. directement. Si oui, les stubs doivent router vers `TradeOrchestrator`.

---

### PHASE 6 : MISE À JOUR DU BRIDGE

#### ✅ [TERMINÉ] ÉTAPE 12 : Nettoyage de `Bridge.mqh`
**Action :**
1. Supprimer l'import de `MT4/Trade/Trade.mqh` et `MT5/Trade/Trade_Stubs.mqh`.
2. Ajouter les imports du nouveau système :
```cpp
// New Engine System
#include "Common/Core/Engine/TradeErrorHandler.mqh"
#include "Common/Core/Engine/TradeValidator.mqh"
#include "Common/Core/Engine/TradeOrchestrator.mqh"
```
3. L'import des Engine Implementations MT4/MT5 reste inchangé.

**Vérification :** Compile MT4 ✅, Compile MT5 ✅.

---

### PHASE 7 : NETTOYAGE & VALIDATION

#### ✅ [TERMINÉ] ÉTAPE 13 : Suppression de l'ancien `TradeLogic.mqh` monolithique
**Action :** Supprimer le fichier-agrégateur de transition créé à l'étape 3. Mettre à jour tous les `#include` qui pointaient vers `TradeLogic.mqh` pour pointer vers les trois sous-fichiers.

#### ✅ [TERMINÉ] ÉTAPE 14 : Checkpoint Compatibilité MT5
**Action :**
1. Vérifier que `Compatibility.mqh` couvre tous les appels faits par les nouveaux fichiers.
2. Fix critique : Implémenter `MODE_MARGINREQUIRED` correctement pour MT5 dans `Compatibility.mqh` :
```cpp
case 0: // MODE_MARGINREQUIRED placeholder
{
   double margin = 0;
   if(OrderCalcMargin(ORDER_TYPE_BUY, symbol, 1.0, SymbolInfoDouble(symbol, SYMBOL_ASK), margin))
      return margin;
   return 0.0;
}
```
**Note :** `UpdateOpenOrderLines()` devra être enrichi pour MT5 (gestion des ordres pendants séparés). → Ticket technique à créer, hors scope de cette restructuration moteur.

#### ✅ ÉTAPE 15 : Suppression du Legacy (Clean-up)
**Backup complet du dossier avant suppression !**
**Supprimer :**
*   `MT4/Trade/` entier (`Trade.mqh`, `Trade_Constants.mqh`, `Trade_Execution.mqh`, `Trade_Calculations.mqh`, `Trade_Lines.mqh`, `Trade_Manager.mqh`).
*   `MT5/Trade/Trade_Stubs.mqh`.
*   `Handler_SymbolManager 2.mqh` (doublon).
*   L'ancien `Common/Core/TradeLogic.mqh` (si pas déjà fait à l'étape 13).
*   Mettre à jour `Bridge.mqh` pour supprimer tous les `#include` legacy.

#### ✅ ÉTAPE 16 : Validation Compilation
*   Compile MT4 : 0 Error, 0 Warning.
*   Compile MT5 : 0 Error, 0 Warning.

#### ✅ ÉTAPE 17 : Validation Runtime
**Test MT4 (sur compte démo) :**
1. Ouvrir un Market Order (Buy) → Vérifier SL/TP positionnés, ticket retourné.
2. Ouvrir un Pending Order (Buy Limit) → Vérifier placement.
3. Modifier SL/TP d'un trade ouvert → Vérifier modification.
4. Partial Close 50% → Vérifier le volume restant.
5. Close 100% → Vérifier suppression.
6. Tester sans SL → Doit être REJETÉ.
7. Tester avec Risk > MaxRisk → Doit être REJETÉ.
8. Tester prix = 0 → Doit prendre le Ask/Bid actuel.

**Test MT5 (si disponible) :**
1. Mêmes tests que MT4.

---

## 4. CHECK-LIST SÉCURITÉ CAPITALE (À vérifier dans le code final)

| # | Check | Responsable | Fichier |
| :--- | :--- | :--- | :--- |
| 1 | 🔴 **Stop Loss Obligatoire :** Le système rejette-t-il un ordre Market sans SL ? | `TradeValidator` | `TradeValidator.mqh` |
| 2 | 🔴 **Risque Max :** Si risque > MaxRiskPercent, le système bloque-t-il ? | `TradeValidator` | `TradeValidator.mqh` |
| 3 | 🔴 **Prix Vide :** Si prix = 0 pour Market, le système utilise-t-il Ask/Bid actuel ? | `TradeOrchestrator` ou `Handler` | `Handler_Trading.mqh` |
| 4 | 🔴 **Busy Context :** Boucle de retry activée uniquement sur MT4 ? | `TradeEngineMT4` | `TradeEngineMT4.mqh` |
| 5 | 🔴 **Margin Check :** Vérification marge suffisante (avec buffer 10%) avant exécution ? | `TradeValidator` + `TradeEngineMT4` | Les deux |
| 6 | 🔴 **StopLevel :** SL/TP/Entry respectent la distance minimale du broker ? | `TradeValidator` | `TradeValidator.mqh` |
| 7 | 🔴 **Spread :** Spread actuel < MaxSpread avant exécution Market ? | `TradeValidator` | `TradeValidator.mqh` |
| 8 | 🔴 **Lot Normalization :** Volume arrondi à LotStep, entre MinLot et MaxLot ? | `TradeValidator` | `TradeValidator.mqh` |
| 9 | 🟡 **Pas de Toast dans Engine :** L'Engine **NEVER** touche la GUI | Audit code | `TradeEngineMT4/MT5.mqh` |
| 10 | 🟡 **Pas de validation dupliquée :** Handler ne refait PAS ce que Validator fait | Audit code | `Handler_Trading.mqh` |

---

## 5. RÉSUMÉ DES FICHIERS À CRÉER / MODIFIER / SUPPRIMER

| Action | Fichier | Détail |
| :--- | :--- | :--- |
| ✏️ **MODIFIER** | `DataTypes.mqh` | Ajouter `TradeRequest`, `TradeResult`, Enum, Helpers |
| ✏️ **MODIFIER** | `ITradeEngine.mqh` | Signatures → `TradeResult` |
| ✏️ **MODIFIER** | `TradeEngineMT4.mqh` | Intégrer robustesse complète (Busy/Retry/Margin) |
| ✏️ **MODIFIER** | `TradeEngineMT5.mqh` | Mapper vers `TradeResult` |
| ✏️ **MODIFIER** | `Handler_Trading.mqh` | Simplifier → `TradeRequest` → `Orchestrator` |
| ✏️ **MODIFIER** | `Handler_PositionActions.mqh` | `SafeOrder`* → `Orchestrator` |
| ✏️ **MODIFIER** | `Bridge.mqh` | Supprimer imports legacy, ajouter nouveaux |
| ✏️ **MODIFIER** | `Compatibility.mqh` | Fix `MODE_MARGINREQUIRED` pour MT5 |
| 🆕 **CRÉER** | `TradeLogic/TradeCalc.mqh` | Math pure extraite de `TradeLogic.mqh` |
| 🆕 **CRÉER** | `TradeLogic/TradeVisuals.mqh` | Lignes graphiques extraites de `TradeLogic.mqh` |
| 🆕 **CRÉER** | `TradeLogic/TradeUIInteraction.mqh` | Interaction UI extraite de `TradeLogic.mqh` |
| 🆕 **CRÉER** | `Engine/TradeValidator.mqh` | Validation centralisée (6 niveaux) |
| 🆕 **CRÉER** | `Engine/TradeOrchestrator.mqh` | Contrôleur unique |
| 🆕 **CRÉER** | `Engine/TradeErrorHandler.mqh` | Formatage erreurs |
| 🗑️ **SUPPRIMER** | `MT4/Trade/*` | Tout le dossier legacy |
| 🗑️ **SUPPRIMER** | `MT5/Trade/Trade_Stubs.mqh` | Plus nécessaire |
| 🗑️ **SUPPRIMER** | `Common/Core/TradeLogic.mqh` | Remplacé par dossier `TradeLogic/` |
| 🗑️ **SUPPRIMER** | `Handler_SymbolManager 2.mqh` | Doublon |