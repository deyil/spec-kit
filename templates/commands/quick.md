---
description: Fast path for clear requirements - combines specify, plan, tasks, checklist, and analyze in one context-aware command.
handoffs:
  - label: Start Implementation
    agent: speckit.implement
    prompt: Begin implementing the tasks
    send: true
  - label: View Status
    agent: speckit.status
    prompt: Show current workflow progress
  - label: Full Build Mode
    agent: speckit.build
    prompt: Run the full guided workflow
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

`/speckit.quick` is a **fast-path command** that generates a complete project setup with minimal interaction. It's designed for:

- Clear requirements that don't need extensive clarification
- Experienced users who know what they want
- Prototypes and MVPs
- Features that follow established project patterns

**Time estimate**: 2-4 minutes for a complete project setup.

**Key difference from `/speckit.build`**:
- `/speckit.build` = Guided wizard with checkpoints (10-15 min)
- `/speckit.quick` = Automated flow with context-aware assumptions (2-4 min)

## Orchestration Summary

This command MUST orchestrate the workflow by running these commands in order (with minimal interaction):

1. `/speckit.specify <description>`
2. `/speckit.plan <tech stack>`
3. `/speckit.tasks`
4. `/speckit.checklist` (auto-selected domains)
5. `/speckit.analyze`

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                        /speckit.quick Workflow                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  INPUT: "Build a REST API for user management using Python/FastAPI"     │
│                                                                         │
│  1. CONTEXT SCAN (automatic)                                            │
│     └── Scan all context sources to inform assumptions                  │
│                                                                         │
│  2. GENERATE ALL ARTIFACTS (no checkpoints)                             │
│     ├── Branch + spec.md                                                │
│     ├── plan.md + data-model.md + contracts/                            │
│     ├── tasks.md                                                        │
│     └── checklists/ (auto-selected domains)                             │
│                                                                         │
│  3. CRITICAL CLARIFICATION (0-2 questions only)                         │
│     └── Ask ONLY if showstopper ambiguity detected                      │
│                                                                         │
│  4. ANALYSIS + REPORT                                                   │
│     └── Consistency check + checklist status + summary                  │
│                                                                         │
│  OUTPUT: Ready-to-implement project with documented assumptions         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Context Sources

Before making any assumptions, scan these context sources in priority order:

### High Priority (always check)

| Priority | Source | What to Extract |
|----------|--------|-----------------|
| 1 | `/memory/constitution.md` | Principles, constraints, non-negotiables |
| 2 | Existing `specs/*/spec.md` + `plan.md` | Patterns from previous features |
| 3 | Agent context files (`CLAUDE.md`, `AGENTS.md`, etc.) | Established AI context |
| 4 | Config files (`package.json`, `pyproject.toml`, etc.) | Dependencies, scripts, versions |
| 5 | Design system / UI components | Existing UI patterns, theme |

### Medium Priority (for relevant decisions)

| Priority | Source | What to Extract |
|----------|--------|-----------------|
| 6 | Codebase patterns | Directory structure, naming, imports |
| 7 | Style files + theme (`tailwind.config`, CSS vars) | Brand, colors |
| 8 | Test patterns | Framework, coverage expectations |
| 9 | CI/CD config (`.github/workflows`) | Required checks |
| 10 | Existing contracts (OpenAPI, GraphQL) | API patterns |

### Lower Priority (if still ambiguous)

| Priority | Source | What to Extract |
|----------|--------|-----------------|
| 11 | Storybook / component docs | UI documentation |
| 12 | Git history / recent commits | Current work context |
| 13 | README | Project overview |
| 14 | Infrastructure configs (Docker, etc.) | Deployment patterns |

## Execution Steps

## Delegation Rule (Bullet-Proofing)

This command is an **orchestrator**.

**Important**: `/speckit.quick` does **not** invoke any scripts directly. It must only orchestrate the canonical `/speckit.*` commands listed below.

- You MUST generate artifacts by explicitly **running the canonical `/speckit.*` commands** whose source-of-truth templates live in `templates/commands/`.
- Do **not** re-implement or paraphrase those commands’ internal logic inside `/speckit.quick`.
- Quick-mode behavior is enforced by how you answer prompts (minimal interaction, context-derived assumptions), not by duplicating logic.

### Step 1: Parse Input and Setup

1. **Parse `$ARGUMENTS`**:
   - Extract feature description
   - Extract tech stack (if provided, e.g., "using Python/FastAPI")
   - Extract any explicit constraints mentioned

