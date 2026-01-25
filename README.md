# FantomePad - Technical Documentation & Vision

> **Target Audience:** AI Agents & Core Developers
> **Project Status:** Active Development (V2.0)
> **Goal:** Revolutionize the MetaTrader 4 experience through a modern "OS-like" overlay and hardware integration.

---

## 1. Project Vision: The "OS within an App"

**FantomePad** is not just an Expert Advisor. It is a comprehensive **GUI Overhaul and Trade Execution System** designed to sit on top of the archaic MetaTrader 4 engine.

### The Problem
MT4 is powerful but its UX/UI is stuck in 2005.
*   **Friction:** Execution is slow (multiple clicks, separate windows).
*   **Visuals:** Cluttered, dated, and uninspiring.
*   **Disconnect:** No physical connection between the trader's intent and the terminal.

### The Solution
We are building a **Modular Monolith** that acts as a new Operating System within the chart window.
1.  **Software Layer:** A custom-built, high-performance GUI engine rendering a modern "Glassmorphism" interface directly on the chart canvas.
2.  **Hardware Layer (The PhantomPad):** A physical macropad fully integrated with the EA via DLL/Shortcuts, allowing "Blind Execution" (Trading without looking at the mouse).

**The End State:** The user maximizes the chart window, hides all MT4 toolbars/terminals, and interacts *exclusively* through the FantomePad interface.

---

## 2. Technical Architecture

The project follows a strict **Modular Monolith** architecture to ensure maintainability and scalability in MQL4.

### 2.1. File Structure Overview
```text
MQL4/Experts/FantomePad/
├── fantomepad.mq4           # Entry Point (OnInit, OnTick, OnChartEvent)
├── SECURITY_AUDIT.md        # Security Analysis & Vulnerability Report
├── SECURITY_FIX_GUIDE.md    # Remediation Steps for Security
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
