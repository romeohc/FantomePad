# FantomePad Project - Documentation Technique pour IA & Développeurs

## 1. Contexte du Projet
**FantomePad** est une solution complète écrite en **MQL4** visant à moderniser radicalement l'expérience de trading sur **MetaTrader 4**.
Le but est de remplacer l'interface native (vieillissante et peu ergonomique) par une interface graphique (GUI) moderne, esthétique ("Deep Dark Theme"), et fonctionnelle, permettant de tout gérer depuis le graphique : prise de position, calcul de lots, gestion des risques et configuration.

## 2. Architecture du Système

Le projet a été restructuré d'un fichier monolithique vers une architecture modulaire pour assurer la maintenabilité et l'extensibilité.

### Structure des Fichiers
```text
/Users/romeohc/Downloads/MagicKey/
├── magikey.mq4                 # [ENTRY POINT] Point d'entrée principal unique.
├── README.md                   # Ce fichier de documentation.
└── Include/
    └── MagicKey/               # [CORE LOGIC] Toute la logique réside ici.
        ├── Defines.mqh         # Variables globales, Inputs, Constantes, Couleurs.
        ├── Config.mqh          # Système de persistance (Save/Load configuration to file).
        ├── Trade.mqh           # Moteur de trading (Calculs de lots, OrderSend, Gestion Lignes Graphique).
        └── GUI/                # [INTERFACE] Gestion visuelle.
            ├── GUI_Master.mqh  # [CONTROLLER] Chef d'orchestre des événements et de l'initialisation.
            ├── Components.mqh  # [LIBRARY] Primitives graphiques (CreateButton, CreateRect, etc.).
            ├── Panel_Main.mqh  # [VIEW] Logique du Panneau Principal (Trading).
            ├── Panel_Settings.mqh # [VIEW] Logique du Panneau de Configuration.
            ├── Panel_Info.mqh  # [VIEW] (Squelette) Futur panneau d'informations (Balance/Equity).
            └── Panel_Manager.mqh # [VIEW] (Squelette) Futur panneau de gestion de positions.
```

---

## 3. Détail des Modules

### A. Point d'Entrée : `magikey.mq4`
C'est le seul fichier exécutable par MT4.
- **Rôle** : Initialiser l'environnement (Chart settings), charger la config, et déléguer immédiatemment le contrôle.
- **Fonctions Clés** :
    - `OnInit()` : Appelle `InitGlobals()`, `LoadConfig()`, et `GUI_OnInit()`.
    - `OnTick()` : Appelle `UpdateOpenOrderLines()` (Trade.mqh) et met à jour les calculs.
    - `OnChartEvent()` : Redirige **tous** les événements vers `GUI_OnChartEvent()` (GUI_Master.mqh).

### B. Configuration : `Defines.mqh` & `Config.mqh`
- **`Defines.mqh`** : Contient tous les `input` (paramètres utilisateur), les constantes de couleurs, et les états globaux (`CurrentTypeIndex`, `IsSettingsOpen`). C'est la "mémoire" partagée du système.
- **`Config.mqh`** : Gère la lecture/écriture d'un fichier texte pour sauvegarder les préférences utilisateur (couleurs, risque par défaut) de manière persistante.

### C. Moteur de Trading : `Trade.mqh`
Ce module est "aveugle" aux interactions souris, il se concentre sur la logique métier.
- **`CalculateLotSize()`** : Calcule la taille de position selon le risque % et la distance SL.
- **`ExecuteOrder()`** : Envoie les ordres (`OrderSend`) au serveur.
- **`UpdateChartLines()`** : Dessine les lignes visuelles (SL, TP, Entry) sur le graphique avant la prise de position.
- **`UpdateOpenOrderLines()`** : Dessine les lignes des positions *ouvertes* (pour remplacer celles de MT4).

### D. Le Cerveau Graphique : `GUI/GUI_Master.mqh`
C'est le **Master Controller**.
- **`GUI_OnInit()`** : Lance la création initiale des panneaux (`CreatePanel`, `UpdateUIMode`).
- **`GUI_OnChartEvent()`** : Reçoit tous les clics et mouvements.
    - **Routing** : Si c'est un clic sur "Settings", il appelle `Panel_Settings`. Si c'est un clic sur "Buy", il appelle `Trade`.
    - **Gestion du Drag** : Gère le déplacement des fenêtres.
    - **Raccourcis Clavier** : Gère les touches (7, 8, 9) pour changer de type d'ordre.

### E. Les Vues (Panneaux)
- **`Panel_Main.mqh`** : Contient `CreatePanel()` et `UpdateUIMode()`. Gère l'affichage dynamique du panneau de trading (changement de couleur selon Buy/Sell, affichage conditionnel des champs Limit/Stop). Gère aussi le sélecteur d'actif (`ToggleSymbolList`).
- **`Panel_Settings.mqh`** : Contient la logique du color picker et des champs de saisie pour la configuration.
- **`Components.mqh`** : Contient `CreateButton`, `CreateLabel`, `CreateEdit`. **C'est ici qu'on définit le style visuel de base.**

---

Ce projet est conçu pour être propre et segmenté. Maintenez cette séparation rigoureuse.
