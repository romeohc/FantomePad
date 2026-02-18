---
name: ea-license-security-auditor
description: Performs an obsessive, read-only security audit of the PhantomPad Expert Advisor's license system, authentication flow, soft-lock protection, cryptographic obfuscation, and Supabase backend integration. Its single mission is to guarantee that the license cannot be bypassed, spoofed, or tampered with, and that the soft-lock mode truly prevents unauthorized trading. Produces a detailed audit report with a score out of 100. Does NOT modify any file or database record.
---

# Expert Advisor — License Security Auditor 🔑🔒

## Goal

To perform an **exhaustive, read-only** security audit of the entire license and authentication system — from **local certificate storage** to **Supabase edge function communication**, **soft-lock enforcement**, and **cryptographic obfuscation**.

The output is a single `.md` audit report. **No code or database is modified. Ever.**

After this audit passes with no CRITICAL findings, we can guarantee:
- It is **impossible to trade without a valid license** (every entry point is guarded).
- The **soft-lock mode** truly restricts the user to position management only (close/modify, no new trades).
- The **license heartbeat** cannot be trivially bypassed or suppressed.
- The **certificate file and activation code** are stored with reasonable obfuscation.
- **JSON injection** into the license check payload is prevented.
- The **Supabase backend** has proper RLS policies protecting license data.

---

## When to use this skill

- When user ask to use the "ea license security auditor"
- When user ask an audit security for the license system.

---

## How to use it

### PHASE 0 — BACKEND INTROSPECTION (Supabase)

Before starting the file analysis, perform a **read-only** reconnaissance of the Supabase backend to inform the audit:

1.  **Check Security Advisors**: Run `get_advisors(type='security')` to identify flagged vulnerabilities in the database.
2.  **Verify RLS**: Run a **SELECT-only** query to check Row Level Security on the `Licence` table:
    ```sql
    SELECT tablename, policyname, roles, cmd, qual 
    FROM pg_policies 
    WHERE tablename = 'Licence';
    ```
3.  **Schema Check**: Run `list_tables` and use `execute_sql` (SELECT only) to understand the `Licence` table structure (constraints, indices).

---

### PHASE 1 — FILE COLLECTION (Mandatory Reading List)

Read **ALL** of these files in full before starting any analysis.

| Priority | File | Why |
|----------|------|-----|
| 🔴 P0 | `Common/Core/Security.mqh` | `CheckLicense()` — main license verification, `GetSessionID()` — hardware fingerprint, `GetSecretToken()` / `SaveSecretToken()` — cert management |
| 🔴 P0 | `Common/GUI/SoftLock.mqh` | `HandleInitialLicenseCheck()` — startup gate, `HandleLicenseHeartbeat()` — periodic recheck, `ApplySoftLockMode()` — UI restriction |
| 🔴 P0 | `Common/Core/Crypto.mqh` | `EncodeString()` / `DecodeString()` — XOR obfuscation, `HexToInt()`, `IsEncodedHexString()` |
| 🟠 P1 | `Common/GUI/Auth/Panel_Auth.mqh` | Auth panel logic — activation code submission |
| 🟠 P1 | `Common/GUI/Auth/Panel_Auth_UI.mqh` | Auth panel rendering |
| 🟠 P1 | `Common/Core/IO/HttpManager.mqh` | `Post()` — HTTP POST to Supabase, timeout, error handling |
| 🟠 P1 | `Common/Core/IO/FileManager.mqh` | `Read()` / `Write()` / `Delete()` — cert file operations |
| 🟠 P1 | `Common/Core/Config.mqh` | `LoadConfig()` — loads encoded activation code, `SaveConfigToFile()` — saves encoded |
| 🟡 P2 | `Common/Core/Globals.mqh` | `g_LicenseState`, `g_IsLicensed`, `g_ActivationCode`, `g_AuthErrorMsg` |
| 🟡 P2 | `Common/Core/StateTypes.mqh` | `ENUM_LICENSE_STATE` enum definition |
| 🟡 P2 | `GUI/Events/Handlers/Handler_Trading.mqh` | License guard at trading entry point |
| 🟡 P2 | `fantomepad.mq4` / `fantomepad.mq5` | `OnTick()` license check |

**Backend (Supabase) — use MCP tools in READ-ONLY:**
| Priority | Target | Why |
|----------|--------|-----|
| 🟠 P1 | `Licence` table schema & RLS | Can users read/modify other users' licenses? |
| 🟠 P1 | `verify-license` edge function | Is the server-side validation logic sound? |

