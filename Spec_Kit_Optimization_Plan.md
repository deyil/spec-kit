# Spec Kit Optimization Plan
## Problem Statement
Spec Kit's current workflow requires users to execute **5-6 sequential slash commands** (`constitution` → `specify` → `clarify` → `plan` → `tasks` → `implement`), which creates friction for both new and experienced users. The learning curve is steep, commands must be invoked in the correct order, and there's no easy path for simple projects.
## Current State Overview
**Workflow Steps:**
1. `/speckit.constitution` - Create project principles (often skipped)
2. `/speckit.specify <description>` - Create feature specification
3. `/speckit.clarify` - Ask clarification questions (optional)
4. `/speckit.plan <tech stack>` - Create implementation plan
5. `/speckit.tasks` - Generate actionable tasks
6. `/speckit.implement` - Execute tasks
7. `/speckit.analyze` - Consistency check (optional)
8. `/speckit.checklist` - Quality validation (optional)
**Key Pain Points Identified:**
* Too many sequential commands to remember
* No guided flow or smart progression between steps
* Redundant user input (feature description in specify, tech stack in plan)
* Optional commands (clarify, analyze, checklist) create confusion about when to use them
* Constitution step is important but easily skipped
* No "quick mode" for simple projects
* No status/progress tracking
## Upstream Sync & Conflict Minimization
Goal: keep future merges/rebases with upstream low-conflict.
Principles:
* Prefer additive changes (new files) over modifying existing ones.
* Avoid renames/moves, broad refactors, and formatting-only changes (whitespace/reflow).
* Keep edits to high-churn files (notably `src/specify_cli/__init__.py`, release scripts, `README.md`) small and as append-only as possible.
* Encapsulate new behavior in new modules/files and keep existing entrypoints as thin “wiring” layers.
* Land work as small, separable PRs/commits (one feature per PR when possible) to make upstream merges easier.
Implementation tactics in this plan:
* New workflow commands (`build`, `quick`, `status`) are new files under `templates/commands/`.
* New workflow commands orchestrate existing commands instead of duplicating their logic.
* When modifying existing templates, only add narrowly-scoped sections; do not reorder/rewrite existing content.
* Add checklist scanning to `analyze` as a clearly-delimited, appended section to minimize overlap with upstream edits.
* Keep version bump + `CHANGELOG.md` edits in a dedicated commit to reduce merge friction.
## Distribution Strategy (Option B: Maintain a Fork + Custom Releases)
Goal: ship the new commands to users without waiting for upstream, while still keeping it easy to regularly merge/rebase from upstream.
Approach:
* Maintain a long-lived fork that stays close to upstream `main`.
* Publish releases from the fork so teams can consume the updated command templates.
How users consume it:
* Change CLI defaults to use your fork:
    * Current state: template downloads are hardcoded to `github/spec-kit` in `download_template_from_github(...)`.
    * Change defaults to your fork:
        * `--template-owner <owner>` (default `deyil`)
        * `--template-repo <repo>` (default `spec-kit`)
    * Users who want upstream can override: `specify init --template-owner github`
    * Implementation notes:
        * Keep the override logic isolated (new helper/module), and keep `src/specify_cli/__init__.py` as thin wiring.
        * Note: this change will cause merge conflicts if upstream changes the same lines; resolve by keeping your defaults during rebase.
* Fallback (no CLI changes): users manually download the fork’s release ZIP for their agent and extract/copy the command files into their project’s agent folder (e.g. `.claude/commands/`, `.github/agents/`, etc.).
Keeping the fork in sync with upstream (low-conflict routine):
* Avoid large refactors; keep changes additive as described in the upstream-sync section.
* Regularly merge/rebase upstream changes into the fork, resolve conflicts, and cut a new fork release.
Release requirements:
* Ensure the fork publishes assets with the same naming pattern as upstream (so tooling and docs stay consistent), e.g. `spec-kit-template-{agent}-{sh|ps}-<version>.zip`.
## Proposed Changes
### 1. New Unified Command: `/speckit.build` (High Priority)
Create a single guided wizard command that orchestrates the full workflow:
```warp-runnable-command
/speckit.build [optional: inline description and tech stack]
```
**Behavior:**
* Prompts for: project description, tech stack, key constraints
* Auto-generates constitution from context (or uses existing)
* Runs specify → plan → tasks in sequence
* Pauses for user confirmation at key checkpoints
* Runs optional clarify only if critical ambiguities detected
* Integrates checklist + analysis into the guided flow:
    * Run `/speckit.checklist` after spec/plan/tasks exist
    * Ask the user for the checklist domain OR auto-suggest a domain from generated artifacts
    * Limit to **1-2 checklist-scoping questions max** (fast mode) before writing checklist file(s)
    * Run `/speckit.analyze` after **all** artifacts are generated (spec + plan + tasks + checklists)
