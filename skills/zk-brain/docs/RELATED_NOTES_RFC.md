# Related Notes Feature - Design Proposal

**Version:** 1.2.0 (proposed)
**Status:** RFC (Request for Comments)
**Author:** Claude Code Evaluation
**Date:** 2026-01-09

---

## Overview

Add bidirectional note linking to create knowledge graphs and reduce token usage when exploring related concepts.

## Token Efficiency Analysis

### Current State
- Finding related information requires multiple search iterations
- Each search: ~50 tokens output
- Claude must manually connect concepts
- Typical exploration: 4-6 searches = 200-300 tokens

### With Related Notes
- One note reveals all connected notes
- Direct path to related context
- Estimated savings: **25-40% tokens** for multi-note scenarios

---

## Implementation Options

### Option A: Simple Text Field (RECOMMENDED)
```sql
ALTER TABLE notes ADD COLUMN related_ids TEXT DEFAULT '';
-- Storage: "42,43,45" (comma-separated IDs)
```

**Pros:**
- ✅ Simplest implementation (~100 lines of bash)
- ✅ No additional tables
- ✅ Easy to query and display
- ✅ Minimal storage overhead
- ✅ Works with existing sql_escape

**Cons:**
- ⚠️ Must manually maintain bidirectionality
- ⚠️ No referential integrity (can link to deleted notes)

**Verdict:** Best balance of simplicity and functionality

---

### Option B: Junction Table
```sql
CREATE TABLE note_links (
    from_id INTEGER REFERENCES notes(id),
    to_id INTEGER REFERENCES notes(id),
    link_type TEXT DEFAULT 'related',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (from_id, to_id)
);
```

**Pros:**
- ✅ Referential integrity
- ✅ Can add metadata (link types: "depends-on", "contradicts", "extends")
- ✅ Cleaner bidirectional queries

**Cons:**
- ❌ More complex to implement
- ❌ Additional table to manage
- ❌ Overkill for current use case
- ❌ More SQL queries per operation

**Verdict:** Over-engineering for v1.2.0, consider for v2.0

---

### Option C: FTS Tag Syntax (Creative Alternative)
```bash
# Use special tag syntax for references
zk add "Database Decision" "architecture,ref:42,ref:43" "..."
zk search "ref:42"  # Find all notes referencing #42
```

**Pros:**
- ✅ Zero schema changes
- ✅ Works with existing search

**Cons:**
- ❌ Not discoverable
- ❌ No bidirectionality
- ❌ Pollutes tag namespace
- ❌ Manual maintenance

**Verdict:** Clever but limited, not recommended

---

## Recommended Design: Option A

### Schema Change
```sql
-- Migration (non-destructive)
ALTER TABLE notes ADD COLUMN related_ids TEXT DEFAULT '';
```

### New Commands

#### Link Notes (Bidirectional)
```bash
zk link ID1 ID2         # Create bidirectional link
zk link ID1 ID2 --one-way  # Create directional link (optional)

# Example
zk link 42 43           # Links #42 ↔ #43
# Updates: note 42 related_ids: "43"
#          note 43 related_ids: "42"
```

#### View Related Notes
```bash
zk related ID           # List related notes (ID|Title|Tags)
zk related ID --full    # Get full content of all related

# Example
$ zk related 42
43|Auth Pattern|auth,security|global
45|API Design|api,architecture|myproject
```

#### Unlink Notes
```bash
zk unlink ID1 ID2       # Remove link (bidirectional)

# Example
zk unlink 42 43         # Removes link in both directions
```

#### Enhanced Get Command
```bash
$ zk get 42
---
[existing note output]
---
Related notes: #43 (Auth Pattern), #45 (API Design)
---
```

### Helper Functions

```bash
# Add to related_ids (maintains uniqueness)
add_related_id() {
    local note_id="$1"
    local related_id="$2"

    # Get current related_ids
    local current
    current=$(sqlite3 "$DB_FILE" "SELECT related_ids FROM notes WHERE id = $note_id;")

    # Add if not already present
    if ! echo ",$current," | grep -q ",$related_id,"; then
        [ -n "$current" ] && current="$current,$related_id" || current="$related_id"
        sqlite3 "$DB_FILE" "UPDATE notes SET related_ids = '$current' WHERE id = $note_id;"
    fi
}

# Remove from related_ids
remove_related_id() {
    local note_id="$1"
    local related_id="$2"

    local current
    current=$(sqlite3 "$DB_FILE" "SELECT related_ids FROM notes WHERE id = $note_id;")

    # Remove the ID
    local updated
    updated=$(echo "$current" | sed "s/^$related_id,//; s/,$related_id,/,/; s/,$related_id$//; s/^$related_id$//")

    sqlite3 "$DB_FILE" "UPDATE notes SET related_ids = '$updated' WHERE id = $note_id;"
}
```

