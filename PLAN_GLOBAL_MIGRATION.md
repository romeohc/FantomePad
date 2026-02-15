# PLAN GLOBAL : MIGRATION FANTOMEPAD (SCALABLE & UNIFIED)

**Objectif :** Transformer FantomePad en une solution Multi-Plateforme (MT4 & MT5) via une architecture professionnelle "Single Source of Truth".  
**Vision :** Une seule base de code. Zéro duplication. Maintenance instantanée sur les deux plateformes.
**Destinataire :** AI Architect / Lead Developer.

---

## 🏗 ARCHITECTURE CIBLE : LE MODÈLE "H.A.L."
Nous n'allons pas "porter" le code. Nous allons construire une **Hardware Abstraction Layer (HAL)**.
Le code logique de FantomePad (stratégie, interface) ne doit **JAMAIS** parler directement à MetaTrader. Il doit parler à notre couche d'abstraction, qui elle, traduira pour MT4 ou MT5.

### Structure des Dossiers Cible
- `Common/` : Tout le code pur (Maths, Couleurs, Logique GUI, JSON, Logique Métier). **100% Compatible.**
- `Platform/MT4/` : Les "Drivers" spécifiques MT4 (OrderSend, OrderSelect, MarketInfo).
- `Platform/MT5/` : Les "Drivers" spécifiques MT5 (MqlTradeRequest, PositionSelect, SymbolInfoDouble).
- `Platform/Bridge.mqh` : Le fichier magique qui détecte la plateforme et charge le bon Driver.

---

## 📅 PHASES D'EXÉCUTION V3.0 (ZERO RISK & ABSTRACTION TOTALE)
**Philosophie :** "Abstraction Totale". Le code commun ne doit JAMAIS savoir sur quelle plateforme il tourne. Ni pour les ordres, ni pour les dessins.

### PHASE 0 : RESTRUCTURATION (Validée ✅)
Architecture en place. Les fondations sont saines.

### PHASE 1 : LA FONDATION DE DONNÉES (DTO - Le Socle)
**But :** Parler la même langue mathématique.
- [ ] Créer `Common/Core/DataTypes.mqh` : Introduire `struct FantomeTrade` (standardise un ordre/position) et `struct FantomeAccount`.
- [ ] Créer `MT4/Wrappers/Data_Wrapper.mqh` : Remplit ces structures depuis `OrderSelect`.
- [ ] Créer `MT5/Wrappers/Data_Wrapper.mqh` : Remplit ces structures depuis `PositionSelect` (Stub pour l'instant).
- [ ] **Action Clé :** Remplacer TOUS les appels `OrderOpenPrice()` dans le GUI par `Trade.Price`.

### PHASE 1.5 : L'ABSTRACTION GRAPHIQUE (GUI HAL - Nouveau Critique)
**But :** Parler la même langue visuelle et éviter les bugs d'objets sur MT5.
- [ ] Créer `Common/GUI/GraphicWrappers.mqh`.
- [ ] Définir `FP_ObjectCreate`, `FP_ObjectSetInteger`, `FP_ObjectGetInteger`.
- [ ] **MT4** : Mappe vers les fonctions natives.
- [ ] **MT5** : Mappe vers les fonctions natives (permettra d'injecter des corrections spécifiques sans toucher au GUI).
- [ ] **Refactor :** `Components.mqh` doit utiliser `FP_ObjectCreate` au lieu de `ObjectCreate`.
- [x] Extraire la Logique Pure (TradeLogic.mqh)
    - [x] Isoler `AutoSwitchOrderType` et calculs de risque
    - [x] Vérifier qu'aucun appel `OrderSend` ne reste dans le GUI
- [x] **Implémentation Stubs MT5 (Nouveau)**
    - [x] Créer `Platform/MT5/Trade/Trade_Stubs.mqh`
    - [x] Simuler `ExecuteOrder` et fonctions de sécurité pour permettre la compilation du GUI avant la Phase 3. **Note Importante:** Le moteur d'exécution MT5 est actuellement une coquille vide pour valider l'architecture.

### Phase 2 : Sécurité & Authentification (Supabase)UTHENTIFICATION
**But :** Un passeport universel.
- [ ] Adapter `Security.mqh` pour utiliser une classe `C_HttpManager` (Wrapper de `WebRequest`).
- [ ] Gérer les différences de headers HTTP entre MT4 et MT5 via ce Wrapper.

### PHASE 3 : LE MOTEUR D'EXÉCUTION (L'Action)
**But :** Exécuter sans réfléchir.
- [ ] Créer l'interface `ITradeEngine` (virtuelle).
- [ ] Implémenter `C_TradeEngineMT4` (Basé sur le code actuel).
- [ ] Implémenter `C_TradeEngineMT5` (Utilisant `MqlTradeRequest` et `OrderSend` MT5).
- [ ] Le `Bridge.mqh` instancie le bon moteur au démarrage.

### PHASE 4 : LA GESTION D'ÉTAT (Le Cerveau)
**But :** Centraliser la vérité et fluidifier le rendu.
- [ ] Créer `C_OrderManager` (Singleton en Common).
- [ ] Il boucle (Polling) et met à jour une liste `FantomeTrade[]`.
- [ ] Le GUI ne fait **plus aucun appel** à `OrdersTotal()`. Il lit juste `C_OrderManager.Trades`.
- [ ] **Avantage :** Performance extrême (60 FPS), zéro lag système dans la boucle graphique.

### PHASE 5 : L'INTERFACE UTILISATEUR (Le Rendu)
**But :** Afficher sans bug.
- [ ] Compiler le GUI sur MT5.
- [ ] Corriger les événements souris (`CHARTEVENT_MOUSE_MOVE` vs `CHARTEVENT_MOUSE`).
- [ ] Ajuster les décalages de pixels (MT5 a des polices légèrement différentes).

### PHASE 6 : VALIDATION FINALE & OPTIMISATION
- [ ] Tests croisés intenses.
- [ ] Optimisation du code (inlining, gestion mémoire).
- [ ] Packaging : Générateur d'installeur unique.