* Final output: Ready-to-implement project with all artifacts + checklist(s) + analysis report
**Files to create:**
* `templates/commands/build.md` - The unified command template
### 2. New Quick Mode: `/speckit.quick` (High Priority)
Context-aware fast path for clear requirements:
```warp-runnable-command
/speckit.quick Build a REST API for user management using Python/FastAPI
```
**Behavior:**
* Combines specify + plan + tasks into one invocation
* **Context-aware assumptions** - consults project context before assuming (see below)
* **Critical-only clarification** - asks max 1-2 questions only for showstoppers
* Documents all assumptions with their source
* Integrates checklist + analysis in fast mode:
    * Auto-select checklist domain(s) based on generated artifacts
    * Auto-generate **1-2 checklist-scoping questions** based on generated artifacts (ask only if needed; otherwise apply defaults)
    * Generate checklist file(s)
    * Run `/speckit.analyze` after **all** artifacts are generated (spec + plan + tasks + checklists)
* Targets 80% use case where requirements are reasonably clear
**Context Sources (consulted in priority order):**
```warp-runnable-command
High Priority (always check):
  1. constitution.md - Principles, constraints, non-negotiables
  2. Existing specs/*/spec.md + plan.md - Patterns from previous features
  3. Agent context files (CLAUDE.md, AGENTS.md, etc.) - Established AI context
  4. Config files (package.json, pyproject.toml, etc.) - Dependencies, scripts
  5. Design system / UI components - Existing UI patterns, theme
Medium Priority (for relevant decisions):
  6. Codebase patterns - Directory structure, naming, imports
  7. Style files + theme (tailwind.config, CSS vars) - Brand, colors
  8. Test patterns - Framework, coverage expectations
  9. CI/CD config (.github/workflows) - Required checks
  10. Existing contracts (OpenAPI, GraphQL) - API patterns
Lower Priority (if still ambiguous):
  11. Storybook / component docs - UI documentation
  12. Git history / recent commits - Current work context
  13. README - Project overview
  14. Infrastructure configs (Docker, etc.) - Deployment patterns
```
**Critical vs Non-Critical Decisions:**
* **Critical (ask user):** Auth model, data ownership, real-time requirements, breaking API changes
* **Non-critical (assume from context):** Pagination style, error format, naming conventions, UI patterns
**Example output in spec.md:**
```markdown
## Assumptions (derived from project context)
- OAuth2 auth flow (per constitution.md)
- SendGrid for emails (consistent with feature 001-notifications)
- 1-hour token expiry (matches existing auth config)
- Primary button style for submit (per design system)
```
**Files to create:**
* `templates/commands/quick.md` - The quick command template
### 3. New Status Command: `/speckit.status` (Medium Priority)
Show workflow progress and next steps:
```warp-runnable-command
/speckit.status
```
**Output example:**
```warp-runnable-command
Feature: 003-user-authentication
✓ Constitution: .specify/memory/constitution.md
✓ Specification: .specify/specs/003-user-auth/spec.md
✓ Plan: .specify/specs/003-user-auth/plan.md
○ Tasks: Not created
○ Checklists: Not created
○ Analysis: Not run
○ Implementation: Not started
Next: Run /speckit.tasks to generate task breakdown
```
**Checklist details (when present):**
```warp-runnable-command
○ Checklists:
  ✓ checklists/api.md - 12/12 complete
  ⚠ checklists/ux.md - 8/10 complete (2 unresolved)
  ⚠ checklists/security.md - 5/8 complete (3 unresolved)
```
**Implementation approach:**
* Extend existing `check-prerequisites.sh` with `--status` flag (reuse `get_feature_paths` logic)
* Or: command template can check file existence directly without helper script
**Files to create/modify:**
* `templates/commands/status.md` - The status command template
* `scripts/bash/check-prerequisites.sh` - Add `--status` flag (optional)
* `scripts/powershell/check-prerequisites.ps1` - Add `-Status` flag (optional)
### 4. Keep Analyze and Checklist Separate + Enhance Analyze (Medium Priority)
After review, these commands serve **distinct purposes** but should integrate better:
**`/speckit.analyze`** - Cross-artifact consistency:
* Checks if spec.md, plan.md, tasks.md align with each other
* Finds duplications, gaps, contradictions, coverage mismatches
* Automated, no user input needed
* Run after `/speckit.tasks`, before `/speckit.implement` (and for `/speckit.build` + `/speckit.quick`, run automatically after tasks + checklists are generated)
**`/speckit.checklist`** - Requirements quality validation:
* "Unit tests for English" - validates requirements are clear, complete, measurable
* User specifies domain (UX, security, API, performance, etc.)
* Creates separate checklist files: `checklists/ux.md`, `checklists/security.md`
* Run anytime to validate specific requirement areas
**Enhancement: Analyze should perform checklist quality analysis**
Currently `/speckit.analyze` ignores `checklists/*.md`. Add:
* Load all files in `FEATURE_DIR/checklists/`
* Perform quality analysis on checklist items:
  - Ambiguity detection (vague criteria without measurement)
  - Testability check (objectively verifiable)
  - Cross-artifact alignment (validates actual spec requirements)
  - Duplication detection (same validation across multiple checklists)
  - Orphan detection (validates undefined features/components)
