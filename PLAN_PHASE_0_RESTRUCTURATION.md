# PLAN PHASE 0 : RESTRUCTURATION MAJEURE (FONDATIONS)

**Objectif :** Déplacer toute la logique existante dans un contexte multi-plateforme sans casser l'exécutable MT4 actuel.
**Risque :** Moyen (chemins d'include, variables globales).
**Critère de Succès Obligatoire :** `fantomepad.mq4` doit compiler avec **0 erreur** et **0 warning**.

---

## 🏗 DÉTAIL DES OPÉRATIONS (SÉCURITÉ MAXIMALE)

### ÉTAPE 1 : CRÉER LES COMPARTIMENTS
- `/Include/FantomePad/Platform/`
- `/Include/FantomePad/Platform/Common/` (Code Pur : Maths, GUI, JSON, Utils)
- `/Include/FantomePad/Platform/MT4/Trade/` (Code Impur : Ordres, Positions)
- `/Include/FantomePad/Platform/MT5/` (Stubs Vides)
- `/Include/FantomePad/Platform/Bridge.mqh` (Le Connecteur Intelligent)

> **Règle d'Or :** Les dossiers actuels (`Core`, `GUI`, `Trade`) seront vidés de leur substance. Tout sera redirigé.

### ÉTAPE 2 : DÉPLACER LES "INVARIANTS" (SAFE TO MOVE)
Ces fichiers ne dépendent pas de la plateforme. Ils bougent directement dans `Platform/Common/`.
1.  **Cibles :**
    - `Core/Defines.mqh` → `Platform/Common/Core/Defines.mqh`
    - `Core/Config.mqh` → `Platform/Common/Core/Config.mqh`
    - `GUI/GUI_Master.mqh` et tous ses sous-dossiers → `Platform/Common/GUI/`

2.  **Raison :** Le GUI dessine des rectangles. Un rectangle est un rectangle sur MT4 et MT5.
    - **Note :** Le GUI contient des appels à `PositionsTotal()` ou `OrderSelect()`. Ce n'est pas grave : tant qu'on compile sur MT4, ils trouveront leur chemin. Plus tard, on injectera un Wrapper.

### ÉTAPE 3 : ISOLER LA LOGIQUE MÉTIER "DIFFICILE" (UNSAFE)
Le Trading Engine est spécifique. On le met dans sa cage MT4.
1.  **Cibles :**
    - `Trade/Trade_Execution.mqh` → `Platform/MT4/Trade/Trade_Execution.mqh`
    - `Trade/Trade_Lines.mqh` → `Platform/MT4/Trade/Trade_Lines.mqh`
    - Tous les autres ficheirs de `Trade/` → `Platform/MT4/Trade/`

2.  **Création du Pont (`Bridge.mqh`) :**
    Ce fichier sera le SEUL point d'entrée pour le Trading.
    ```cpp
    #ifdef __MQL4__
       #include "MT4/Trade/Trade_Execution.mqh"
       // ... autres includes MT4
    #else
       // #include "MT5/Trade_Wrapper.mqh" (Futur)
    #endif
    ```

### ÉTAPE 4 : METTRE À JOUR LE FICHIER MAÎTRE (`fantomepad.mq4`)
On ne touche pas à la logique interne. On change juste les adresses.
- Remplacer les `#include "Include/FantomePad/Core/..."` par les nouveaux chemins `Platform/...`.
- Ajouter l'appel au `Bridge.mqh`.

### ÉTAPE 5 : LE TEST CRITIQUE (MT4)
- Compiler `fantomepad.mq4`.
- **SI ERREUR :** Rollback immédiat.
- **SI SUCCÈS :** La Phase 0 est validée. On a une structure prête pour accueillir MT5 sans avoir cassé MT4.

### ÉTAPE 6 : PRÉPARER LE FUTUR FICHIER MT5
- Créer `fantomepad.mq5`.
- Contenu initial :
  ```cpp
  // Point d'entrée MT5 - Clone de la structure
  #include "fantomepad.mq4"
  ```
- **Note :** Ce fichier ne compilera PAS encore (c'est normal, il manquera les traductions). Mais il existera.

---

**CONSIGNE POUR L'IA EXÉCUTANTE :**
Ne faites **AUCUNE** modification de code à l'intérieur des fichiers déplacés pour l'instant (sauf ajustement de chemins `#include` relatifs si nécessaire). Contentez-vous de déplacer et de relier.
La priorité absolue est la **continuité de service sur MT4**.
