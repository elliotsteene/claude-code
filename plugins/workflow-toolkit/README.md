# Workflow Toolkit Plugin

Comprehensive development workflow system for Claude Code that enables systematic codebase research, interactive implementation planning, and stacked PR management through specialized AI agents.

## Overview

This plugin provides a complete workflow for software development with Claude Code:

1. **Research Phase**: Document codebases systematically through parallel agent collaboration
2. **Planning Phase**: Create detailed implementation plans with interactive iteration
3. **Implementation Phase**: Execute plans with phased approach and automated verification
4. **PR Management**: Create and manage stacked pull requests automatically

## Features

### 🔍 Codebase Research (`/research_codebase`)

Spawn specialized agents in parallel to thoroughly research and document your codebase:

- **codebase-locator**: Finds WHERE files and components live
- **codebase-analyzer**: Understands HOW code works
- **codebase-pattern-finder**: Discovers similar implementations and patterns
- **thoughts-locator**: Searches historical context in thoughts directory
- **thoughts-analyzer**: Extracts high-value insights from documents

Creates comprehensive research documents with GitHub permalinks and YAML frontmatter.

### 📋 Implementation Planning (`/create_plan`)

Interactive planning workflow with:

- Skeptical questioning of vague requirements
- Parallel research of current implementation
- Stacked PR phase design (<300 lines per PR)
- Automated and manual verification criteria
- Integration with ticket systems

Generates detailed plans in `thoughts/shared/plans/` directory.

### ⚙️ Plan Implementation (`/implement_plan`)

Execute approved plans with:

- Sequential phase implementation
- Automated verification after each phase (`just check-test`)
- Manual verification checkpoints
- Automatic stacked PR creation
- Resume capability for in-progress stacks

### 🔗 Stacked PR Management (skill: `stacked-pr`)

Create and manage stacked pull requests using git-town:

- **Phase 1**: Starts new stack from main
- **Phase N**: Appends to existing stack
- Automatic base branch management
- Stack synchronization after PR creation
- Thoughts directory exclusion

### 🤫 Silent Execution (skill: `silent-execution`)

Context-efficient command execution:

- Automatically wraps verbose commands (pytest, ruff, builds)
- Minimal output on success, full output on failure
- 80-95% reduction in context usage
- Proactive (Claude uses automatically)

### 🎫 Ticket Management (agent: `ticket-writer`)

Manages engineering tickets:

- Creates tickets from thoughts documents
- Updates ticket status and adds comments
- Integrates with Linear project management

## Installation

### Prerequisites

This plugin requires the following tools to be installed:

#### Required Dependencies

