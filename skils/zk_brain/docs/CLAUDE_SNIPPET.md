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

4. **Organize**:
   ```bash
   zk list -p .             # list project notes
   zk tags                  # list all tags
   zk projects              # list all projects
   ```

### When to Query

- "Why did we do X?" → search first
- "What's our pattern for X?" → search first
- Starting work on a project → `zk list -p .`
- Solved a bug → `zk add -p . "Fix: ..." "bug,topic" "solution..."`
- Made a decision → `zk add "Decision: X" "decisions" "We chose X because..."`

### Note Quality

- **Atomic**: One concept per note
- **Searchable**: Title = what you'd search for
- **Self-contained**: Include context
- **Tagged**: lowercase, singular (e.g., `auth` not `Auth`)
