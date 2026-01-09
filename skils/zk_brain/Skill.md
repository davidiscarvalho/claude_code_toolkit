---
name: zk-brain
description: Token-efficient personal knowledge base using SQLite. Use when (1) storing learnings, decisions, patterns, or solutions, (2) recalling past decisions or context ("why did we...", "what's our pattern for..."), (3) starting work on any project (check project-specific notes first), (4) after solving bugs or making architectural decisions. Trigger: any reference to memory, knowledge base, notes, learnings, past decisions, or patterns.
---

# ZK Brain - Zettelkasten Knowledge Base

A SQLite-backed personal knowledge base optimised for token efficiency. Search returns IDs and titles (~50 tokens), fetch full content only when needed.

## Setup

```bash
# Make executable and add to PATH (add to ~/.bashrc or ~/.zshrc)
chmod +x ~/.claude/zk_brain/zk
export PATH="$HOME/.claude/zk_brain:$PATH"

# Or create symlink
ln -sf ~/.claude/zk_brain/zk /usr/local/bin/zk

# Initialize database
zk init
```

## Token-Efficient Workflow

**Search first, fetch what's needed:**

```bash
# 1. Search (cheap - ~50 tokens output)
zk search "authentication redirect"
# Output: 42|Clerk redirect fix|auth,clerk|resumai|...snippet...

# 2. Fetch only relevant notes
zk get 42
```

## Core Commands

### Search (Always Start Here)
```bash
zk search "query"              # All notes
zk search -p . "query"         # Current project only
zk search -p myproj "query"    # Specific project
zk search -t auth "query"      # Filter by tag
zk search -a "query"           # Include archived
```

### Get Full Content
```bash
zk get 42                      # Single note
zk get 42 43 44               # Multiple notes
```

### Add Notes
```bash
# Global note
zk add "Title" "tag1,tag2" "Content here..."

# Project-specific (-p . = current git project)
zk add -p . "API Pattern" "api,patterns" "We use X because Y..."
zk add -p resumai "Auth Flow" "auth,clerk" "The redirect works by..."
```

### List & Organize
```bash
zk list                        # All active notes
zk list -p .                   # Current project
zk list -t bugs                # By tag
zk tags                        # All tags with counts
zk projects                    # All projects with counts
zk archive 42                  # Archive (excluded from search)
zk stats                       # Database statistics
```

### Bulk Operations
```bash
zk feed document.md            # Output for analysis → add atomic notes
zk import notes.jsonl          # Import from JSON/JSONL
zk export backup.json          # Export all notes
```

## When to Use

### Query the Knowledge Base
- "Why did we choose X?" → `zk search "X decision"`
- "What's our pattern for Y?" → `zk search "Y pattern"`
- "How did we fix Z?" → `zk search "Z fix"`
- Starting any project → `zk list -p .`

### Add to Knowledge Base
- Solved a tricky bug → `zk add -p . "Fix: issue" "tags" "solution..."`
- Made architectural decision → `zk add "Decision: X" "architecture" "We chose X because..."`
- Found useful pattern → `zk add "Pattern: X" "patterns" "Use this when..."`
- Learned from debugging → `zk add -p . "Gotcha: X" "gotchas" "Watch out for..."`

## Note Quality Guidelines

**Atomic**: One concept per note. If you're writing "and also...", split it.

**Searchable**: Title should be what you'd search for later.
- ✓ "Clerk: redirect after signup requires middleware"
- ✗ "Auth stuff"

**Self-contained**: Include enough context to understand without other notes.

**Tagged consistently**: Use lowercase, singular (auth not Auth or authentication).

## Feed Workflow

For ingesting documents into atomic notes:

```bash
# 1. Output document for analysis
zk feed large-doc.md

# 2. Claude analyzes and suggests atomic notes
# 3. Execute the zk add commands Claude generates
```

## Data Location

- Database: `~/.claude/zk_brain/brain.db`
- Script: `~/.claude/zk_brain/zk`

## JSON Import Format

```json
{"title": "Note Title", "tags": "tag1,tag2", "content": "...", "project": "optional"}
```