* Integrate findings into main analysis report with severity levels
* Example findings:
  - `CQ1 | Checklist Quality | HIGH | checklists/security.md:L15 | Validation item "system is secure" is untestable | Add measurable criteria`
**Files to modify:**
* `templates/commands/analyze.md` - Add checklist quality analysis logic
**No merge needed** - they complement each other, analyze now performs checklist quality analysis.
### 5. Improve Command Handoffs (Medium Priority)
Enhance the existing handoff system to be more proactive:
**Changes:**
* After `/speckit.specify` success, auto-suggest: "Ready for planning. Run `/speckit.plan` or describe your tech stack:"
* After `/speckit.plan` success, auto-run `/speckit.tasks` unless user opts out
* Add `--auto` flag to commands for continuous flow
**Files to modify:**
* `templates/commands/specify.md` - Enhance handoff section
* `templates/commands/plan.md` - Add auto-continuation logic
* `templates/commands/tasks.md` - Add auto-continuation logic
### 6. CLI Improvements (Lower Priority)
**6a. Auto-detect AI agent:**
* Check for presence of `.claude/`, `.gemini/`, `.cursor/`, etc. folders
* Skip agent selection prompt if detected
**6b. Reduce interactive prompts:**
* Auto-detect script type from OS (already partially done)
* Add `--yes` flag to accept all defaults
**6c. Add `specify quickstart` command:**
```warp-runnable-command
specify quickstart my-project --ai claude --quick
```
Sets up project AND runs the quick workflow in one CLI invocation.
**Files to modify:**
* `src/specify_cli/__init__.py` - Minimal wiring only (prefer placing new logic in new module files to reduce merge conflicts)
## Command Comparison: `/speckit.build` vs `/speckit.quick`
| Aspect | `/speckit.build` | `/speckit.quick` |
|--------|------------------|------------------|
| **Interaction** | Multi-step wizard with pauses | Single command, minimal interaction |
| **Clarification** | Up to 5 questions at checkpoints | 0-2 critical questions only |
| **Non-critical gaps** | Asks or flags for review | Assumes from project context |
| **Context consultation** | User-driven decisions | Full automated context scan |
| **Constitution** | Creates/updates interactively | Uses existing, skips if none |
| **Time** | 10-15 min (thorough) | 2-4 min (fast + checklist + analyze) |
| **Best for** | New projects, complex features, stakeholder review | Clear features, prototypes, experienced users |
| **Output quality** | Thorough + checklist + analyze | Good, context-aligned + checklist + analyze |
## Implementation Priority
| Change | Priority | Effort | Impact |
|--------|----------|--------|--------|
| `/speckit.build` command | High | Medium | High - Single command for full workflow |
| `/speckit.quick` command | High | Medium | High - Fast path for simple projects |
| `/speckit.status` command | Medium | Low | Medium - Better UX and guidance |
| Improve handoffs | Medium | Low | Medium - Smoother transitions |
| CLI improvements | Lower | Medium | Low-Medium - Developer convenience |
## Backward Compatibility
All existing commands will continue to work:
* `/speckit.constitution`, `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement` - No changes to behavior
* `/speckit.clarify`, `/speckit.analyze`, `/speckit.checklist`, `/speckit.taskstoissues` - No changes
New commands are additive and provide easier entry points while preserving granular control.
## Success Metrics
1. New users can go from idea to ready-to-implement in **1-2 commands** instead of 5-6
2. `/speckit.quick` handles 80% of straightforward features
3. `/speckit.status` eliminates "what do I do next?" confusion
4. Documentation simplifies to: "Use `/speckit.build` for guided workflow or `/speckit.quick` for fast iteration"
## Files Summary
**New files to create:**
* `templates/commands/build.md`
* `templates/commands/quick.md`
* `templates/commands/status.md`
**Files to modify:**
* `templates/commands/specify.md` - Better handoffs
* `templates/commands/plan.md` - Better handoffs, auto-continue option
* `templates/commands/tasks.md` - Better handoffs
* `templates/commands/checklist.md` - Add fast mode (limit checklist-scoping questions to 1-2 for build/quick)
* `templates/commands/analyze.md` - Add checklist scanning
* `scripts/bash/check-prerequisites.sh` - Add `--status` flag (optional)
* `scripts/powershell/check-prerequisites.ps1` - Add `-Status` flag (optional)
* `.github/workflows/scripts/create-release-packages.sh` - Include new commands in release
* `src/specify_cli/__init__.py` - Minimal wiring only; keep new logic in new module files where possible
* `README.md` - Document new commands (small, additive edits)
* `CHANGELOG.md` - Version bump and changelog (dedicated commit)
* `pyproject.toml` - Version bump (dedicated commit)
* `AGENTS.md` - No change for this plan (only update when adding new agent support)
