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

## 🚧 PROCHAINE ÉTAPE : PHASE 3 (LE MOTEUR D'EXÉCUTION)

**État Actuel :** 
- Le GUI compile et s'affiche sur MT5.
- Les boutons "Achat/Vente" appellent des fonctions vides (`ExecuteOrder` dans `Trade_Stubs.mqh`).
- **Objectif :** Remplacer les Stubs par un vrai moteur d'exécution MT5.

**Plan d'Action Phase 3 :**
1.  **Supprimer `Trade_Stubs.mqh`** de `Bridge.mqh`.
2.  **Activer `Trade_Execution.mqh`** (actuellement désactivé/revert). 
3.  **Implémenter le moteur MT5 :**
    - Utiliser la librairie standard `CTrade` pour la robustesse.
    - Gérer les `MqlTradeRequest` et `MqlTradeResult`.
    - Mapper les retours d'erreurs MT5 vers le système de Toast du GUI.
    - Gérer les différences de "Position" vs "Ordre".
4.  **Validation :** Tester l'ouverture, la fermeture et la modification d'ordres sur un compte Démo MT5.

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
