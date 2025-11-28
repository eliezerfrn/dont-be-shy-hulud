# AI Assistant Tools and Workflows

This directory contains tools and workflows specifically designed for AI assistants working with this repository.

## Directory Structure

```
.agents/
├── README.md           # This file
├── skills/             # Claude MCP skills
│   ├── shai-hulud-detector.json
│   └── shai-hulud-remediation.json
└── workflows/          # Common workflows (future)
```

## Skills

### Shai-Hulud Detector

**File**: `skills/shai-hulud-detector.json`

Automated detection skill for Shai-Hulud 2.0 compromise.

**Usage with Claude Desktop**:
1. Install the MCP skill
2. Invoke: "Scan my system for Shai-Hulud"
3. The skill will run detection scripts and report findings

**What it does**:
- Scans for IOC files (`setup_bun.js`, `bun_environment.js`)
- Checks running processes
- Verifies credentials exposure
- Scans GitHub repos for exfiltration markers
- Checks workflows for backdoors

### Shai-Hulud Remediation

**File**: `skills/shai-hulud-remediation.json`

Guided remediation workflow.

**Usage with Claude Desktop**:
1. After positive detection
2. Invoke: "Help me remediate Shai-Hulud"
3. Follow the interactive workflow

**What it does**:
- Guides through credential rotation
- Helps clean infected packages
- Assists with system recovery
- Verifies cleanup completeness

## For AI Assistants

When working with this repository:

1. **Read `AGENTS.md`** first for comprehensive guidelines
2. **Respect language preferences** (EN/CS bilingual)
3. **Prioritize security** - verify before executing
4. **Maintain consistency** across both languages
5. **Test thoroughly** before suggesting changes

## Adding New Skills

To add a new MCP skill:

1. Create JSON file in `skills/`
2. Follow Claude MCP skill schema
3. Test thoroughly
4. Document in this README
5. Update `AGENTS.md` if needed

## Future Enhancements

Planned additions to this directory:

- [ ] GitLab CI workflow templates
- [ ] GitHub Actions workflow examples
- [ ] Pre-commit hook templates
- [ ] IOC update automation scripts
- [ ] Translation synchronization tools

## Contributing

See `CONTRIBUTING.md` in the root directory for general contribution guidelines.

For AI-specific tooling contributions:
- Ensure cross-platform compatibility (macOS/Linux)
- Include error handling
- Document all parameters
- Provide usage examples

---

**Note**: These tools are designed for AI assistants but can also be used by humans with appropriate MCP clients.