2. **If description is empty**, ERROR:
   ```text
   ❌ No feature description provided.
   
   Usage: /speckit.quick <description> [using <tech stack>]
   
   Examples:
   - /speckit.quick Build a REST API for user management using Python/FastAPI
   - /speckit.quick Add OAuth2 authentication with Google and GitHub providers
   - /speckit.quick Create a dashboard showing real-time analytics
   ```

3. **Run the canonical spec command**:
   - Run: `/speckit.specify <feature description>`
   - Provide the description parsed from `$ARGUMENTS`.
   - If `/speckit.specify` asks optional questions, answer using project context; ask the user only if it’s a showstopper (counts toward the 0–2 critical question budget).

### Step 2: Context Scan

Before making assumptions, scan these context sources in priority order:

#### High Priority (always check)

| Priority | Source | What to Extract |
|----------|--------|-----------------|
| 1 | `/memory/constitution.md` | Principles, constraints, non-negotiables |
| 2 | Existing `specs/*/spec.md` + `plan.md` | Patterns from previous features |
| 3 | Agent context files (`CLAUDE.md`, `AGENTS.md`, etc.) | Established AI context |
| 4 | Config files (`package.json`, `pyproject.toml`, etc.) | Dependencies, scripts, versions |
| 5 | Design system / UI components | Existing UI patterns, theme |

#### Medium Priority (for relevant decisions)

| Priority | Source | What to Extract |
|----------|--------|-----------------|
| 6 | Codebase patterns | Directory structure, naming, imports |
| 7 | Style files + theme (`tailwind.config`, CSS vars) | Brand, colors |
| 8 | Test patterns | Framework, coverage expectations |
| 9 | CI/CD config (`.github/workflows`) | Required checks |
| 10 | Existing contracts (OpenAPI, GraphQL) | API patterns |

#### Lower Priority (if still ambiguous)

| Priority | Source | What to Extract |
|----------|--------|-----------------|
| 11 | Storybook / component docs | UI documentation |
| 12 | Git history / recent commits | Current work context |
| 13 | README | Project overview |
| 14 | Infrastructure configs (Docker, etc.) | Deployment patterns |

1. **Scan all available context sources** (see table above):
   - Build a context map with findings from each source
   - Record source for each finding (for traceability)

2. **Auto-detect or determine tech stack** (if not provided):
   - Check existing config files (`package.json`, `pyproject.toml`, `go.mod`, etc.)
   - Match against previous feature specs and plans
   - Use project conventions from codebase patterns
   
   **If auto-detection fails**, analyze and decide:
   - Review feature description for technical requirements
   - Consider: data storage needs, API vs UI focus, real-time requirements, scale expectations
   - Select appropriate stack based on:
     - Feature complexity (simple → lightweight stack, complex → robust framework)
     - Data requirements (relational → SQL, document-based → NoSQL, caching → Redis)
     - UI needs (SPA → React/Vue, SSR → Next.js/Nuxt, simple → vanilla)
     - API style (REST, GraphQL, real-time → WebSocket)
   - Document the chosen stack in assumptions with "Agent-determined" source

3. **Build assumptions inventory**:
   ```text
   Context Findings:
   - Auth: OAuth2 flow (from constitution.md)
   - Email: SendGrid (from feature 001-notifications/plan.md)
   - Token expiry: 1 hour (from existing auth config)
   - API style: RESTful (from existing contracts/)
   - Error format: RFC 7807 (from existing API patterns)
   - UI: Primary button style (from design system)
   ```

### Step 3: Generate Specification

This step MUST be performed by running the canonical `/speckit.specify` command (see Step 1.4).

Quick-mode constraints while running `/speckit.specify`:
- Document assumptions with sources (prefer constitution/spec history/config/codebase).
- Ask the user **0–2 questions max**, only for showstoppers.

### Step 4: Generate Plan

Run the canonical command: `/speckit.plan <tech stack>`

Quick-mode constraints while running `/speckit.plan`:
- If tech stack is missing, infer it from repository context; only ask if a wrong choice would materially derail the plan.
- Prefer defaults aligned to existing project patterns.
- After `/speckit.plan` completes, run `{AGENT_SCRIPT}` to update agent context.

### Step 5: Generate Tasks

Run the canonical command: `/speckit.tasks`

Quick-mode constraints while running `/speckit.tasks`:
- Optimize for “ready to implement” with minimal ceremony.
- Preserve any task formatting conventions used by the canonical template.

### Step 6: Generate Checklists (Auto-Select)

1. **Auto-detect checklist domains** from artifacts:
   - Always generate `requirements.md`
   - If API endpoints → generate `api.md`
   - If UI components → generate `ux.md`
   - If auth/security requirements → generate `security.md`
   - If performance requirements specified → generate `performance.md`

