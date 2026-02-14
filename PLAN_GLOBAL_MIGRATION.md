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

## 📅 PHASES D'EXÉCUTION (SÉQUENTIEL & ÉTANCHE)

### PHASE 0 : RESTRUCTURATION (La Fondation)
**But :** Organiser le chaos avant de construire.
- Déplacer physiquement les fichiers existants dans la nouvelle architecture.
- Séparer ce qui est "Pur" (Common) de ce qui est "Pollué" (MT4 specific).
- **CRITÈRE DE SUCCÈS :** L'Expert Advisor compile **exactement** comme avant sur MT4. Aucune régression. Les fichiers sont juste ailleurs.

### PHASE 1 : ABSTRACTION DES DONNÉES (Le Vocabulaire)
**But :** Unifier la langue. MT4 dit `Bid`, MT5 dit `SymbolInfoDouble(..., SYMBOL_BID)`.
- Créer `Wrapper_Market.mqh` : `GetBid()`, `GetAsk()`, `GetPoint()`.
- Créer `Wrapper_Account.mqh` : `GetBalance()`, `GetEquity()`, `GetFreeMargin()`.
- Unifier les Constantes : Mapper `OP_BUY` (MT4) vers `ORDER_TYPE_BUY` (MT5).
- **CRITÈRE DE SUCCÈS :** Un script de test affiche les mêmes prix et solde sur MT4 et MT5.

### PHASE 2 : SÉCURITÉ & AUTH (Le Passeport)
**But :** Rendre l'authentification Supabase universelle.
- Adapter `Security.mqh`.
- Unifier `WebRequest` (Attention aux différences de timeout et headers).
- Unifier la lecture/écriture de fichiers (Token de licence).
- **CRITÈRE DE SUCCÈS :** Une licence valide sur MT4 est reconnue valide sur MT5 (même Hardware ID généré).

### PHASE 3 : MOTEUR D'EXÉCUTION (Le Moteur)
**But :** La partie la plus critique. Acheter et Vendre.
- Créer `TradeWrapper.mqh`.
- MT4 : Utilise `OrderSend` (simple).
- MT5 : Implémente une structure `MqlTradeRequest` complète (complexe).
- Gérer les "Retries" et les codes erreurs (Requotes vs Rejets).
- **CRITÈRE DE SUCCÈS :** 100 trades de test (Buy/Sell/Limit) exécutés sans erreur `10013` ou `10015` sur MT5.

### PHASE 4 : MÉMOIRE & ÉTAT (Le Cerveau)
**But :** Unifier la vision du passé (Historique) et du présent (Positions ouvertes).
- **Problème Majeur :** MT4 mélange "Positions" et "Ordres en attente". MT5 les sépare strictement.
- Créer `PositionsWrapper.mqh` : Une fonction `GetOpenPositions()` qui renvoie une liste unifiée.
- Créer `HistoryWrapper.mqh` : Abstraire `HistorySelect` (MT5) pour qu'il ressemble à l'accès direct de MT4.
- **CRITÈRE DE SUCCÈS :** Le Panel "Positions" et le Panel "History" affichent exactement les mêmes données (Profit, Swap, Date) sur les deux plateformes.

### PHASE 5 : INTERFACE & ÉVÉNEMENTS (La Peau)
**But :** Rendre le Pad réactif.
- Adapter `OnChartEvent` pour les différences Clavier/Souris.
- Vérifier le rendu graphique (les objets `OBJ_RECTANGLE_LABEL` se comportent parfois différemment au pixel près).
- **CRITÈRE DE SUCCÈS :** Le GUI est fluide, le Drag & Drop fonctionne, les clics sont détectés instantanément.

### PHASE 6 : NETTOYAGE & VALIDATION FINALE
- Supprimer tout code mort ou commenté "Legacy".
- Test de charge (Scalabilité).
- Validation finale "User Experience" (Le WAOUH effect).

---

**NOTE CRITIQUE POUR L'IA EXÉCUTANTE :**
Ne jamais mélanger deux phases. Si l'étape 3 (Execution) échoue, ne passez pas à l'étape 4 (History). La base doit être solide.
Utilisez toujours `#ifdef __MQL5__` pour isoler le code spécifique. Le fichier maître reste propre.
