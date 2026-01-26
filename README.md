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
    │   ├── Defines.mqh      # Constants, Colors (Theming), Structs
    │   └── Config.mqh       # Save/Load State Logic (File I/O)
    ├── GUI/                 # Custom Graphics Engine
    │   ├── GUI_Master.mqh   # Event Dispatcher, Redraw Loop, Coordinator
    │   ├── Components/      # Primitives (Buttons, Panels, Labels)
    │   ├── Panel_Main.mqh   # Execution Dashboard (Buy/Sell)
    │   ├── Panel_Manager.mqh# Open Positions List (Grid View)
    │   └── ... (Other Panels: History, Settings, Info, Positions)
    └── Trade/               # Execution Logic
        └── Trade.mqh        # OrderSend Wrappers, Risk Calc, Error Handling
```

### 2.2. The Custom GUI Engine (`Include/FantomePad/GUI/`)
Unlike standard MQL4 panels (which are limited), we implement a **Virtual Window Manager**:
*   **State Management:** Each Window (Panel) is defined by a `TPanelState` struct (Visible, X, Y, Width, Dragging).
*   **Event Loop (`GUI_Master.mqh`):** The `OnChartEvent` from the main file is piped directly here. It handles:
    *   **Routing:** `sparam` (ObjName) is parsed to route clicks to specific handlers.
    *   **Dragging:** Custom logic for moving windows smoothly without lag.
    *   **Safety:** `ApplyPanelSafety()` prevents windows from being dragged off-screen.
*   **Theming:** Centralized in `Defines.mqh` (`g_ColorBg`, `g_ColorGreen`, etc.). Changing one constant updates the entire UI.

### 2.3. The Trading Core (`Include/FantomePad/Trade/`)
*   **Risk Calculation:** real-time calculation of lot sizes based on:
    *   **Balance %:** (e.g. 1% Risk).
    *   **Fixed Money:** (e.g. $100 Risk).
    *   **Fixed R:** (Ratio-based).
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
*   **Mechanism:** `SaveConfig` / `LoadConfig` serialize the UI state (Window positions, Visibility). This ensures the "Desktop" arrangement remains after restarting MT4.

### 3.3. Security & Stability
Refer to `SECURITY_AUDIT.md` for known vectors.
*   **Input Validation:** All user inputs (Risk parameters) are sanitized.
*   **Order Integrity:** Magic Number (`123456`) identifies FantomePad trades.
*   **Zero-Lag Optimization:** `OnTick` is throttled for UI updates (e.g., every 500ms) to preserve CPU for trade execution.

---

## 4. Development Guidelines

### Adding a New Panel
1.  **Define Struct:** Add `TPanelState g_PanelNew` in `Defines.mqh`.
2.  **Create Logic:** Create `Include/FantomePad/GUI/Panel_New.mqh` with `CreateNewPanel()` function.
3.  **Register:** Add `CreateNewPanel()` to `GUI_OnInit()` and `RefreshAllPanels()` in `GUI_Master.mqh`.
4.  **Route Events:** Add proper `if(sparam == ...)` handling in `GUI_OnChartEvent`.

### Design Philosophy
*   **"Aesthetics First":** If it looks like default MT4, it's wrong. Use `g_ColorChartBg` (Dark) and custom `OBJ_RECT_LABEL` objects.
*   **"Speed Second":** Reduce click depth. One click to confirm, zero clicks to calculate.

---

*This document is intended for internal use by Artificial Intelligence Agents and Core Developers to maintain context of the FantomePad vision and architecture.*
