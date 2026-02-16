# PLAN GLOBAL : MIGRATION FANTOMEPAD (SCALABLE & UNIFIED)

**Objectif :** Transformer FantomePad en une solution Multi-Plateforme (MT4 & MT5) via une architecture professionnelle "Single Source of Truth".  
**Vision :** Une seule base de code. Zéro duplication. Maintenance instantanée sur les deux plateformes.
**Destinataire :** AI Architect / Lead Developer.

---

## 🏗 ARCHITECTURE ACTUELLE : LE MODÈLE H.A.L. (Hardware Abstraction Layer)

Nous avons construit une **Hardware Abstraction Layer (HAL)** robuste.
Le code logique de FantomePad (stratégie, interface) ne parle **JAMAIS** directement à MetaTrader. Il parle à notre couche d'abstraction (`Compatibility.mqh` et Wrappers), qui elle, traduit pour MT4 ou MT5.

### Structure des Dossiers Actuelle
- `Common/` : Tout le code pur (Maths, Couleurs, Logique GUI, JSON, Logique Métier). **100% Compatible.**
- `Platform/MT4/` : Les "Drivers" spécifiques MT4 (OrderSend, OrderSelect, MarketInfo).
- `Platform/MT5/` : Les "Drivers" spécifiques MT5 (Wrappers, Stubs pour l'instant).
- `Platform/Bridge.mqh` : Le fichier magique qui détecte la plateforme et charge le bon Driver.

---

## 📅 ÉTAT D'AVANCEMENT DU PROJET (Mise à jour : Phase 3 - Prêt à démarrer)

### ✅ PHASE 0 : RESTRUCTURATION (Terminée)
- Architecture modulaire en place.
- Séparation stricte entre Logique Pure (`TradeLogic.mqh`) et Implémentation (`Bridge.mqh`).

### ✅ PHASE 1 : LA FONDATION DE DONNÉES (Terminée)
- **Abstraction des Données :** `Compatibility.mqh` gère le mapping des fonctions vitales (`OrderSelect`, `OrderOpenPrice`, etc.).
- **Abstraction Graphique :** `GUI_Master.mqh` et `Components.mqh` utilisent des wrappers ou des macros compatibles.
- **Support MT5 :** Le code compile sur MT5 grâce à ces abstractions.

### ✅ PHASE 1.5 : L'ABSTRACTION GRAPHIQUE (Terminée)
- **Wrappers Graphiques :** Les objets graphiques se créent et se modifient correctement sur les deux plateformes.
- **Événements :** La gestion des événements souris (`CHARTEVENT`) est unifiée dans `GUI_Master.mqh`.
- **Logique Pure :** `TradeLogic.mqh` est isolé et fonctionnel (calculs de lots, risques).
- **Stubs MT5 :** `Trade_Stubs.mqh` est en place pour permettre la compilation du GUI avant que le moteur de trading ne soit prêt.

### ✅ PHASE 2 : SÉCURITÉ & AUTHENTIFICATION (Validation Initiale)
- **Supabase :** L'authentification par licence fonctionne sur MT4 et MT5.
- **Interface Auth :** Le panneau de login s'affiche et réagit correctement sur les deux plateformes.

### 🚧 PHASE 2.5 : INDUSTRIALISATION I/O & HTTP (CRITIQUE)
**But :** Rendre le code Scalable et Maintenable (Recommandation Architecte).
- [ ] Créer `Common/Core/IO/HttpManager.mqh` : Classe `C_HttpManager` (Singleton) qui gère les Timeouts, Headers, et Codes Erreur unifiés (MT4/5).
- [ ] Créer `Common/Core/IO/FileManager.mqh` : Classe `C_FileManager` (Static) pour lire/écrire des JSON/Txt de manière sécurisée (Flags partagés).
- [ ] **REFACTORING :** Réécrire `Security.mqh` pour qu'il n'utilise QUE `C_HttpManager` et `C_FileManager`.
- [ ] **Validation :** Le même code d'activation fonctionne sur MT4 et MT5 sans `#ifdef` sales.

---

## 🚧 PROCHAINE ÉTAPE : PHASE 3 (LE MOTEUR D'EXÉCUTION UNIFIÉ)
**But :** Acheter et Vendre sans que le GUI sache si on est sur MT4 ou MT5.

### ÉTAPE 3.1 : L'INTERFACE COMMUNE (Le Contrat)
- [ ] Créer `Common/Core/Engine/ITradeEngine.mqh` : Interface pure (`virtual`) définissant les méthodes `OpenMarket`, `OpenPending`, `Modify`, `Close`, `Delete`.
- [ ] Utiliser exclusivement les types `FantomeTrade` (DTO) pour les paramètres.

### ÉTAPE 3.2 : IMPLÉMENTATION MT4 (Le Legacy)
- [ ] Créer `MT4/Engine/TradeEngineMT4.mqh` qui implémente `ITradeEngine`.
- [ ] Migrer le code existant de `Trade_Execution.mqh` vers cette classe.

### ÉTAPE 3.3 : IMPLÉMENTATION MT5 (Le Moderne)
- [ ] Créer `MT5/Engine/TradeEngineMT5.mqh` qui implémente `ITradeEngine`.
- [ ] Utiliser la classe standard `CTrade` (`#include <Trade/Trade.mqh>`) pour gérer les ordres MT5 de manière robuste.
- [ ] Taper dans `MqlTradeRequest` et mapper les retours vers le format unifié.

### ÉTAPE 3.4 : L'INJECTION DE DÉPENDANCE (Le Bridge)
- [ ] Modifier `Bridge.mqh` pour instancier le bon moteur (`C_TradeEngineMT4` ou `MT5`) au démarrage.
- [ ] Rendre ce moteur accessible via un Singleton ou une Variable Globale `g_TradeEngine`.
- [ ] Connecter les boutons du GUI (Achat/Vente) à `g_TradeEngine.OpenMarket(...)`.

---

### 🔮 PHASES FUTURES (Post-Trading)

### PHASE 4 : LA GESTION D'ÉTAT (Le Cerveau)
**But :** Centraliser la vérité et fluidifier le rendu.
- [ ] Créer `C_OrderManager` (Singleton en Common).
- [ ] Il boucle (Polling) et met à jour une liste `FantomeTrade[]`.
- [ ] Le GUI ne fait **plus aucun appel** à `OrdersTotal()`. Il lit juste `C_OrderManager.Trades`.
- [ ] **Avantage :** Performance extrême (60 FPS), zéro lag système dans la boucle graphique.

### PHASE 5 : OPTIMISATION UX/UI
**But :** Finition parfaite.
- [ ] Ajuster les décalages de pixels (MT5 a des polices légèrement différentes).
- [ ] Optimiser la réactivité des graphiques (FPS).

### PHASE 6 : VALIDATION FINALE & PACKAGING
- [ ] Tests croisés intenses (Stress Test).
- [ ] Générateur d'installeur unique pour les clients.
