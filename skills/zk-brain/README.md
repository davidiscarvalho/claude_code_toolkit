# ZK Brain

A token-efficient Zettelkasten knowledge base for Claude Code. Store learnings, decisions, and patterns in a SQLite database with full-text search. Query returns minimal metadata (~50 tokens), fetch full content only when needed.

## Why?

Claude Code's context window is precious. Instead of:
- Dumping entire documentation files into context
- Re-explaining the same decisions every session
- Losing tribal knowledge between conversations

ZK Brain gives you:
- **Search-first retrieval**: Find relevant notes without loading everything
- **Atomic knowledge**: One concept per note, properly tagged
- **Project scoping**: Filter notes by project with `-p .`
- **Token efficiency**: 98% reduction for targeted queries

### Token Math

| Scenario | Traditional | ZK Brain |
|----------|-------------|----------|
| 100 notes × 200 tokens | 20,000 tokens | ~250 tokens |
| Find one pattern | Load all docs | Search → Get |

## Installation

### Quick Install

```bash
git clone https://github.com/davidiscarvalho/claude_code_toolkit.git
cd skills/zk-brain
./install.sh
```

### Manual Install

```bash
# Copy script to zk_brain directory
mkdir -p ~/.claude/zk_brain
cp scripts/zk ~/.claude/zk_brain/
chmod +x ~/.claude/zk_brain/zk

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/.claude/zk_brain:$PATH"

# Initialize database
zk init
```

### Dependencies

- `sqlite3` - Database engine with FTS5 support
- `jq` - JSON processing (for import/export)

```bash
# Ubuntu/Debian
sudo apt install sqlite3 jq

# macOS
brew install sqlite jq

# Arch
sudo pacman -S sqlite jq
```

## Usage

### Core Workflow

```bash
# 1. Search first (cheap - ~50 tokens output)
zk search "authentication pattern"
# Output: 42|Clerk redirect fix|auth,clerk|resumai|...snippet...

# 2. Fetch only what you need
zk get 42

# 3. Add new knowledge
zk add "Title" "tag1,tag2" "Content describing the learning..."

# 4. Project-specific notes (-p . = current git repo)
zk add -p . "API Design" "api,patterns" "We use REST because..."
```

### Commands Reference

#### Search (Always Start Here)

```bash
zk search "query"              # All active notes
zk search -p . "query"         # Current project only
zk search -p myproject "query" # Specific project
zk search -t auth "query"      # Filter by tag
zk search -a "query"           # Include archived notes
```

#### Retrieve

```bash
zk get 42                      # Single note (shows related notes)
zk get 42 43 44               # Multiple notes
```

#### Add & Update

```bash
zk add "Title" "tags" "content"           # Global note
zk add -p . "Title" "tags" "content"      # Project-specific
zk add -p myproject "Title" "tags" "..."  # Named project

zk update 42 "new content"                # Update content
zk update 42 -t "new,tags"                # Update tags
zk update 42 -T "New Title"               # Update title
```

#### Link Notes (Knowledge Graphs)

**New in v1.2.0** - Build connections between related notes to reduce token usage when exploring concepts.

```bash
zk link 42 43                  # Link two notes (bidirectional)
zk unlink 42 43                # Remove link between notes
zk related 42                  # List related notes (minimal output)
zk related 42 --full           # Get full content of all related notes
```

**Use cases:**
- Decision trails: Link decisions to their context, analysis, and outcomes
- Bug investigations: Connect bug reports to root causes and fixes
- Learning paths: Create progression through related concepts
- Architecture: Link components, dependencies, and design decisions

**Token savings:**
- Before: Multiple searches (~200-300 tokens) to find related context
- After: Direct path via links (~100-150 tokens)
- Savings: 25-40% for multi-note exploration

#### List & Organize

```bash
zk list                        # All active notes
zk list -p .                   # Current project
zk list -t bug                 # Filter by tag
zk list -a                     # Include archived
zk list -n 100                 # Limit results

zk tags                        # All tags with counts
zk projects                    # All projects with counts
zk stats                       # Database statistics
```

#### Archive & Delete

```bash
zk archive 42                  # Soft delete (excluded from search)
zk unarchive 42                # Restore
zk delete 42                   # Permanent delete
```

#### Bulk Operations

```bash
zk feed document.md            # Output file for Claude to analyze
zk import notes.jsonl          # Import from JSON/JSONL
zk export backup.json          # Export all notes
```

#### Maintenance

```bash
zk init                        # Initialize/reset database
zk upgrade                     # Upgrade database schema (v1.1.0 → v1.2.0)
zk vacuum                      # Optimize database
zk backup                      # Create timestamped backup
zk backup ~/my-backup.db       # Backup to specific path
```

**Note:** If upgrading from v1.1.0, run `zk upgrade` to add the related_ids column.

## Claude Code Integration

### Add to CLAUDE.md

Add this to your `~/.claude/CLAUDE.md` (global) or project-specific `CLAUDE.md`:

