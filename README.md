# Claude Code Toolkit

A curated repository of **tools, commands, skills, and workflows for Claude Code**.  
This repo aggregates **third-party**, **personal**, and **AI-generated** assets to extend Claude’s coding, analysis, and automation capabilities.

---

## Purpose

- Centralise reusable Claude Code tools and prompts
- Document proven commands and workflows
- Experiment with AI-generated utilities and skills
- Share patterns that improve productivity and code quality

This repository is **tooling-oriented**, not a prompt dump. Each entry should be actionable, documented, and reproducible.

---

## Tools

| Tool | Description | Status |
|------|-------------|--------|
| [zk-brain](./skills/zk-brain/) | Token-efficient Zettelkasten knowledge base | 🟡 Testing |

---
## Repository Structure
```
├── agents/ (TBD)
├── commands/ (TBD)
├── examples/ (TBD)
│ ├── prompts/
│ └── transcripts/
├── skills/
│ ├── zk-brain/
│ │ ├── README.md          # Full documentation (usage, examples, troubleshooting)
│ │ ├── SKILL.md           # Claude Code skill definition
│ │ ├── install.sh         # One-command installation
│ │ ├── scripts/
│ │ │   └── zk             # Main CLI (bash + sqlite)
│ │ └── docs/
│ │   └── CLAUDE_SNIPPET.md  # Copy to your CLAUDE.md
│ └── README.md
├── tools/ (TBD)
├── workflows/  (TBD)
└── README.md
```
---
## Adding New Tools

1. Create directory: mkdir -p new-tool/{scripts,docs}
2. Add README.md with usage docs
3. Add SKILL.md if it's a Claude Code skill
4. Add install.sh for easy setup
5. Update this README's tools table


