# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal collection of Claude Code commands, sub-agents, and skills that form a comprehensive workflow system for software development. The project implements an agent-based architecture where specialized AI agents collaborate to research codebases, plan implementations, and manage stacked pull requests.

**Key Concept**: This is NOT a traditional codebase with runtime code. It's a configuration and specification repository that extends Claude Code's capabilities through markdown documents and shell scripts.

## Architecture

The system follows a **command-agent-skill pattern**:

- **Commands** (`.claude/commands/*.md`): Entry points invoked via slash commands (e.g., `/research_codebase`)
- **Agents** (`.claude/agents/*.md`): Specialized sub-agents spawned for specific research tasks
- **Skills** (`.claude/skills/*/SKILL.md`): Integrated tools for specific actions (e.g., stacked PRs)
- **Scripts** (`.claude/scripts/*.sh`): Utility functions for metadata collection and output formatting

### Agent Collaboration Model

Commands spawn multiple agents in parallel for efficiency:

```
/research_codebase
  └─> Spawns: codebase-locator + codebase-analyzer + thoughts-locator (parallel)
      └─> Results synthesized into research document

/create_plan
  └─> Spawns: codebase-locator + codebase-analyzer + pattern-finder (parallel)
      └─> Results synthesized into implementation plan
```

Each agent is a specialist that returns focused results with file:line references.

## Available Commands

### `/research_codebase`
Document the codebase as-is with thoughts directory for historical context.

**Purpose**: Comprehensive codebase research through parallel sub-agent spawning
**Output**: Research documents in `thoughts/shared/research/YYYY-MM-DD-ENG-XXXX-description.md`
**Key Features**:
- Spawns specialized agents (locator, analyzer, pattern-finder) in parallel
- Creates documentation with YAML frontmatter and GitHub permalinks
- Syncs via `humanlayer thoughts sync`
- Supports follow-up questions with document updates

**Usage**:
```bash
/research_codebase
# Then provide your research question when prompted
```

**Critical Philosophy**: Document ONLY what exists. Do NOT suggest improvements, critique implementation, or recommend changes unless explicitly asked. You are a documentarian, not an evaluator.

### `/create_plan`
Create detailed implementation plans through interactive research and iteration.

**Purpose**: Interactive planning with skeptical questioning and thorough research
**Output**: Implementation plans in `thoughts/shared/plans/YYYY-MM-DD-ENG-XXXX-description.md`
**Key Features**:
- Reads ticket files fully before spawning research
- Spawns parallel agents to understand current implementation
- Iterative collaboration with user for design decisions
- Designed for stacked PR workflow (each phase = one PR)
- Separates automated vs manual verification steps

**Usage**:
```bash
/create_plan thoughts/elliot/tickets/eng_1234.md
# or
/create_plan
# Then provide task description when prompted
```

**Stacked PR Philosophy**: Each phase should be:
- <300 lines of changes for reviewability
- Independently testable and deployable
- Part of a coherent implementation journey
- Clear in dependencies and purpose

**Success Criteria Guidelines**:
- Always use `just` commands (e.g., `just check-test` instead of `uv run pytest && ruff check`)
- Separate automated (CI can run) from manual (human testing required) criteria
- Focus on context efficiency - use commands with built-in backpressure

### `/implement_plan`
Implement technical plans from thoughts/shared/plans with verification.

**Purpose**: Execute approved plans with phased approach and stacked PR management
**Key Features**:
- Reads plan files and implements each phase sequentially
- Validates success criteria (automated) after each phase
- Pauses for manual verification between phases
- Uses `stacked-pr` skill for PR creation
- Supports resuming in-progress stacks

**Usage**:
```bash
/implement_plan thoughts/shared/plans/2025-01-08-ENG-1234-feature.md
```

## Available Agents

### codebase-locator
Finds WHERE files and components live in the codebase.
- Locates by feature/topic/component
- Returns organized file paths (no reading)
- Use for: "Find all files related to X"

### codebase-analyzer
Understands HOW code works.
- Reads and traces code flow
- Documents implementation details with file:line references
- Use for: "Explain how X works"

### codebase-pattern-finder
Finds similar implementations and examples.
- Locates comparable features
- Extracts reusable patterns
- Use for: "Show me examples of X pattern"

### thoughts-locator
Discovers documents in `thoughts/` directory.
- Searches research, tickets, plans, PRs
- Handles `searchable/` directory hard links correctly
- Use for: "Find historical context about X"

### thoughts-analyzer
Extracts high-value insights from documents.
- Filters aggressively (no noise)
- Validates relevance and temporal context
- Use for: "What are key decisions about X?"