---

## Token Usage Examples

### Before (v1.1.0)
```bash
# User: "How did we decide on PostgreSQL?"
Claude: zk search "PostgreSQL decision"  # 50 tokens
Claude: zk get 42                        # 100 tokens
Claude: zk search "database comparison"  # 50 tokens
Claude: zk search "performance tests"    # 50 tokens
Claude: zk get 43 44                     # 200 tokens

Total: 450 tokens
```

### After (v1.2.0)
```bash
# User: "How did we decide on PostgreSQL?"
Claude: zk search "PostgreSQL decision"  # 50 tokens
Claude: zk get 42                        # 100 tokens
  → See: "Related: #43 (Comparison), #44 (Performance), #45 (Migration)"
Claude: zk get 43 44 45                  # 300 tokens

Total: 450 tokens BUT with MORE comprehensive context
OR
Claude: zk related 42 --full             # 350 tokens (gets everything in one command)

Total: 400 tokens, fewer commands
```

---

## Implementation Checklist

- [ ] Schema migration with ALTER TABLE
- [ ] `cmd_link()` - create bidirectional links
- [ ] `cmd_unlink()` - remove bidirectional links
- [ ] `cmd_related()` - list/get related notes
- [ ] Update `cmd_get()` to show related notes
- [ ] Update `cmd_delete()` to clean up orphaned links
- [ ] Add validation (prevent self-links, circular refs)
- [ ] Add tests for all new commands
- [ ] Update README with examples
- [ ] Update SKILL.md with use cases

**Estimated effort:** 2-3 hours

---

## Migration Path

```bash
# v1.1.0 → v1.2.0 upgrade
zk upgrade  # New command that runs ALTER TABLE automatically

# Or manual:
sqlite3 ~/.claude/zk_brain/brain.db "ALTER TABLE notes ADD COLUMN related_ids TEXT DEFAULT '';"
```

**Non-destructive:** Existing data preserved, related_ids defaults to empty string.

---

## Use Cases

### Knowledge Graph Building
```bash
# Create decision trail
zk add "Decision: Use PostgreSQL" "database,decision" "..."
zk add "Performance benchmark results" "database,testing" "..."
zk add "Cost analysis" "database,finance" "..."
zk link 42 43  # Decision → Performance
zk link 42 44  # Decision → Cost

# Later: zk get 42 shows entire decision context
```

### Bug Investigation Trail
```bash
zk add "Bug: Memory leak in auth" "bug,auth" "..."
zk add "Root cause: JWT cache" "bug,auth,fix" "..."
zk add "Workaround: Cache eviction" "bug,workaround" "..."
zk link 50 51 51 52  # Bug → Cause → Workaround
```

### Learning Paths
```bash
zk add "React Hooks Basics" "react,learning" "..."
zk add "useState Deep Dive" "react,hooks" "..."
zk add "useEffect Gotchas" "react,hooks" "..."
zk link 60 61 62  # Create learning progression
```

---

## Questions for Discussion

1. **Bidirectional by default?** Yes (simpler UX, matches mental model)
2. **Link types?** Skip for v1.2.0, add in v2.0 if needed
3. **Limit on related_ids?** Suggest max 10 per note (prevent abuse)
4. **Circular reference prevention?** Not needed (circular refs are valid in knowledge graphs)
5. **Orphaned link cleanup?** Yes, on `zk delete`, remove ID from all related_ids

---

## Timeline Recommendation

**Option 1: Ship Now (with v1.1.0)**
- Pros: Complete feature set
- Cons: Delays shipping critical fixes

**Option 2: Ship Separately (as v1.2.0)** ← RECOMMENDED
- Pros: Ship v1.1.0 fixes immediately, get user feedback
- Cons: Users wait ~1-2 weeks for linking

**Option 3: Skip for Now**
- Pros: Keep it simple
- Cons: Missing valuable feature for knowledge graphs

---

## Recommendation

**Ship as v1.2.0 in ~1-2 weeks**, after v1.1.0 is validated.

**Why separate release:**
1. v1.1.0 addresses critical robustness → ship now
2. Related notes is enhancement → can wait
3. Get feedback on v1.1.0 first
4. Refine linking API based on usage patterns
5. Keeps commits focused and reviewable

**But start implementation soon because:**
- Low complexity (~2 hours work)
- High value (25-40% token savings)
- Users will want this for knowledge graphs
- Better to have early before large knowledge bases exist

---

## Open Questions

1. Should we add `zk graph ID` to visualize note network? (ASCII tree or mermaid diagram)
2. Should related notes appear in search results? (e.g., show #42 and its related notes)
3. Should we track link "strength" (how often related notes are accessed together)?

---

**Status:** Ready for implementation
**Decision needed:** Ship now (v1.1.0) or later (v1.2.0)?
