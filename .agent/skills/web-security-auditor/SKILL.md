---
name: web-security-auditor
description: Analyzes the Next.js web application and Supabase configuration for security vulnerabilities without modifying code or database.
---

# Web Security Auditor

## Goal
To perform a comprehensive, **read-only** security audit of the FantomePad Next.js web application (located in the `web` directory) and the associated Supabase project ("PhantomPad"). The goal is to identify potential vulnerabilities, bugs, and security risks in both the frontend code and the database configuration (RLS, licenses, etc.) that could compromise the application or its users. This skill **MUST NOT** modify any code or database records. It only produces a report.

## When to use this skill
- When the user asks for a security audit, review, or analysis of the web application.
- When checking for vulnerabilities in the frontend, API routes, or Supabase database configuration.
- Before a major release to ensure security standards are met.

## How to use it
1.  **Scope Definition**:
    -   **Codebase**: `web/` directory (Next.js application).
    -   **Database**: Supabase project named "PhantomPad" (specifically the `Licence` table and RLS policies).

2.  **Analysis Phase (Read-Only)**:
    -   **Code Analysis (File System)**:
        -   file structure analysis of `web/`.
        -   Scan for hardcoded secrets, insecure patterns (`dangerouslySetInnerHTML`), injection risks, and sensitive data exposure.
        -   Review authentication flows and API route protection.
    
    -   **Database Analysis (Supabase MCP)**:
        -   **Tools**: Use `supabase-mcp-server` tools.
        -   **Project Check**: Verify the "PhantomPad" project status using `get_project` or `list_projects`.
        -   **Advisors**: Run `get_advisors` with `type='security'` to get automated security recommendations from Supabase (e.g., MFA, RLS).
        -   **Schema & RLS**: 
            -   List tables using `list_tables` (verify existence of `Licence` table).
            -   **CRITICAL**: Check Row Level Security (RLS) policies. You may use `execute_sql` to query system catalog tables (like `pg_policies`) to verify RLS is enabled and correctly configured.
            -   **STRICT PROHIBITION**: You MUST NOT execute any `INSERT`, `UPDATE`, `DELETE`, `DROP`, or `ALTER` statements. Only `SELECT` or introspection inspection tools are allowed.

3.  **Reporting Phase**:
    -   Create/Overwrite a comprehensive markdown report file named `SECURITY_AUDIT_REPORT.md` in the root of the project.
    -   The report **MUST** include:
        -   **Executive Summary**: High-level overview of the security posture (App + DB).
        -   **Methodology**: Description of checks performed on Code and Supabase.
        -   **Findings**: Detailed list of issues found, categorized by severity (Critical, High, Medium, Low).
            -   *Supabase Findings*: Specific section for Database/RLS issues.
            -   *Code Findings*: Specific section for Next.js/App issues.
            -   For each finding, include: Location, Description, Potential Impact, and Recommendation.
        -   **Conclusion**: Final verdict.

## Examples
**User:** "Audit the security of the web app and database."
**Assistant:**
1.  Scans `web/` for code vulnerabilities.
2.  Connects to Supabase "PhantomPad" project.
3.  Checks if RLS is enabled on the `Licence` table.
4.  Identifies that RLS is disabled (Critical).
5.  Identifies a hardcoded secret in `web/` (High).
6.  Creates `SECURITY_AUDIT_REPORT.md` detailing these findings.

## Constraints
-   **NO CODE MODIFICATIONS**: This skill is strictly read-only regarding the application code.
-   **NO DATABASE MODIFICATIONS**: This skill is strictly read-only regarding the Supabase database. NEVER fix RLS policies or data issues automatically.
-   **Output**: The ONLY file to be created or modified is the `SECURITY_AUDIT_REPORT.md`.