### ticket-writer
Manages engineering tickets.
- Creates tickets from thoughts documents
- Updates ticket status and adds comments
- Integrates with Linear

## Available Skills

### stacked-pr
Creates and manages stacked pull requests using git-town.

**Purpose**: Manage stacked PR workflow where each implementation phase = one PR
**Scripts**: `new-stack.sh` (Phase 1), `append-stack.sh` (Phase N)
**Integration**: Used by `/implement_plan` after completing each phase

## Directory Structure

```
.claude/
  agents/          # Sub-agent specifications (6 agents)
  commands/        # Slash command implementations (3 commands)
  scripts/         # Shell utilities (3 scripts)
  skills/          # Integrated skills (1 skill: stacked-pr)
.claude-plugin/    # Marketplace configuration
thoughts/          # Research documents, plans, tickets (if exists)
  shared/
    research/      # Research documents from /research_codebase
    plans/         # Implementation plans from /create_plan
    prs/           # PR documentation
  searchable/      # Hard links for searching (paths should strip this)
```

## Development Philosophy

### Core Principles

1. **Documentation Over Everything**
   - Research commands document what EXISTS, not what SHOULD BE
   - No recommendations unless explicitly requested
   - Agents are "documentarians, not critics"

2. **Parallel Processing for Efficiency**
   - Spawn multiple agents concurrently
   - Reduces context token usage through focused investigation
   - Each agent has single responsibility

3. **Stacked PR Workflow**
   - Each implementation phase = one atomic PR
   - Phases designed for <300 lines (easier review)
   - Sequential dependencies enable guided journey
   - Each phase independently testable

4. **Interactive, Iterative Process**
   - Constant user interaction and feedback loops
   - Skeptical questioning of vague requirements
   - No "open questions" in final plans

5. **Context Efficiency**
   - Use `just` commands (built-in backpressure)
   - Prefer `just check-test` over raw tool commands
   - Clean output via `run_silent.sh` wrapper

### File Reading Rules

When working with this system:
- **Always read files FULLY** (no limit/offset parameters)
- Read mentioned files in main context BEFORE spawning sub-tasks
- Never write documents with placeholder values
- Wait for ALL sub-agents to complete before synthesizing

### Path Handling

The `thoughts/searchable/` directory contains hard links for searching:
- Always remove "searchable/" from paths when documenting
- Preserve all other subdirectories exactly
- Examples:
  - `./thoughts/searchable/shared/research/foo.md` → `./thoughts/shared/research/foo.md`
  - `./thoughts/searchable/elliot/tickets/bar.md` → `./thoughts/elliot/tickets/bar.md`

## Common Development Tasks

This repository has no build/test commands since it's purely configuration. However, the system assumes target codebases use:

- **git-town**: Stack management for pull requests
- **gh**: GitHub CLI for PR creation
- **just**: Task runner (preferred over raw commands)
- **humanlayer**: Thoughts directory synchronization (`humanlayer thoughts sync`)

## Working with Plans

### Plan Structure

Plans use this filename format: `YYYY-MM-DD-ENG-XXXX-description.md`

Each plan includes:
- YAML frontmatter with metadata
- Overview and current state analysis
- "What We're NOT Doing" (scope boundaries)
- Multiple phases with PR context
- Success criteria (automated + manual)
- Testing strategy and references

### Stacked PR Patterns

**Database Changes**:
1. Schema/migration + tests (foundation)
2. Store methods + unit tests (data layer)
3. Business logic updates (application layer)
4. API endpoints + integration tests (interface layer)
5. Client updates (consumer layer)

**New Features**:
1. Research + data model + tests (foundation)
2. Core backend logic + unit tests (business logic)
3. API endpoints + integration tests (interface)
4. UI implementation + component tests (presentation)
5. E2E tests + documentation (validation)

**Refactoring**:
1. Add tests for current behavior (safety net)
2. Extract/refactor internal implementation (no API changes)
3. Update API surface if needed (interface changes)
4. Update consumers + deprecation (migration)
5. Remove old code (cleanup)

## Metadata Collection

Use `.claude/scripts/spec_metadata.sh` to collect:
- Git commit hash, branch, user
- Current timestamp with timezone
- Repository name
- Thoughts directory status

This metadata populates frontmatter in research documents and plans.

## Integration Points

### HumanLayer Integration
- Research documents and plans sync via `humanlayer thoughts sync`
- Ticket writer integrates with Linear project management
- Thoughts directory provides historical context

### GitHub Integration
- Research documents include GitHub permalinks when on main/pushed commits
- Stacked PRs managed via git-town and gh CLI
- PR descriptions auto-generated with stack context

## License

MIT License - See LICENSE file for details
