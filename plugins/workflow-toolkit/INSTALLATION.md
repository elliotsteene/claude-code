# Installation Guide

## How Plugin Installation Works

When the `workflow-toolkit` plugin is installed via Claude Code:

### What Gets Installed

**Only the plugin directory is copied:**
- Source: `plugins/workflow-toolkit/`
- Destination: User's Claude Code plugins directory

**NOT copied:**
- The entire repository
- Other plugins in `plugins/`
- Root `.claude-plugin/` directory

### File Access

All files within the plugin directory are accessible:

```
workflow-toolkit/               ← Entire directory is installed
  agents/ (6 files)            ✅ Accessible
  commands/ (3 files)          ✅ Accessible
  scripts/ (3 files)           ✅ Accessible
  skills/ (2 skills)           ✅ Accessible
  hooks/ (1 file)              ✅ Accessible
  README.md                    ✅ Accessible
  INSTALLATION.md              ✅ Accessible
  LICENSE                      ✅ Accessible
  plugin.json                  ✅ Accessible
```

## Path Resolution

### Using `${CLAUDE_PLUGIN_ROOT}`

Claude Code provides the `${CLAUDE_PLUGIN_ROOT}` environment variable that points to the installed plugin directory. All script references use this for portability.

**Examples:**

```bash
# ✅ Correct - Works anywhere
${CLAUDE_PLUGIN_ROOT}/scripts/smart_wrap.sh "uv run pytest"

# ❌ Incorrect - Only works from specific directory
./scripts/smart_wrap.sh "uv run pytest"
```

### How It Works

When Claude Code loads the plugin:
1. Plugin is installed to: `/path/to/claude/plugins/workflow-toolkit/`
2. `${CLAUDE_PLUGIN_ROOT}` is set to this path
3. Scripts resolve to: `/path/to/claude/plugins/workflow-toolkit/scripts/smart_wrap.sh`
4. Works regardless of user's current working directory

## Installation Methods

### Method 1: Direct Plugin Directory (Development)

```bash
cc --plugin-dir /Users/elliotsteene/Documents/claude-code/plugins/workflow-toolkit
```

**Use for:**
- Local development and testing
- Direct access to source files
- Immediate updates when modifying plugin

### Method 2: Copy to Project (Project-Specific)

```bash
cd /path/to/your-project
cp -r /path/to/plugins/workflow-toolkit .claude-plugin/
```

**Use for:**
- Project-specific plugin installations
- Customizing plugin for specific project
- Committing plugin to project repository

### Method 3: System-Wide Installation (Future)

```bash
# Via Claude Code marketplace (when available)
cc plugin install workflow-toolkit
```

**Use for:**
- Making plugin available to all projects
- Automatic updates via marketplace
- Shared installation across team

## Verification

After installation, verify the plugin is loaded:

```bash
cc --list-plugins
```

Should show:
```
✓ workflow-toolkit (0.1.0)
  - 6 agents
  - 3 commands
  - 2 skills
  - 1 hook
```

## Testing Path Resolution

Test that scripts are accessible:

```bash
# In any directory, ask Claude:
"Run ${CLAUDE_PLUGIN_ROOT}/scripts/spec_metadata.sh"
```

Should output metadata without errors, regardless of current directory.

## Troubleshooting

### Issue: Scripts not found

**Symptom:**
```
bash: ./scripts/smart_wrap.sh: No such file or directory
```

**Solution:**
Ensure paths use `${CLAUDE_PLUGIN_ROOT}` and wrap commands in quotes:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/smart_wrap.sh "your command here"
```

### Issue: Plugin not loading

**Check:**
1. Plugin directory contains `plugin.json`
2. Required directories exist in plugin root: `agents/`, `commands/`, `scripts/`, `skills/`, `hooks/`
3. Plugin is in correct location for installation method

**Verify:**
```bash
ls -la /path/to/plugin/
# Should show: agents/, commands/, scripts/, skills/, hooks/, plugin.json, README.md, LICENSE
```

### Issue: Hooks not running

**Symptom:**
Setup validation hook doesn't run on startup

**Solution:**
1. Check `hooks/hooks.json` exists
2. Verify JSON is valid: `cat hooks/hooks.json | jq .`
3. Restart Claude Code

## Dependencies

The plugin requires these tools to be installed on the system:

**Required:**
- `git-town` - Stack management
- `gh` - GitHub CLI
- `humanlayer` - Thoughts synchronization

**Optional:**
- `just` - Task runner

The setup-validation hook will check for these on first use.

## Updates

### Updating Installed Plugin

**Method 1 (Direct):**
Plugin updates automatically (files are directly accessed)

**Method 2 (Copied):**
```bash
cd /path/to/your-project
rm -rf .claude-plugin/workflow-toolkit
cp -r /path/to/updated/workflow-toolkit .claude-plugin/
```

**Method 3 (System):**
```bash
cc plugin update workflow-toolkit
```

## Uninstallation

### Remove from Project

```bash
rm -rf .claude-plugin/workflow-toolkit
```

### Remove from System

```bash
cc plugin uninstall workflow-toolkit
```

## Development Mode

When developing the plugin:

1. **Use Method 1** (direct plugin directory)
2. Edit files in source location
3. Changes take effect immediately
4. No need to reinstall or copy

## Security Notes

- Scripts are executed with user permissions
- No elevated privileges required
- All scripts are in plugin directory (sandboxed)
- Review `scripts/*.sh` before installation

## Support

For issues or questions:
- Check [README.md](README.md) for usage documentation
- Review [TROUBLESHOOTING section](#troubleshooting)
- Open issue at repository URL (see plugin.json)
