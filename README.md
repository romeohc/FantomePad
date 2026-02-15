# FantomePad - Technical Documentation & Vision

> **Target Audience:** AI Agents & Core Developers
> **Project Status:** Active Development (V3.0 - Multi-Platform Architecture)
> **Goal:** Revolutionize the trading experience on legacy platforms (MetaTrader 4 & 5) through a modern "OS-like" overlay, cloud-based licensing, and hardware integration (The Pad).

---

## 1. Project Vision: The "OS within an App"

**PhantomPad** is a high-performance GUI overlay engineered to transcend the limitations of archaic trading interfaces. It transforms platforms like MetaTrader 4 and MetaTrader 5 into a modern, fluid environment where the user interacts exclusively with a custom "Mini OS" rendered directly on the chart canvas.

Our mission is not just to fix MT4, but to **revolutionize how traders interact with the market**. While we start with the MetaTrader ecosystem (due to its massive user base requiring modernization), our core architecture is designed to be platform-agnostic, ready to adapt to future trading environments.

### The Core Pillars
*   **Software (The Overlay):** A custom-built **Modular Monolith** GUI engine. It features independent, draggable, and persistent windows that remember their state across sessions.
*   **Security (Cloud Unified):** A robust, **zero-DLL** licensing system integrated with **Supabase**. It features hardware-bound activation, secret token certificates, and periodic license validation.
*   **Web Hub (**`web/`**):** A modern Next.js centralized portal for license management, user onboarding flow, and terminal connectivity monitoring.
*   **Hardware (The Pad):** Deep integration with physical macropads enabling **"Blind Execution."** Traders can now execute orders, manage risk, and navigate symbols via tactile shortcuts with high-security sequence verification.

### Key Objectives
*   **Eliminate Friction:** Automated risk management (real-time lot sizing based on % or cash risk) and one-click execution to save critical seconds.
*   **Premium Aesthetics:** A "Deep Dark" design system with vibrant accents (Mint Green/Vibrant Red), moving away from "standard toolbars" towards a professional, high-tier SaaS aesthetic.
*   **Sovereignty:** The end goal is for users to maximize their charts, hide all native terminal UI elements, and operate entirely through the PhantomPad ecosystem.

---

## 2. Technical Architecture

The project follows a strict **Hardware Abstraction Layer (H.A.L.)** architecture (Onion Architecture variation) to ensure seamless operation across **MetaTrader 4** and **MetaTrader 5** from a single code base.

