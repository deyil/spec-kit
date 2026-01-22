````markdown
---
description: Show workflow progress and next steps for the current feature.
scripts:
  sh: scripts/bash/check-prerequisites.sh --json
  ps: scripts/powershell/check-prerequisites.ps1 -Json
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

`/speckit.status` provides a clear view of your current feature's progress through the Spec-Driven Development workflow. It answers:

- "What artifacts exist?"
- "What's my current progress?"
- "What should I do next?"

## Execution Steps

### Step 1: Detect Feature Context

1. **Run setup script** to detect current feature:
   ```text
   Run `{SCRIPT}` from repo root and parse JSON for FEATURE_DIR
   ```

2. **If no feature detected**, check for any existing specs:
   - List directories in `.specify/specs/`
   - If multiple features exist, list them for user to choose
   - If no features exist, report clean slate

3. **If `$ARGUMENTS` contains a feature name/number**, use that to locate the feature directory.

### Step 2: Scan Artifacts

Check for existence of each artifact in FEATURE_DIR:

| Artifact | Path | Status Symbols |
|----------|------|----------------|
| Constitution | `/memory/constitution.md` | ✓ exists / ○ missing |
| Specification | `FEATURE_DIR/spec.md` | ✓ exists / ○ missing |
| Plan | `FEATURE_DIR/plan.md` | ✓ exists / ○ missing |
| Tasks | `FEATURE_DIR/tasks.md` | ✓ exists / ○ missing |
| Data Model | `FEATURE_DIR/data-model.md` | ✓ exists / ○ optional (not required) |
| Contracts | `FEATURE_DIR/contracts/` | ✓ exists / ○ optional |
| Research | `FEATURE_DIR/research.md` | ✓ exists / ○ optional |
| Checklists | `FEATURE_DIR/checklists/` | (detailed below) |

### Step 3: Analyze Checklists (if present)

If `FEATURE_DIR/checklists/` directory exists:

1. **List all `.md` files** in the directory
2. **For each checklist file**:
   - Count total items: Lines matching `- [ ]` or `- [X]` or `- [x]`
   - Count completed: Lines matching `- [X]` or `- [x]`
   - Count incomplete: Lines matching `- [ ]`
   - Calculate percentage complete