2. **Generate checklists** using fast-mode (zero scoping questions):
   - Run `/speckit.checklist` (repeat per domain)
   - **Fast-mode constraint**: When the checklist command prompts for clarifying questions, pre-answer **all questions** from available context (spec, plan, constitution, codebase patterns) and proceed without user interaction. Do not pause for user input.
   - Use context to determine focus areas, depth, and audience
   - Each domain creates or appends `FEATURE_DIR/checklists/<domain>.md`

### Step 7: Critical Clarification (If Needed)

**Critical decisions** (ASK user - max 2 questions):
- Authentication model conflicts with existing system
- Data ownership unclear (who owns user data?)
- Real-time requirements ambiguous (WebSocket vs polling?)
- Breaking API changes to existing contracts
- Security/compliance requirements unclear
- Budget/cost constraints for cloud services

**Non-critical decisions** (ASSUME from context):
- Pagination style → Use existing API patterns
- Error format → Use existing error format
- Naming conventions → Follow codebase patterns
- UI patterns → Use design system
- Test framework → Use existing test setup
- Logging format → Use existing logging patterns

**If critical ambiguity detected**:
```text
⚠️ Critical Clarification Needed (1 of max 2)

Before proceeding, I need clarity on a decision that significantly impacts the feature:

Q1: [Critical question]

Context: [Why this matters]

Options:
| Option | Choice | Implications |
|--------|--------|--------------|
| A | [Option A] | [What this means] |
| B | [Option B] | [What this means] |

Your choice: _[Wait for user input]_
```

**If no critical ambiguities**: Proceed directly to analysis.

### Step 8: Run Analysis

1. **Execute analysis passes**:
   - Duplication detection
   - Ambiguity detection
   - Underspecification check
   - Constitution alignment
   - Coverage gap analysis
   - Inconsistency detection

2. **Analyze checklists**:
   - Perform quality analysis (ambiguity, alignment, testability)
   - Check cross-artifact consistency with spec/plan
   - Integrate findings into analysis report

3. **Generate compact analysis report**

This step MUST be performed by running the canonical command: `/speckit.analyze`

Quick-mode constraints while running `/speckit.analyze`:
- Ensure checklists in `FEATURE_DIR/checklists/` are included in the analysis (if present).
- Report only actionable issues; keep the final report compact.

### Step 9: Final Report

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ QUICK BUILD COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Feature: [Feature name]
Branch: [BRANCH_NAME]
Time: [Duration]

📁 Generated Artifacts:
├── [FEATURE_DIR]/
│   ├── spec.md ✓
│   ├── plan.md ✓
│   ├── tasks.md ✓
│   ├── [data-model.md] [✓ if created]
│   ├── [contracts/] [✓ if created]
│   └── checklists/
│       ├── requirements.md ✓
│       └── [auto-selected checklists...]

📊 Analysis Summary:
- Coverage: [Percentage]% of requirements have tasks
- Issues: [Count] critical, [Count] high, [Count] medium
- Checklist quality issues: [Count]

📝 Assumptions Made: [Count]
(See spec.md "Assumptions" section for full list with sources)

[If critical issues exist:]
⚠️ Action Recommended:
- [List critical issues to address]

🚀 Ready for Implementation!

Next: Run `/speckit.implement` to begin development

Alternative: Run `/speckit.build` for a more thorough guided review
```

## Assumptions Documentation

Every assumption MUST be documented with its source (prefer constitution/spec history/config/codebase; default only when necessary).

## When to Use `/speckit.quick` vs `/speckit.build`

| Scenario | Recommended Command |
|----------|---------------------|
| Clear requirements, experienced user | `/speckit.quick` |
| Complex feature, needs stakeholder review | `/speckit.build` |
| Prototype or MVP | `/speckit.quick` |
| New project, establishing patterns | `/speckit.build` |
| Following established project conventions | `/speckit.quick` |
| Novel feature type, many unknowns | `/speckit.build` |
| Time-constrained | `/speckit.quick` |
| Quality-critical | `/speckit.build` |

## Error Handling

- **No description**: Error with usage examples
- **No project context**: Warn and proceed with defaults (document heavily)
- **Tech stack conflicts**: Ask clarification (counts toward 2-question limit)
- **Script failures**: Report and suggest `/speckit.build` for step-by-step

## Examples

**Basic usage:**
```text
/speckit.quick Build a REST API for user management using Python/FastAPI
```

**With constraints:**
```text
/speckit.quick Add real-time chat feature using WebSockets, must support 1000 concurrent connections
```

**UI feature:**
```text
/speckit.quick Create a dashboard showing sales analytics with charts and filters using React/TypeScript
```

**Following existing patterns:**
```text
/speckit.quick Add password reset flow (similar to existing email verification)
```