### PHASE 2 — SYSTEMATIC ANALYSIS (Ordered Checklist)

Verdicts: ✅ **PASS**, ❌ **FAIL (CRITICAL)**, ⚠️ **WARN**

#### Block A — License Check Logic (`Security.mqh`)

| # | Check | What to verify |
|---|-------|----------------|
| A1 | **Empty code guard** | Is `code == ""` returning `false` immediately? |
| A2 | **JSON injection prevention** | Are `"` and `\` stripped from `cleanCode`, `sessionID`, `secretToken`? Any other dangerous chars (`{`, `}`, `:`) left unescaped? |
| A3 | **Response parsing robustness** | If Supabase returns garbage/empty/malformed JSON, does the code crash or handle gracefully? |
| A4 | **Token extraction safety** | When extracting `"new_token"`, is `StringFind()` + `StringSubstr()` safe against out-of-bounds? |
| A5 | **Self-healing mechanism** | When "Certificat" error detected, is `fantome_cert.dat` deleted to allow re-activation? Is this exploitable? |
| A6 | **Timeout** | Is the default 5000ms reasonable? Could an attacker DoS the Supabase endpoint to force timeout and bypass? |
| A7 | **HTTP error mapping** | Are 4060 (URL not allowed), 4014 (not allowed in testing), and -1 correctly mapped? |

#### Block B — Hardware Fingerprint (`GetSessionID`)

| # | Check | What to verify |
|---|-------|----------------|
| B1 | **Uniqueness** | Is `"ID-" + sessionName + "-" + cpu_cores` unique enough across machines? |
| B2 | **Stability** | Does it change if the user reinstalls MT4/MT5 or moves the data folder? |
| B3 | **Spoofability** | How easy is it for a user to fake this ID? (It's based on file path + CPU cores) |
| B4 | **Cross-platform** | Does it work on Mac (Wine), Windows, and VPS environments? |

#### Block C — Cryptographic Obfuscation (`Crypto.mqh`)

| # | Check | What to verify |
|---|-------|----------------|
| C1 | **XOR Key Scope** | Is the key used only for local config/cert obfuscation? If yes, a hardcoded key is **ACCEPTABLE**. Do NOT flag as a warning unless the key is used for actual server-side encryption secrets. |
| C2 | **Encode/Decode symmetry** | Does `DecodeString(EncodeString(x)) == x` for all inputs? |
| C3 | **Legacy compatibility** | Does `DecodeString()` handle plain-text (non-hex) input from old config files? |
| C4 | **XOR Logic** | Ensure XOR is not used for data integrity (signing). It is for curiosity-protection only. |

#### Block D — Soft-Lock Mode (`SoftLock.mqh`)

| # | Check | What to verify |
|---|-------|----------------|
| D1 | **Initial check — code present** | If `g_ActivationCode != ""` and `CheckLicense()` fails: if positions open → `LICENSE_REVOKED` (soft-lock), if no positions → `LICENSE_NONE` (full lock). Correct? |
| D2 | **Initial check — no code** | If `g_ActivationCode == ""` but positions exist: `LICENSE_REVOKED`. Correct? This prevents code deletion as bypass. |
| D3 | **Soft-lock UI restrictions** | In `ApplySoftLockMode()`: Main panel hidden? Account panel hidden? History hidden? Settings hidden? ONLY Positions panel visible? Alert banner shown? |
| D4 | **Can new trades be opened in soft-lock?** | Is `g_LicenseState != LICENSE_OK` checked in `Handler_Trading.mqh` BEFORE building TradeRequest? Is it checked in `TradeValidator` (Level 6)? |
| D5 | **OnTick guard** | In `OnTick()`, if `!g_IsLicensed`, is only `GUI_OnTick()` called (no trade logic)? |
| D6 | **Heartbeat interval** | Is 1800000ms (30 min) reasonable? Could a user trade for 30 min before heartbeat catches a revoked license? |
| D7 | **Heartbeat idle check** | Is `g_LastInteractionTime > 60000` checked to avoid checking during active trading (UX protection)? |
| D8 | **Revoked → None transition** | When `OrdersTotal() == 0` and license is revoked, does it switch to `LICENSE_NONE` and trigger re-init? |
| D9 | **Server unreachable handling** | If heartbeat fails because server is down ("Serveur injoignable"), does it NOT revoke the license? (Grace period logic) |

#### Block E — Certificate & Config Storage

| # | Check | What to verify |
|---|-------|----------------|
| E1 | **cert file location** | Is `fantome_cert.dat` in `FILE_COMMON`? Can other EAs access it? |
| E2 | **cert file permissions** | Is `FILE_SHARE_READ` used for reading? Could another process corrupt the file while reading? |
| E3 | **Config activation code** | Is `g_ActivationCode` encoded via `EncodeString()` before writing to config file? Is it decoded on load? |
| E4 | **Config file tampering** | If a user manually edits `FantomePad_Config2.txt` and changes `MaxRiskPercent=99999`, is it caught by the sanity check in `OnInit()`? (Note: this overlaps with capital-safety, but license perspective matters for config integrity) |

#### Block F — Backend Security (Supabase)

| # | Check | What to verify |
|---|-------|----------------|
| F1 | **Licence table RLS** | **ACTION: Run SQL SELECT on `pg_policies`.** Are policies active? Can a user read/modify licenses of other users? |
| F2 | **Edge function validation** | Does `verify-license` validate all 3 keys (code, session_id, secret_token)? (Use `list_edge_functions` to verify existence). |
| F3 | **Database Advisors** | **ACTION: Use `get_advisors`.** Are there any performance or security issues flagged for the license tables? |
| F4 | **Token rotation** | When `new_token` is returned on first activation, is the old token invalidated server-side? |
| F5 | **HTTPS** | Is the URL `https://` (not `http://`)? check `HttpManager.mqh`. |