3. **Determine checklist status**:
   - ✓ = All items complete (100%)
   - ⚠ = Partially complete (has incomplete items)
   - ○ = Not started (0% or doesn't exist)

### Step 4: Analyze Tasks Progress (if tasks.md exists)

1. **Count task completion**:
   - Total tasks: Lines matching `- [ ]` or `- [X]` or `- [x]` with task IDs
   - Completed: Lines matching `- [X]` or `- [x]`
   - In progress: Infer from recent file changes (optional)

2. **Identify current phase**:
   - Find the first incomplete task
   - Determine which phase it belongs to

### Step 5: Determine Workflow Stage

Based on artifact existence, determine the current stage:

```text
STAGE 1: Not Started
  - No spec.md exists
  - Next: /speckit.specify or /speckit.build or /speckit.quick

STAGE 2: Specified
  - spec.md exists
  - No plan.md
  - Next: /speckit.plan

STAGE 3: Planned
  - spec.md and plan.md exist
  - No tasks.md
  - Next: /speckit.tasks

STAGE 4: Ready to Implement
  - spec.md, plan.md, tasks.md exist
  - Tasks not started (all - [ ])
  - Next: /speckit.implement

STAGE 5: In Progress
  - Some tasks completed (- [x] or - [X])
  - Not all tasks complete
  - Next: Continue /speckit.implement

STAGE 6: Complete
  - All tasks marked complete
  - Next: Review, test, merge
```

### Step 6: Generate Status Report

**If no feature exists:**
```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SPEC KIT STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

No features found in this project.

Getting Started:
├── /speckit.build   - Guided wizard for new features (recommended)
├── /speckit.quick   - Fast path for clear requirements
└── /speckit.specify - Create specification only

Constitution:
└── [✓ exists / ○ missing - recommend creating first]

```

**If feature exists:**
```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 FEATURE STATUS: [Feature Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Branch: [BRANCH_NAME]
Directory: [FEATURE_DIR]

Workflow Progress:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [✓] Constitution     /memory/constitution.md
  [✓] Specification    [FEATURE_DIR]/spec.md
  [✓] Plan             [FEATURE_DIR]/plan.md
  [○] Tasks            Not created
  [○] Implementation   Not started

Optional Artifacts:
  [✓] Data Model       [FEATURE_DIR]/data-model.md
  [✓] Contracts        [FEATURE_DIR]/contracts/ (3 files)
  [○] Research         Not created

Checklists:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| Checklist | Progress | Status |
|-----------|----------|--------|
| requirements.md | 12/12 (100%) | ✓ Complete |
| api.md | 8/10 (80%) | ⚠ 2 incomplete |
| security.md | 5/8 (63%) | ⚠ 3 incomplete |

[If tasks.md exists with progress:]
Task Progress:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| Phase | Progress | Status |
|-------|----------|--------|
| Setup | 4/4 | ✓ Complete |
| Foundational | 3/5 | ⚠ In Progress |
| US1: User Auth | 0/8 | ○ Not Started |
| US2: Profile | 0/6 | ○ Not Started |
| Polish | 0/3 | ○ Not Started |

Overall: 7/26 tasks (27%)

Next Step:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Run `/speckit.tasks` to generate task breakdown

[Or if tasks exist but implementation not started:]
Run `/speckit.implement` to begin development

[Or if implementation in progress:]
Continue with `/speckit.implement` (currently in Foundational phase)

```

**If multiple features exist and none specified:**
```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SPEC KIT STATUS - Multiple Features Found
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found [N] features in this project:

| # | Feature | Branch | Stage | Progress |
|---|---------|--------|-------|----------|
| 1 | 001-user-auth | 001-user-auth | Ready | 0/24 tasks |
| 2 | 002-notifications | 002-notifications | In Progress | 12/18 tasks |
| 3 | 003-dashboard | 003-dashboard | Planned | - |

To see details for a specific feature:
  /speckit.status 001-user-auth
  /speckit.status 2

Current branch: [current git branch if matches a feature]

```

### Step 7: Provide Contextual Guidance

Based on current stage, provide specific guidance:

**Stage 1 (Not Started):**
```text
Recommended Actions:
1. Create a project constitution: /speckit.constitution
2. Start a new feature:
   - /speckit.build <description>  (guided, thorough)
   - /speckit.quick <description>  (fast, automated)
   - /speckit.specify <description> (spec only)
```

**Stage 2 (Specified):**
```text
Recommended Actions:
1. Review spec.md for completeness
2. Create implementation plan: /speckit.plan <tech stack>
   Or use: /speckit.clarify to refine requirements first
```

**Stage 3 (Planned):**
```text
Recommended Actions:
1. Review plan.md and generated artifacts
2. Generate task breakdown: /speckit.tasks
3. Optional: Create quality checklists: /speckit.checklist
```

**Stage 4 (Ready to Implement):**
```text
Recommended Actions:
1. Optional: Run consistency check: /speckit.analyze
2. Optional: Create checklists: /speckit.checklist
3. Begin implementation: /speckit.implement

[If checklists have incomplete items:]
⚠ Note: Some checklists have incomplete items. Review before implementation.
```

**Stage 5 (In Progress):**
```text
Current Progress:
- Phase: [Current phase name]
- Next task: [T0XX] [Task description]

Recommended Actions:
1. Continue implementation: /speckit.implement
2. Check consistency: /speckit.analyze
3. Review progress: (you're here!)
```

**Stage 6 (Complete):**
```text
🎉 All tasks complete!

Recommended Actions:
1. Run final consistency check: /speckit.analyze
2. Verify all checklists are complete
3. Review implementation against spec
4. Create PR and merge
```

## Error Handling

- **No `.specify/` directory**: Report that Spec Kit hasn't been initialized
- **Script failure**: Fall back to manual file detection
- **Ambiguous feature**: List all features and ask for clarification

## Examples

**Check current feature status:**
```text
/speckit.status
```

**Check specific feature:**
```text
/speckit.status 001-user-auth
```

**Check by number:**
```text
/speckit.status 2
```

````