### 2.1. File Structure Overview
```text
MQL4/Experts/FantomePad/
├── fantomepad.mq4           # Entry Point MT4 (Wrapper)
├── fantomepad.mq5           # Entry Point MT5 (Wrapper)
├── Include/FantomePad/      # Core Logic Library
└── web/                     # Next.js Web Dashboard & Onboarding

Included Files (Include/FantomePad/):
├── Platform/                # The H.A.L. Core
│   ├── Common/              # PLATFORM-AGNOSTIC CODE (The "Brain")
│   │   ├── Core/            # Global Defs, Config, Security
│   │   │   ├── Defines.mqh  # + Compatibility.mqh (Data Abstraction Layer)
│   │   ├── GUI/             # The "Mini OS" Engine (Pure Logic)
│   │   └── Compatibility.mqh # The "Universal Translator" (Macros & Wrappers)
│   ├── MT4/                 # MT4 SPECIFIC DRIVERS (The "Hands")
│   │   └── Trade/           # Execution logic using OrderSend (Cleaned)
│   ├── MT5/                 # MT5 SPECIFIC DRIVERS (Future Implementation)
│   └── Bridge.mqh           # The "Switch" (Routes calls based on Compiler)
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

### 3.4. Hardware Integration & Shortcuts (`GUI_Event_Key.mqh`)
The Pad system is designed for high-speed, tactile execution without mouse interaction. It uses a **High-Security Sequence Engine** to prevent accidental triggers.

*   **Security Sequence:** Commands require a specific 5-digit sequence (e.g., `9191x`) sent within a **150ms-200ms** window. This ensures that only a programmed hardware pad (not human typing) can trigger core actions.
*   **Trading Macros:**
    *   **Execution:** `91911` (BUY), `91912` (SELL), `91913` (LIMIT), `91914` (STOP).
    *   **Risk Toggle:** `91915` switches between % Risk, Monetary Risk, and Fixed Lot.
*   **Position Management:**
    *   **Quick Closes:** `91917` (25%), `91918` (50%), `91919` (100% - Close All).
    *   **Break-Even:** `91916` moves SL to BE for the selected position.
*   **Navigation & Precision:**
    *   **Symbol Wheel:** `66661/2` to scroll through Market Watch, `66660` to select.
    *   **Risk Wheel:** `77771/2` to increment/decrement risk value, `77770` to reset.
    *   **Cycle Positions:** `82821` to cycle through open trades (autoswitches chart).

---

### 3.5. Security & Stability (Risk Control)
*   **Input Validation:** All user inputs (Risk parameters) are sanitized via dedicated handlers.
*   **Order Integrity:** Unique Magic Numbers identify FantomePad trades.
*   **Performance:** `OnTick` is throttled for UI updates (500ms) to preserve CPU for trade execution. `OnTimer` handles high-frequency license heartbeats.

### 3.6. Security & Licensing (Supabase Cloud Ecosystem)
The security module (`Security.mqh`) represents a major shift toward a professional SaaS model, operating entirely within the MQL4 sandbox without external DLLs.

*   **Cloud Verification:** Powered by **Supabase Edge Functions**. The EA communicates via native `WebRequest` to validate license states, order IDs, and activation status.
*   **Hardware Binding (Session-Locked):**
    *   Licenses are bound to a unique hardware signature derived from `TERMINAL_COMMONDATA_PATH` usage and `TERMINAL_CPU_CORES`.
    *   This ensures "one-click" portability within a user's machine while preventing unauthorized sharing.
*   **The Secret Token (Self-Healing Certificate):**
    *   Upon activation, the server generates a unique **Secret Token** stored in a hidden local binary file (`fantome_cert.dat`).
    *   Verification requires a triple-match: {License Code + Hardware ID + Secret Token}.
    *   **Self-Healing:** If a token is corrupted or reset by an admin, the EA automatically purges local certificates to allow the user a clean re-activation.
*   **Onboarding Experience:**
    *   A custom-built **Onboarding UI** handles the "The new standard is here" first-run experience.
    *   Features a full-screen chart-hiding overlay for a focused, premium software feel.
    *   Monochrome branding (#121212 / #FFFFFF) with professional feedback loops.
    *   Instant revocation capability allows admins to block/ban licenses in real-time, immediately locking the GUI and navigation modules.

### 3.7. The Web Hub (`web/`)
The **FantomePad Web Hub** is the administrative and user-facing gateway to the ecosystem.

*   **Tech Stack:** Next.js 15, TypeScript, Tailwind CSS 4, Framer Motion, and Supabase SSR.
*   **Onboarding Flow:** A high-end interactive onboarding experience that guide users through registration and terminal linking.
*   **User Dashboard:** provides a real-time overview of active licenses, hardware bindings, and account status.
*   **Deployment:** Optimized for Netlify with automatic branch deploys and environment management.

---

## 4. Development Guidelines

### Adding a New Feature/Panel
1.  **Module Creation:** Create a new folder in `Include/FantomePad/GUI/`.
2.  **Define State:** If it needs persistence, add relevant fields to `Defines.mqh` and update `Config.mqh`.
3.  **Implement UI:** Use `Components.mqh` primitives to build the interface within your module.
4.  **Register:** Link the new panel in `GUI_Master.mqh`.
5.  **Validation:** Ensure the feature respects the `g_IsLicensed` flag for proper security blocking.

### Design Philosophy
*   **"Aesthetics First":** Maintain the **"Monochrome Premium"** aesthetic (#121212 / #FFFFFF / #2962FF) using `Defines.mqh` color tokens.
*   **Strict Modularity:** Keep layout/UI separate from logic. Files MUST remain under 300 lines (refactoring mandatory).
*   **SaaS Reliability:** Every network call must be asynchronous or timeout-protected to ensure the EA never freezes during trade execution.

---

*This document is intended for internal use by Artificial Intelligence Agents and Core Developers to maintain context of the FantomePad vision and architecture.*