#### Block G — License Guard Completeness

| # | Check | What to verify |
|---|-------|----------------|
| G1 | **Every trade entry point** | Are ALL trade-opening paths protected by license check? (Buy, Sell, Pending: all 3 in Handler_Trading) |
| G2 | **Position management in soft-lock** | Can users still close/modify positions when license is revoked? (They SHOULD be able to — protecting their capital) |
| G3 | **OnTick guard** | In `OnTick()`: if `!g_IsLicensed` → only GUI update, no trade logic. Verified? |
| G4 | **Timer bypass** | Could a user disable `OnTimer()` to prevent heartbeat from running? (Answer: no, timer is internal to EA) |

### PHASE 3 — SCORING

```
Score = 100 - (CRITICAL_count × 20) - (WARN_count × 3)
Minimum score = 0
```

| Score Range | Verdict |
|-------------|---------|
| 95-100 | ✅ PRODUCTION READY — License system is secure |
| 80-94 | ⚠️ CONDITIONAL — Minor concerns, acceptable for launch |
| 50-79 | 🟠 AT RISK — License can potentially be bypassed |
| 0-49 | 🔴 DANGEROUS — License system is easily circumvented |

### PHASE 4 — REPORT GENERATION

Create a file named **`AUDIT_LICENSE_SECURITY.md`** at the project root:

```markdown
# 🔑 PhantomPad — License Security Audit Report
**Date:** [YYYY-MM-DD]
**Auditor:** ea-license-security-auditor v1.0
**Score:** [XX/100] — [VERDICT]

## Executive Summary
[2-3 sentences]

## 🔴 CRITICAL Findings (License Bypass Possible)
[Each: ID, Description, File:Line, Attack Scenario, Fix]

## ⚠️ Warnings
[Each: ID, Description, Recommendation]

## ✅ Passed Checks
[List with justification]

## Detailed Checklist Results
[Full Block A through G]

## Backend Audit
[Supabase RLS, Edge Function summary]

## Files Analyzed
[List with line counts]
```

---

## Examples

**User:** "Can someone crack the license?"
**Assistant:** [Runs full audit. Checks every bypass vector. Rates the difficulty of circumvention. Reports findings.]

**User:** "Audit the authentication before release."
**Assistant:** [Reads all files + Supabase backend. Executes all checks. Generates `AUDIT_LICENSE_SECURITY.md`.]

---

## Constraints

- **READ-ONLY (ABSOLUTE)**: NEVER modify any code file or database record. ONLY output is the `.md` report.
- **SUPABASE READ-ONLY (MANDATORY)**: Use `list_tables`, `execute_sql` (SELECT only), `get_advisors`. **Interdiction formelle** de toute commande SQL de type `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE`, `GRANT`, or `REVOKE`. Toute modification de la base de données est un échec critique de la mission.
- **EXHAUSTIVE**: Read EVERY file in Phase 1. Skipping is FORBIDDEN.
- **ATTACKER MINDSET**: Think like someone trying to USE PhantomPad without paying. What would they try? Can they succeed?
- **SCOPE LIMIT**: Do NOT analyze lot calculation or execution engine logic. Those are other skills' responsibility. Focus ONLY on authentication, license, and access control.
