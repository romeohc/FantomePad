# FantomePad - Technical Documentation & Vision

> **Target Audience:** AI Agents & Core Developers
> **Project Status:** Active Development (V2.0)
> **Goal:** Revolutionize the MetaTrader 4 experience through a modern "OS-like" overlay and hardware integration.

---

## 1. Project Vision: The "OS within an App"

**PhantomPad** is a high-performance GUI overlay for MetaTrader 4, engineered to transcend the limitations of the archaic 2005 interface. It transforms the terminal into a modern, fluid environment where the user interacts exclusively with a custom "Mini OS" rendered directly on the chart canvas.

### The Core Pillars
*   **Software (The Overlay):** A custom-built **Modular Monolith** GUI engine. It features independent, draggable, and persistent windows (Trading, Positions, History, Settings) that remember their state across sessions, creating a seamless "desktop" experience within MT4.
*   **Hardware (The Pad):** Future-proof integration with a physical macropad for **"Blind Execution,"** enabling traders to execute complex orders via tactile shortcuts without ever touching a mouse.

### Key Objectives
*   **Eliminate Friction:** Automated risk management (real-time lot sizing based on % or cash risk) and one-click execution to save critical seconds.
*   **Premium Aesthetics:** A "Deep Dark" design system with vibrant accents (Mint Green/Vibrant Red), moving away from "standard toolbars" towards a professional, high-tier SaaS aesthetic.
*   **Sovereignty:** The end goal is for users to maximize their charts, hide all MT4 UI elements, and operate entirely through the PhantomPad ecosystem.

---

## 2. Technical Architecture

The project follows a strict **Modular Monolith** architecture to ensure maintainability and scalability in MQL4.

### 2.1. File Structure Overview
```text
MQL4/Experts/FantomePad/
├── fantomepad.mq4           # Entry Point (OnInit, OnTick, OnChartEvent)
└── Include/FantomePad/      # Core Logic Library
    ├── Core/                # Global Definitions & Configuration
    │   ├── Defines.mqh      # Constants, Colors, Structs, Global State
    │   └── Config.mqh       # Save/Load State Logic (File I/O)
    ├── GUI/                 # Custom Graphics Engine (Modular)
    │   ├── GUI_Master.mqh   # Main Coordinator & Bridge to MQL4 Events
    │   ├── Components/      # UI Primitives (Buttons, Panels, Labels)
    │   ├── Events/          # Event Dispatchers (Click, Drag, Key, etc.)
    │   │   └── Handlers/    # High-level event logic for specific features
    │   ├── Account/         # Account Info Panel Module
    │   ├── History/         # Trade History Panel Module
    │   ├── Main/            # Trading Panel Module (Risk, Buy/Sell)
    │   ├── Navigation/      # Sidebar/Menu Navigation Module
    │   ├── Positions/       # Trade Manager Panel Module
    │   └── Settings/        # Theming & Global Settings Module
    ├── Trade/               # Execution & Risk Logic (Modular)
    │   ├── Trade.mqh        # Main Trading Interface
    │   ├── Trade_Calculations.mqh # Lot Sizing, RR, Risk Math
    │   └── Trade_Execution.mqh    # OrderSend Wrappers & Error Handling
    └── Tests/               # Automated Unit/Integration Tests
```

### 2.2. The Custom GUI Engine (`Include/FantomePad/GUI/`)
The GUI engine uses a **Virtual Window Manager** with a highly modular design:
*   **Event Delegation:** `GUI_Master.mqh` intercepts `OnChartEvent` and routes it to specialized event files in `GUI/Events/` (e.g., `GUI_Event_Click.mqh`). This keeps the master file clean and focused on coordination.
*   **Modular Panels:** Each UI feature (Main, Account, Positions) is encapsulated in its own directory. A typical panel module contains:
    *   `Panel_*.mqh`: The main entry point for the module.
    *   `Panel_*_UI.mqh` / `Panel_*_Layout.mqh`: View definitions and layout logic.
    *   `Panel_*_Logic.mqh`: Business logic specific to the panel.
*   **State Management:** Each Window (Panel) is defined by a `TPanelState` struct in `Defines.mqh` (Visible, X, Y, Width, Dragging).
*   **Centralized Handlers:** Complex interactions that cross panel boundaries or require specific trade logic are managed in `GUI/Events/Handlers/`.

### 2.3. The Trading Core (`Include/FantomePad/Trade/`)
*   **Modularity:** Logic is split into calculations, execution, and visual trade lines.
*   **Risk Calculation:** Real-time calculation of lot sizes based on balance %, fixed money, or fixed R.
*   **Execution:** Wrapper functions around `OrderSend` that handle Retries, Slippage, and ECN compatibility.

---

## 3. Key Systems & Context

### 3.1. Global State (`InitGlobals`)
*   Located in `Defines.mqh`.
*   Acts as the "Registry" for the application.
*   Initializes default positions, load colors, and sets startup flags.
*   **CRITICAL:** Any new global state must be added to the `TPanelState` or relevant struct here.

### 3.2. Persistence System
*   **File:** `FantomePad_Config.txt` (in `MQL4/Files/`).
*   **Mechanism:** `SaveConfig` / `LoadConfig` in `Core/Config.mqh` serialize the UI state. This ensures the "Desktop" arrangement remains after restarting MT4.

### 3.3. Security & Stability
*   **Input Validation:** All user inputs (Risk parameters) are sanitized via dedicated handlers.
*   **Order Integrity:** Unique Magic Numbers identify FantomePad trades.
*   **Performance:** `OnTick` is throttled for UI updates (500ms) to preserve CPU for trade execution. `OnTimer` handles high-frequency UI warnings.

---

## 4. Development Guidelines

### Adding a New Feature/Panel
1.  **Module Creation:** Create a new folder in `Include/FantomePad/GUI/`.
2.  **Define State:** If it needs persistence, add relevant fields to `Defines.mqh` and update `Config.mqh`.
3.  **Implement UI:** Use `Components.mqh` primitives to build the interface within your module.
4.  **Register:** Link the new panel in `GUI_Master.mqh` (`GUI_OnInit` and `RefreshAllPanels`).
5.  **Event Handling:** Add/Update handlers in `GUI/Events/Handlers/` if your feature requires complex interaction logic.

### Design Philosophy
*   **"Aesthetics First":** Maintain the "Deep Dark" professional aesthetic using `Defines.mqh` color tokens.
*   **Strict Modularity:** Keep layout/UI separate from logic. Files should remain under 500 lines.
*   **Zero-Lag Optimization:** Throttling in `OnTick` and efficient event routing are mandatory.

---

*This document is intended for internal use by Artificial Intelligence Agents and Core Developers to maintain context of the FantomePad vision and architecture.*
