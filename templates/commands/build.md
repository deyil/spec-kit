---
description: Unified guided wizard that orchestrates the complete spec-driven workflow from description to ready-to-implement project.
handoffs: 
   - label: Start Implementation
      agent: speckit.implement
      prompt: Begin implementing the tasks
      send: true
   - label: View Status
      agent: speckit.status
      prompt: Show current workflow progress
scripts:
   sh: scripts/bash/create-new-feature.sh --json "{ARGS}"
   ps: scripts/powershell/create-new-feature.ps1 -Json "{ARGS}"
agent_scripts:
   sh: scripts/bash/update-agent-context.sh __AGENT__
   ps: scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

`/speckit.build` is a **guided wizard** that orchestrates the complete Spec-Driven Development workflow in a single command. It walks you through each phase with checkpoints for user confirmation, making it ideal for:

- New projects where thorough planning is important
- Complex features requiring stakeholder review
- Users who want guidance through each step
- Teams that need documentation at every phase

**Time estimate**: 10-15 minutes for a complete, well-documented project setup.

## Workflow Overview

## Orchestration Summary

This command MUST orchestrate the workflow by running these commands in order (with checkpoints as described below):

1. `/speckit.constitution` (only if missing / explicitly requested)
2. `/speckit.specify <description>`
3. `/speckit.clarify` (only if critical ambiguities remain)
4. `/speckit.plan <tech stack>`
5. `/speckit.tasks`
6. `/speckit.checklist` (one or more domains, fast mode)
7. `/speckit.analyze`

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                         /speckit.build Workflow                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. GATHER INPUTS                                                       │
│     ├── Feature description (from $ARGUMENTS or prompt)                 │
│     ├── Tech stack preferences                                          │
│     └── Key constraints/requirements                                    │
│                                                                         │
│  2. CONSTITUTION CHECK                                                  │
│     ├── Load /memory/constitution.md if exists                          │
│     ├── Offer to create if missing (interactive)                        │
│     └── Extract principles for constraint checking                      │
│                                                                         │
│  3. SPECIFICATION PHASE (/speckit.specify logic)                        │
│     ├── Generate spec.md from description                               │
│     ├── Identify critical ambiguities (max 5 questions)                 │
│     ├── ⏸️  CHECKPOINT: User reviews spec                                │
│     └── Update spec with clarifications                                 │
│                                                                         │
│  4. PLANNING PHASE (/speckit.plan logic)                                │
│     ├── Generate plan.md with architecture                              │
│     ├── Create data-model.md, contracts/ as needed                      │
│     ├── ⏸️  CHECKPOINT: User reviews plan                                │
│     └── Update agent context files                                      │
│                                                                         │
│  5. TASK GENERATION (/speckit.tasks logic)                              │
│     ├── Generate tasks.md with phased breakdown                         │
│     ├── Identify parallel execution opportunities                       │
│     └── ⏸️  CHECKPOINT: User reviews tasks                               │
│                                                                         │
│  6. CHECKLIST GENERATION (/speckit.checklist logic)                     │
│     ├── Auto-suggest checklist domain from artifacts                    │
│     ├── Ask 1-2 quick scoping questions (fast mode)                     │
│     └── Generate checklist file(s)                                      │
│                                                                         │
│  7. ANALYSIS PHASE (/speckit.analyze logic)                             │
│     ├── Cross-artifact consistency check                                │
│     ├── Coverage gap analysis                                           │
│     ├── Checklist quality analysis                                      │
│     └── Report with recommendations                                     │
│                                                                         │
│  8. COMPLETION                                                          │
│     ├── Summary of all generated artifacts                              │
│     ├── Next steps recommendation                                       │
│     └── Ready for /speckit.implement                                    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Execution Steps

## Delegation Rule (Bullet-Proofing)

This command is an **orchestrator**.

- For each phase below, you MUST **run the corresponding `/speckit.*` command** and follow the canonical instructions in `templates/commands/<command>.md`.
- Do **not** re-implement or paraphrase the internal logic of those commands here. Any improvements to the base commands should automatically flow into `/speckit.build`.

### Phase 1: Gather Inputs

1. **Parse user input**:
   - If `$ARGUMENTS` contains description AND tech stack: extract both
   - If `$ARGUMENTS` contains only description: will prompt for tech stack later
   - If `$ARGUMENTS` is empty: prompt for feature description

