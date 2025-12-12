# Claude Code Plugins Repository

This repository contains Claude Code plugins for enhancing development workflows.

## Available Plugins

### Workflow Toolkit (`workflow-toolkit`)

Comprehensive development workflow system for codebase research, implementation planning, and stacked PR management through specialized AI agents.

**Features:**
- 🔍 Systematic codebase research with parallel agents
- 📋 Interactive implementation planning
- ⚙️ Phased plan execution with verification
- 🔗 Automated stacked PR management
- 🤫 Context-efficient command execution
- 🎫 Ticket management integration

**Documentation:** See [`plugins/workflow-toolkit/README.md`](plugins/workflow-toolkit/README.md)

## Installation

### From This Repository

```bash
# Use a specific plugin
cc --plugin-dir /path/to/this/repo/plugins/workflow-toolkit

# Or copy to your project
cp -r plugins/workflow-toolkit /path/to/your-project/.claude-plugin/
```

### Plugin Marketplace

This repository can serve as a plugin marketplace. The `.claude-plugin/marketplace.json` file lists all available plugins.

## Repository Structure

```
claude-code/
├── .claude-plugin/
│   └── marketplace.json      # Plugin registry
├── plugins/
│   └── workflow-toolkit/     # Workflow toolkit plugin
│       ├── agents/           # 6 specialized agents
│       ├── commands/         # 3 slash commands
│       ├── scripts/          # 3 utility scripts
│       ├── skills/           # 2 skills
│       ├── hooks/            # Setup validation
│       ├── README.md         # Plugin documentation
│       ├── INSTALLATION.md   # Installation guide
│       ├── LICENSE           # MIT License
│       └── plugin.json       # Plugin manifest
├── CLAUDE.md                 # Project instructions
├── LICENSE                   # Repository license
└── README.md                 # This file
```

## Development

### Creating New Plugins

1. Create a new directory in `plugins/`
2. Add component directories: `agents/`, `commands/`, `scripts/`, `skills/`, `hooks/`
3. Create `plugin.json` manifest
4. Write comprehensive `README.md`
5. Update `.claude-plugin/marketplace.json`

See the [workflow-toolkit plugin](plugins/workflow-toolkit/) as a reference example.

### Testing Plugins

Test plugins locally before publishing:

```bash
cc --plugin-dir /path/to/plugins/your-plugin
```

## Plugin Development Guidelines

### Component Types

- **Commands** (`commands/*.md`): User-invoked slash commands
- **Agents** (`agents/*.md`): Autonomous sub-agents for specialized tasks
- **Skills** (`skills/*/SKILL.md`): Integrated capabilities
- **Scripts** (`scripts/*.sh`): Utility functions
- **Hooks** (`hooks/hooks.json`): Event-driven automation

### Best Practices

1. **Clear Documentation**: Every plugin needs comprehensive README
2. **Dependency Validation**: Use hooks to check prerequisites
3. **Context Efficiency**: Minimize token usage with focused agents
4. **Progressive Disclosure**: Skills should be lean, detailed content in references
5. **Security First**: No hardcoded credentials, use HTTPS
6. **Proper Naming**: Kebab-case for plugins/skills/agents, snake_case for commands

## Contributing

This is a personal collection, but feedback and suggestions are welcome!

1. Fork the repository
2. Create a feature branch
3. Add or improve plugins
4. Submit a pull request

## License

MIT License - See LICENSE file for details.

## Author

Elliot Steene (e.steene@hotmail.co.uk)

## Resources

- [Claude Code Documentation](https://docs.claude.com/code)
- [Plugin Development Guide](https://docs.claude.com/code/plugins)
- [Workflow Toolkit Plugin](plugins/workflow-toolkit/README.md)