```markdown
## Personal Knowledge Base (Zettelkasten Brain)

I have a zettelkasten at `~/.claude/zk_brain/` for storing learnings, decisions, and patterns.

### Protocol

1. **Search first** (cheap - ~50 tokens):
   ```bash
   zk search "query"        # all notes
   zk search -p . "query"   # current project only
   ```

2. **Fetch what's needed**:
   ```bash
   zk get <id>              # full note content
   ```

3. **Add knowledge**:
   ```bash
   zk add "Title" "tags" "content"         # global
   zk add -p . "Title" "tags" "content"    # project-specific
   ```

### When to Query

- "Why did we do X?" → search first
- "What's our pattern for X?" → search first
- Starting work on a project → `zk list -p .`
- Solved a bug → `zk add -p . "Fix: ..." "bug,topic" "solution..."`
- Made a decision → `zk add "Decision: X" "decisions" "reason..."`
```

### When Claude Should Use ZK Brain

| Trigger | Action |
|---------|--------|
| "Why did we choose X?" | `zk search "X decision"` |
| "What's our pattern for Y?" | `zk search "Y pattern"` |
| "How did we fix Z?" | `zk search "Z fix bug"` |
| Starting any project | `zk list -p .` |
| Solved a tricky bug | `zk add -p . "Fix: ..." ...` |
| Made architecture decision | `zk add "Decision: ..." ...` |

## Note Quality Guidelines

### Atomic

One concept per note. If you're writing "and also...", split it.

```bash
# ❌ Bad: Multiple concepts
zk add "Auth stuff" "auth" "Clerk needs middleware. Also rate limiting uses upstash. JWT tokens expire in 24h."

# ✅ Good: Separate notes
zk add "Clerk middleware requirement" "auth,clerk" "Clerk redirect requires adding callback to publicRoutes in middleware.ts"
zk add "Rate limiting with Upstash" "api,ratelimit" "Use @upstash/ratelimit with Redis. Pattern: create limiter, check in handler, return 429."
zk add "JWT expiration policy" "auth,jwt" "Access tokens expire in 24h. Refresh tokens in 7d."
```

### Searchable

Title should be what you'd search for later.

```bash
# ❌ Bad
zk add "Auth stuff" ...
zk add "Fixed it" ...
zk add "Note 1" ...

# ✅ Good
zk add "Clerk: redirect after signup requires middleware config" ...
zk add "Fix: Prisma connection pool exhaustion in serverless" ...
zk add "Pattern: React Query with optimistic updates" ...
```

### Self-Contained

Include enough context to understand without other notes.

```bash
# ❌ Bad: Requires context
zk add "The fix" "bug" "Use the other approach instead"

# ✅ Good: Self-contained
zk add "Fix: Next.js ISR stale data" "nextjs,isr,bug" "When using ISR with dynamic routes, add revalidate: 60 to getStaticProps. The stale-while-revalidate pattern means first request after expiry serves stale, triggers background rebuild."
```

### Tagged Consistently

Use lowercase, singular form.

```bash
# ❌ Bad
zk add "..." "Auth,CLERK,Bugs" ...
zk add "..." "authentication,clerks,bug" ...

# ✅ Good
zk add "..." "auth,clerk,bug" ...
```

## Data Storage

```
~/.claude/zk_brain/
├── brain.db          # SQLite database with FTS5
├── zk                # CLI script
└── brain_backup_*.db # Timestamped backups
```

### Schema

```sql
CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    tags TEXT DEFAULT '',
    project TEXT DEFAULT NULL,      -- NULL = global
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    archived_at DATETIME DEFAULT NULL  -- NULL = active
);
```

### Import/Export Format

```jsonl
{"title": "Note Title", "tags": "tag1,tag2", "content": "...", "project": "optional-project"}
{"title": "Another Note", "tags": "tag3", "content": "...", "project": null}
```

## Advanced Usage

### Feed Documents to Claude

Use `zk feed` to have Claude analyze a document and extract atomic notes:

```bash
# Output document content
zk feed architecture-decisions.md

# Claude analyzes and suggests:
# zk add "Decision: PostgreSQL over SQLite" "database,architecture" "Chose postgres for..."
# zk add "Decision: REST over GraphQL" "api,architecture" "REST chosen because..."
```

### Backup Strategy

```bash
# Manual backup
zk backup ~/Dropbox/zk-backup.db

# Automated daily backup (add to crontab)
0 9 * * * ~/.claude/zk_brain/zk backup ~/backups/zk-$(date +\%Y\%m\%d).db
```

### Multiple Knowledge Bases

```bash
# Use different databases per context
ZK_DIR=~/.claude/work-brain zk search "..."
ZK_DIR=~/.claude/personal-brain zk search "..."
```

## Troubleshooting

### "sqlite3: command not found"

Install SQLite:
```bash
sudo apt install sqlite3  # Debian/Ubuntu
brew install sqlite       # macOS
```

### Search returns nothing

Check if notes exist and aren't archived:
```bash
zk list -a  # Show all including archived
zk stats    # Check counts
```

### FTS not working

Rebuild the FTS index:
```bash
sqlite3 ~/.claude/zk_brain/brain.db "INSERT INTO notes_fts(notes_fts) VALUES('rebuild');"
```

## License

MIT

## Contributing

Issues and PRs welcome. Keep it simple, keep it token-efficient.
