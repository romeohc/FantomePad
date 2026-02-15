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

## 📅 PHASES D'EXÉCUTION V2.0 (INDUSTRIELLE & SCALABLE)
**Philosophie :** "Fail Fast". On doit détecter les incompatibilités MT5 le plus tôt possible, pas à la fin.

### PHASE 0 : RESTRUCTURATION (Validée ✅)
Architecture en place. Les fondations sont saines.

### PHASE 1 : ABSTRACTION DES DONNÉES & NORMALISATION (Le Socle)
**But :** Créer un langage commun universel structuré (DTO).
- [ ] Enrichir `Compatibility.mqh` avec les macros manquantes.
- [ ] **CRITIQUE :** Créer `Common/Core/DataTypes.mqh` contenant `struct FantomeTrade` (Id, Symbol, Type, Lots, Profit...).
- [ ] Créer `MT4/DataWrapper.mqh` : Une fonction qui remplit `FantomeTrade` depuis `OrderSelect`.
- [ ] Créer `MT5/DataWrapper.mqh` : Une fonction (stub) qui remplira `FantomeTrade` depuis `PositionSelect`.
- [ ] **TEST DE FEU :** Compiler tout le projet GUI sur MT5 dès maintenant (avec des stubs vides). Le GUI doit être compilable sur les deux plateformes avant d'aller plus loin.

### PHASE 2 : SÉCURITÉ & CONNECTIVITÉ
**But :** Le Passeport Universel.
- [ ] Adapter `Security.mqh` pour utiliser `WebRequest` de manière unifiée.
- [ ] Abstraire les accès fichiers (Token, Config) dans une classe `C_FileManager`.
- [ ] Validation : Le même code d'activation fonctionne sur MT4 et MT5.

### PHASE 3 : LE MOTEUR D'EXÉCUTION (Unifier l'Action)
**But :** Acheter et Vendre sans se soucier du moteur sous le capot.
- [ ] Créer une interface `ITradeEngine`.
- [ ] Implémenter `C_TradeEngineMT4` (Basé sur le code actuel).
- [ ] Implémenter `C_TradeEngineMT5` (Utilisant `MqlTradeRequest`).
- [ ] Le `Bridge.mqh` instancie le bon moteur au démarrage.

### PHASE 4 : LE CERVEAU (Gestion d'État & Ordres)
**But :** Le GUI ne regarde jamais `OrdersTotal()` directement.
- [ ] Créer `C_OrderManager` (Singleton en Common).
- [ ] Il maintient une liste `FantomeTrade[]` à jour via un Timer/Event.
- [ ] Le GUI lit uniquement cette liste propre (Zéro lag, Zéro appel système bloquant).
- [ ] **Avantage énorme :** On peut trier, filtrer ou simuler des ordres sans toucher au moteur MT.

### PHASE 5 : INTERFACE & UX (Finitions)
**But :** Adapter les subtilités graphiques.
- [ ] Ajuster la gestion des événements Souris (MT5 a plus d'événements que MT4).
- [ ] Vérifier le rendu des polices et des alignements (Pixel Perfect).

### PHASE 6 : VALIDATION CROISÉE
- [ ] Test de charge : 100 ordres ouverts.
- [ ] Test de crash : Coupure réseau, reconnexion.
- [ ] Packaging : Générateur d'installeur unique (détecte les terminaux installés).