2. **Collect missing information** (only ask what's not provided):

   **If description missing:**
   ```text
   📝 What feature would you like to build?
   
   Describe the feature in natural language. Be as detailed or brief as you like.
   
   Example: "User authentication with OAuth2 support, email verification, 
   and password reset functionality"
   
   Your description: _[Wait for user input]_
   ```

   **If tech stack not provided:**
   
   **Step 1: Ask user for tech stack**
   ```text
   🛠️ What technologies will you use?
   
   Examples:
   - "Python with FastAPI and PostgreSQL"
   - "TypeScript, Next.js, Prisma, Vercel"
   - "Go with Chi router and MongoDB"
   
   Leave blank to auto-detect or let me recommend based on your feature.
   
   Tech stack: _[Wait for user input]_
   ```
   
   **Step 2: If user provides no input, attempt auto-detection**
   - Check `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, etc.
   - Scan existing directory structure for patterns
   - Review existing specs for established patterns
   - If tech stack detected, proceed with it
   
   **Step 3: If auto-detection fails, analyze and recommend**
   - Review the feature description for technical implications
   - Consider complexity, scalability needs, and common patterns
   - Factor in any constraints mentioned by the user
   - Present a recommended stack with brief rationale:
   
   ```text
   🛠️ Tech Stack Recommendation
   
   I couldn't detect an existing tech stack. Based on your feature requirements, I recommend:
   
   **[Recommended Stack]** (e.g., Python with FastAPI and PostgreSQL)
   
   Rationale:
   - [Reason 1 based on feature needs]
   - [Reason 2 based on complexity/scale]
   - [Reason 3 based on ecosystem/tooling]
   
   Options:
   | Option | Action |
   |--------|--------|
   | Accept | Use recommended stack |
   | Modify | Specify different technologies |
   
   Your choice: _[Wait for user input, default to Accept]_
   ```
   
   - If user accepts or doesn't respond: proceed with recommended stack
   - If user provides alternative: use their specified stack

   **Optional constraints prompt:**
   ```text
   ⚠️ Any key constraints or requirements? (optional)
   
   Examples:
   - "Must support 10k concurrent users"
   - "Needs HIPAA compliance"
   - "Must integrate with existing auth system"
   - "Budget limit: no paid services"
   
   Constraints (press Enter to skip): _[Wait for user input]_
   ```

### Phase 2: Constitution Check

1. **Check for existing constitution**:
   - Load `/memory/constitution.md` if it exists
   - Extract all principles and constraints

2. **If constitution missing**, offer to create:
   ```text
   📜 No project constitution found.
   
   A constitution defines your project's guiding principles and non-negotiables.
   It helps maintain consistency across features.
   
   Options:
   | Option | Action | Recommended For |
   |--------|--------|-----------------|
   | A | Create constitution now (5 min) | New projects, teams |
   | B | Skip for this feature | Quick prototypes |
   | C | Use default principles | Solo developers |
   
   Your choice: _[Wait for user input]_
   ```

   - **If A**: Run constitution creation workflow inline, then continue
   - **If B**: Proceed without constitution (note in spec)
   - **If C**: Apply default principles (document as assumptions)

3. **Constitution principles extracted for later validation**

### Phase 3: Specification Phase

**Run the canonical command:** `/speckit.specify <feature description>`

Then apply these orchestration-only behaviors (without rewriting `/speckit.specify`):

1. **Generate branch and spec file**:
   - Generate short name from description
   - Check for existing branches (remote, local, specs directories)
   - Run `{SCRIPT}` with calculated number and short-name
   - Parse JSON output for BRANCH_NAME and SPEC_FILE paths

2. **Generate specification**:
   - Load `templates/spec-template.md`
   - Fill all sections based on feature description
   - Apply constitution constraints where applicable
   - Mark critical unknowns with `[NEEDS CLARIFICATION]` (max 3)

3. **Clarification pass** (if needed):
   - If any `[NEEDS CLARIFICATION]` markers exist, present questions
   - Use table format with options and implications
   - Update spec with user's answers

4. **⏸️ CHECKPOINT - Specification Review**:
   ```text
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ⏸️  CHECKPOINT: Specification Review
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   
   📄 Specification created: [SPEC_FILE path]
   
   Key elements:
   - Feature: [Feature name]
   - User stories: [Count]
   - Functional requirements: [Count]
   - Success criteria: [Count]
   
   Options:
   | Option | Action |
   |--------|--------|
   | Continue | Proceed to planning phase |
   | Edit | Make changes to the spec (describe what) |
   | Clarify | Ask more questions about requirements |
   | Abort | Stop the build process |
   
   Your choice: _[Wait for user input]_
   ```

   - **Continue**: Proceed to Phase 4
   - **Edit**: Apply user's requested changes, re-validate, re-checkpoint
   - **Clarify**: Ask additional clarification questions, update spec
   - **Abort**: Stop workflow, preserve created files

### Phase 4: Planning Phase

**Run the canonical command:** `/speckit.plan <tech stack>`

Then apply these orchestration-only behaviors (without rewriting `/speckit.plan`):

1. **Setup**: Run the setup script to get paths
2. **Load context**: Read spec.md and constitution.md
3. **Generate planning artifacts**:
   - Fill IMPL_PLAN template with technical context
   - Generate `research.md` if unknowns exist
   - Generate `data-model.md` for entities
   - Generate `contracts/` for API specifications
   - Generate `quickstart.md` for test scenarios

4. **Update agent context**:
   - Run `{AGENT_SCRIPT}` to update AI agent files

5. **⏸️ CHECKPOINT - Plan Review**:
   ```text
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ⏸️  CHECKPOINT: Plan Review
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   
   📋 Planning artifacts created:
   - plan.md: Technical architecture and phases
   - data-model.md: Entity definitions [if applicable]
   - contracts/: API specifications [if applicable]
   - research.md: Technical decisions [if applicable]
   
   Architecture highlights:
   - Tech stack: [Summary]
   - Key components: [List]
   - Integration points: [List]
   
   Options:
   | Option | Action |
   |--------|--------|
   | Continue | Proceed to task generation |
   | Edit | Make changes to the plan (describe what) |
   | Back | Return to specification phase |
   | Abort | Stop the build process |
   
   Your choice: _[Wait for user input]_
   ```

### Phase 5: Task Generation

**Run the canonical command:** `/speckit.tasks`

Then apply these orchestration-only behaviors (without rewriting `/speckit.tasks`):

1. **Load design documents**: Read all available artifacts
2. **Generate tasks.md**:
   - Extract user stories with priorities
   - Map components to stories
   - Generate phased task breakdown
   - Identify parallel execution opportunities
   - Create dependency graph

3. **⏸️ CHECKPOINT - Tasks Review**:
   ```text
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ⏸️  CHECKPOINT: Tasks Review
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   
   📝 Task breakdown created: tasks.md
   
   Summary:
   - Total tasks: [Count]
   - Setup phase: [Count] tasks
   - Foundational phase: [Count] tasks
   - User story phases: [Count] phases, [Count] tasks
   - Polish phase: [Count] tasks
   - Parallel opportunities: [Count] tasks marked [P]
   
   Options:
   | Option | Action |
   |--------|--------|
   | Continue | Proceed to checklist generation |
   | Edit | Modify task breakdown (describe what) |
   | Back | Return to planning phase |
   | Abort | Stop the build process |
   
   Your choice: _[Wait for user input]_
   ```

### Phase 6: Checklist Generation (Fast Mode)

**Run the canonical command:** `/speckit.checklist` (repeat once per selected domain)

Then apply these orchestration-only behaviors (without rewriting `/speckit.checklist`):

1. **Auto-suggest checklist domain(s)**:
   - Analyze generated artifacts for domain indicators
   - Suggest 1-3 relevant checklist types based on:
     - API endpoints present → suggest `api.md`
     - UI/UX requirements → suggest `ux.md`
     - Security requirements → suggest `security.md`
     - Performance requirements → suggest `performance.md`

2. **Fast-mode scoping (max 2 questions)**:
   ```text
   📋 Checklist Generation (Fast Mode)
   
   Based on your feature, I recommend generating these checklists:
   - [x] requirements.md (always included - validates spec quality)
   - [ ] api.md (detected API requirements)
   - [ ] ux.md (detected UI requirements)
   
   Q1: Which additional checklists would you like? (Enter letters, e.g., "A,B")
   
   | Option | Checklist | Reason |
   |--------|-----------|--------|
   | A | api.md | [Count] API endpoints detected |
   | B | ux.md | [Count] UI components detected |
   | C | security.md | Auth/security requirements present |
   | D | Skip additional | Only requirements.md |
   
   Your choice: _[Wait for user input]_
   ```

3. **Run `/speckit.checklist` once per selected checklist**:
   - Always generate the baseline requirements-quality checklist first (creates `FEATURE_DIR/checklists/requirements.md`).
   - For each additional selection (api/ux/security/performance), run `/speckit.checklist` again for that domain (creates or appends `FEATURE_DIR/checklists/<domain>.md`).
   - Keep the checklist command in **fast-mode**:
     - Prefer defaults for depth/audience/focus areas when unambiguous
     - Do not ask more than **2** scoping questions per run
   - Each invocation must follow the checklist template format.

### Phase 7: Analysis Phase

**Run the canonical command:** `/speckit.analyze`

Then apply these orchestration-only behaviors (without rewriting `/speckit.analyze`):

1. **Load all artifacts**: spec.md, plan.md, tasks.md
2. **Run analysis passes**:
   - Duplication detection
   - Ambiguity detection
   - Underspecification check
   - Constitution alignment
   - Coverage gap analysis
   - Inconsistency detection

3. **Analyze checklists** (enhanced analyze feature):
   - Read all files in `FEATURE_DIR/checklists/`
   - Perform quality analysis (ambiguity, alignment, testability)
   - Check cross-artifact consistency with spec/plan
   - Integrate findings into main analysis report

4. **Generate analysis report**:
   - Findings table with severity
   - Coverage summary
   - Checklist quality findings
   - Recommendations

5. **Present analysis summary** (no checkpoint - informational):
   ```text
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   📊 Analysis Complete
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   
   Consistency Check:
   - Critical issues: [Count]
   - High issues: [Count]  
   - Medium issues: [Count]
   - Low issues: [Count]
   
   Coverage:
   - Requirements with tasks: [Percentage]%
   - Unmapped tasks: [Count]
   
   Checklist Quality:
   - Total validation items analyzed: [Count]
   - Quality issues found: [Count]
   - Critical checklist gaps: [Count]
   (See full analysis report for details)
   
   [If critical issues exist, list them and recommend resolution]
   ```

### Phase 8: Completion

1. **Generate final summary**:
   ```text
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ✅ BUILD COMPLETE
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   
   Feature: [Feature name]
   Branch: [BRANCH_NAME]
   
   📁 Generated Artifacts:
   ├── [FEATURE_DIR]/
   │   ├── spec.md ✓
   │   ├── plan.md ✓
   │   ├── tasks.md ✓
   │   ├── data-model.md [✓ if created]
   │   ├── research.md [✓ if created]
   │   ├── contracts/ [✓ if created]
   │   └── checklists/
   │       ├── requirements.md ✓
   │       └── [additional checklists...]
   
   📊 Quality Summary:
   - Analysis issues: [Count] critical, [Count] high, [Count] medium
   - Checklist quality issues: [Count]
   - Coverage: [Percentage]% of requirements have tasks
   
   🚀 Ready for Implementation!
   
   Next steps:
   1. Review generated artifacts (links above)
   2. Address any critical analysis issues (if any)
   3. Run `/speckit.implement` to begin development
   
   Suggested commit:
   git add .specify/specs/[feature-dir]
   git commit -m "feat: add specification for [feature name]"
   ```

2. **Offer handoffs**:
   - `/speckit.implement` - Start building
   - `/speckit.status` - View current progress
   - `/speckit.analyze` - Re-run analysis if changes made

## Error Handling

- **Missing prerequisites**: Guide user to resolve (e.g., no git repo → suggest `git init`)
- **Script failures**: Report error, suggest manual steps
- **User abort**: Preserve all created files, report what was completed
- **Validation failures**: Offer to fix or proceed with warnings

## Tips

- Use inline description + tech stack for faster flow: `/speckit.build User auth with OAuth2 using Python/FastAPI`
- Review each checkpoint carefully - changes are easier before implementation
- The analysis phase helps catch issues early - address critical findings
- Checklists are optional but valuable for complex features