1. **git-town** - Stack management for pull requests
   ```bash
   brew install git-town  # macOS
   ```
   [Installation guide](https://www.git-town.com/install)

2. **gh** - GitHub CLI for PR creation
   ```bash
   brew install gh  # macOS
   ```
   [Installation guide](https://cli.github.com/manual/installation)

3. **humanlayer** - Thoughts directory synchronization
   ```bash
   pip install humanlayer
   ```
   [Installation guide](https://docs.humanlayer.dev/installation)

#### Optional Dependencies

4. **just** - Task runner (recommended for better command ergonomics)
   ```bash
   brew install just  # macOS
   ```
   [Installation guide](https://just.systems/man/en/chapter_4.html)

### Plugin Installation

Install this plugin using Claude Code:

```bash
# From this repository
cc --plugin-dir /path/to/plugins/workflow-toolkit

# Or copy to your project
cp -r plugins/workflow-toolkit /path/to/your-project/.claude-plugin/
```

The setup-validation hook will check for dependencies on first use.

## Usage

### Research Workflow

```bash
# Start research
/research_codebase

# Claude asks: "What would you like to research?"
# You respond with your question
```

Claude will:
1. Read any mentioned files fully
2. Spawn parallel research agents
3. Wait for all agents to complete
4. Synthesize findings into a research document
5. Add GitHub permalinks (if on main branch)
6. Sync with `humanlayer thoughts sync`

**Example Research Questions:**
- "How does user authentication work?"
- "Where is the payment processing implemented?"
- "What patterns do we use for API error handling?"

### Planning Workflow

```bash
# Create plan from ticket
/create_plan thoughts/elliot/tickets/eng_1234.md

# Or create plan from description
/create_plan
```

Claude will:
1. Read ticket file fully (if provided)
2. Ask clarifying questions
3. Research current implementation
4. Design implementation phases
5. Propose success criteria
6. Generate plan document

**Plan Structure:**
- Each phase = one PR (<300 lines)
- Automated verification (CI can run)
- Manual verification (human testing)
- Clear dependencies and purpose

### Implementation Workflow

```bash
# Implement approved plan
/implement_plan thoughts/shared/plans/2025-01-08-ENG-1234-feature.md
```

Claude will:
1. Read plan fully
2. Implement Phase 1
3. Run automated verification
4. Pause for manual verification
5. Create stacked PR automatically
6. Move to Phase 2
7. Repeat until complete

### Stacked PR Creation

After completing a phase and verification:

```bash
# Phase 1 (from main branch)
just new-stack "1" "websocket-foundation" "feat: Add WebSocket foundation..." "Phase 1: WebSocket Foundation" "PR body..."

# Phase 2+ (from previous phase branch)
just append-stack "2" "message-parser" "feat: Add message parser..." "Phase 2: Message Parser" "PR body..."
```

Or let Claude handle it automatically during `/implement_plan`.

### Context-Efficient Execution

Claude automatically uses silent execution for verbose commands:

```bash
# Claude runs this automatically
${CLAUDE_PLUGIN_ROOT}/scripts/smart_wrap.sh "uv run pytest tests/"

# Output on success:
#   ✓ Running tests (45 tests, in 2.3s)

# Output on failure:
#   ✗ Running tests
#   Command failed: uv run pytest tests/
#   [full error output...]
```

## Architecture

### Command-Agent-Skill Pattern

```
Commands (slash commands)
  ├── /research_codebase
  ├── /create_plan
  └── /implement_plan

Agents (specialized sub-agents)
  ├── codebase-locator
  ├── codebase-analyzer
  ├── codebase-pattern-finder
  ├── thoughts-locator
  ├── thoughts-analyzer
  └── ticket-writer

Skills (integrated capabilities)
  ├── stacked-pr
  └── silent-execution

Scripts (utility functions)
  ├── spec_metadata.sh
  ├── smart_wrap.sh
  └── run_silent.sh
```

### Agent Collaboration

Commands spawn multiple agents in parallel for efficiency:

```
/research_codebase
  └─> Spawns: codebase-locator + codebase-analyzer + thoughts-locator (parallel)
      └─> Results synthesized into research document

/create_plan
  └─> Spawns: codebase-locator + codebase-analyzer + pattern-finder (parallel)
      └─> Results synthesized into implementation plan
```

### Philosophy

1. **Documentation Over Everything**: Research documents what EXISTS, not what SHOULD BE
2. **Parallel Processing**: Spawn multiple agents to reduce context usage
3. **Stacked PR Workflow**: Each phase = atomic, reviewable PR
4. **Interactive Iteration**: Constant user feedback loops
5. **Context Efficiency**: Use silent execution and focused agents

## Directory Structure

```
workflow-toolkit/
  agents/
    ├── codebase-locator.md
    ├── codebase-analyzer.md
    ├── codebase-pattern-finder.md
    ├── thoughts-locator.md
    ├── thoughts-analyzer.md
    └── ticket-writer.md
  commands/
    ├── research_codebase.md
    ├── create_plan.md
    └── implement_plan.md
  scripts/
    ├── spec_metadata.sh
    ├── smart_wrap.sh
    └── run_silent.sh
  skills/
    ├── stacked-pr/
    │   ├── SKILL.md
    │   └── scripts/
    │       ├── new-stack.sh
    │       └── append-stack.sh
    └── silent-execution/
        └── SKILL.md
  hooks/
    └── hooks.json (setup-validation)
  README.md
  INSTALLATION.md
  LICENSE
  plugin.json
  .gitignore
```

## Configuration

### Git Town Setup

Configure git-town for your repository:

```bash
git config git-town.main-branch main
git config git-town.sync-strategy merge
```

### Thoughts Directory

The plugin integrates with HumanLayer's thoughts directory pattern:

```
thoughts/
  shared/
    research/    # Research documents from /research_codebase
    plans/       # Implementation plans from /create_plan
    prs/         # PR documentation
  searchable/    # Hard links for searching (auto-managed)
```

Sync thoughts directory:

```bash
humanlayer thoughts sync
```

### Justfile Commands

For better ergonomics, add to your `justfile`:

```makefile
# Check and test
check-test:
    uv run pytest
    uv run ruff check .
    uv run ruff format --check .

# Stacked PR commands
new-stack phase branch-name commit-msg pr-title pr-body:
    ${CLAUDE_PLUGIN_ROOT}/skills/stacked-pr/scripts/new-stack.sh "{{phase}}" "{{branch-name}}" "{{commit-msg}}" "{{pr-title}}" "{{pr-body}}"

append-stack phase branch-name commit-msg pr-title pr-body:
    ${CLAUDE_PLUGIN_ROOT}/skills/stacked-pr/scripts/append-stack.sh "{{phase}}" "{{branch-name}}" "{{commit-msg}}" "{{pr-title}}" "{{pr-body}}"
```

## Examples

### Example 1: Research Authentication System

```bash
/research_codebase
```

**Claude**: "What would you like to research?"

**You**: "How does user authentication work in this codebase?"

**Result**: Claude spawns agents to find auth components, documents how they work, checks thoughts directory for historical context, and creates a comprehensive research document at `thoughts/shared/research/2025-01-08-authentication-flow.md`.

### Example 2: Plan New Feature

```bash
/create_plan
```

**Claude**: Asks for task description and clarifying questions.

**You**: Provide feature requirements.

**Result**: Claude researches current implementation, asks about design decisions, proposes implementation phases (each <300 lines), and generates plan at `thoughts/shared/plans/2025-01-08-ENG-1234-new-feature.md`.

### Example 3: Implement Plan

```bash
/implement_plan thoughts/shared/plans/2025-01-08-ENG-1234-new-feature.md
```

**Result**: Claude implements Phase 1, runs automated checks, pauses for manual verification, creates stacked PR automatically, then moves to Phase 2.

## Best Practices

### Research

- Be specific in research questions
- Leverage parallel agent spawning
- Review research documents before planning
- Update documents with follow-up questions

### Planning

- Break features into small phases
- Keep phases <300 lines for reviewability
- Separate automated vs manual verification
- Use `just` commands for verification

### Implementation

- Trust automated verification
- Perform manual verification thoroughly
- Review stacked PRs before merging
- Merge in order (Phase 1, then 2, then 3...)

### Context Efficiency

- Let Claude use silent execution automatically
- Use `just` commands for built-in backpressure
- Spawn agents in parallel when possible
- Focus agents on specific tasks

## Troubleshooting

### Dependency Issues

If you see errors about missing commands:

```bash
# Check dependencies
command -v git-town
command -v gh
command -v humanlayer
command -v just
```

Install missing dependencies using the installation guide above.

### Stacked PR Issues

**Wrong base branch:**
```bash
gh pr edit <pr-number> --base <correct-base-branch>
```

**Need to update earlier phase:**
```bash
git checkout phase-N-<name>
# Make changes and commit
git town sync --stack
```

### Thoughts Directory

**Sync issues:**
```bash
humanlayer thoughts status
humanlayer thoughts sync
```

## License

MIT License - See LICENSE file for details.

## Author

Elliot Steene (e.steene@hotmail.co.uk)

## Contributing

This is a personal workflow system, but feedback and suggestions are welcome! Please open an issue or submit a pull request.
