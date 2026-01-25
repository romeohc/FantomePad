---
name: skill-creator
description: Generates complete directory structures and SKILL.md files for Google Antigravity skills. Ensures compliance with official standards, semantic discovery, and workflow best practices.
---

# Skill Creator

## Goal
To standardize the creation of robust Antigravity skills by guiding the user from concept to a production-ready folder structure, maximizing agent discoverability and efficiency.

## When to use this skill
- When a user wants to automate a recurring or complex task.
- To structure specialized workflows (e.g., code review, deployment, formatting).
- When a new capability needs to be modularly added to the agent's toolkit.

## How to use it
1. **Scope Assessment**: Determine if the skill is local (`.agent/skills/`) or global (`~/.gemini/antigravity/global_skills/`).
2. **Trigger Design**: Write a third-person description rich in keywords to ensure the agent correctly identifies when to activate the skill.
3. **SKILL.md Generation**:
   - Generate the YAML frontmatter with `name` and `description`.
   - Use mandatory sections: `# Goal`, `## When to use`, `## How to use`, `## Examples` (provide at least 2), and `## Constraints` (safety and scope limits).
   - Include a `## Decision Logic` section if the task involves complex branching or multiple approaches.
4. **Folder Structure**: Propose the standard Antigravity hierarchy:
skill-name/ ├── SKILL.md # Core instructions (required) ├── scripts/ # Executable scripts (optional) ├── examples/ # Reference implementations for few-shot learning └── resources/ # Templates or additional documentation
5. **Script Management**: If scripts are included, instruct the agent to treat them as "black boxes" by running them with `--help` first instead of reading the full source code.

## Examples
**User:** "Create a skill to audit my Dockerfiles for security."
**Assistant:** [Generates a `docker-security-audit` folder with a SKILL.md containing rules for base images, user permissions, and secret handling].

## Constraints
- **Atomicity**: Each skill must focus on a single, well-defined task.
- **Format**: Always use Markdown for the body and YAML for metadata.
- **Discovery**: Ensure the description is specific enough for semantic detection.