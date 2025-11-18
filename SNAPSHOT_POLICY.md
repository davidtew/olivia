# Snapshot Policy

## Purpose

This document defines **deterministic, objective rules** for when Claude Code must automatically create snapshots before making changes. These rules eliminate subjective judgment and ensure consistent safety practices.

## Automatic Snapshot Rules

Claude Code **MUST** create a snapshot before proceeding if ANY of the following conditions are met:

### Rule 1: File Count Thresholds

Create snapshot if planning to:
- **Modify ≥ 3 files** (even small changes)
- **Create ≥ 2 new files**
- **Delete ANY file** (even one)

**Rationale**: Multiple file changes increase complexity and risk of unintended side effects.

### Rule 2: Critical File Types

Create snapshot if touching ANY of these file types:

- **Database migrations**: `priv/repo/migrations/*.exs`
- **Configuration files**: `config/*.exs`
- **Schema definitions**: Any file containing `use Ecto.Schema`
- **Repository modules**: `*/repo.ex`
- **Dependencies**: `mix.exs` or `mix.lock`
- **Application startup**: `*/application.ex`
- **Router**: `*_web/router.ex`

**Rationale**: These files affect core application behaviour and are difficult to debug if broken.

### Rule 3: Request Keywords

Create snapshot if the user's request contains ANY of these phrases:

- "add feature"
- "implement"
- "refactor"
- "change database"
- "migration"
- "modify schema"
- "add migration"
- "create migration"
- "update database"
- "new feature"

**Rationale**: These keywords indicate significant, multi-step changes.

### Rule 4: Never Snapshot

**DO NOT** create snapshot for:

- **Read-only operations**: Only using Read, Grep, Glob tools (no Write/Edit)
- **Documentation only**: Changes exclusively to `*.md` files
- **Single trivial edit**: One-line typo fixes, comment changes, whitespace
- **Explicit override**: User says "no snapshot needed" or "don't snapshot"

**Rationale**: These operations are reversible, low-risk, or explicitly exempted.

### Rule 5: User Override (Highest Priority)

User can override ALL rules:

- **Force snapshot**: User says "snapshot first" or "create snapshot" → Always snapshot
- **Skip snapshot**: User says "no snapshot needed" or "skip snapshot" → Never snapshot

**Rationale**: User has final authority over their project.

## Execution Format

When a snapshot is required, Claude Code must:

1. **Announce intention**:
   ```
   This operation triggers automatic snapshot (Rule X: reason).
   Creating snapshot before proceeding...
   ```

2. **Execute snapshot script**:
   ```bash
   ./scripts/snapshot.sh
   ```

3. **Report snapshot ID**:
   ```
   Snapshot created: snapshot-YYYYMMDD-HHMMSS
   Proceeding with requested changes...
   ```

4. **Continue with task**

## Examples

### ✅ Snapshot Required

**Example 1**: "Add dark mode feature"
- Triggers: Rule 3 (keyword "add feature")
- Action: Snapshot before starting

**Example 2**: "Update these 4 files to fix the bug"
- Triggers: Rule 1 (modifying ≥3 files)
- Action: Snapshot before starting

**Example 3**: "Create a new migration for users table"
- Triggers: Rule 2 (migration file) + Rule 3 (keyword "migration")
- Action: Snapshot before starting

**Example 4**: "Delete old_helper.ex"
- Triggers: Rule 1 (delete any file)
- Action: Snapshot before starting

### ❌ Snapshot NOT Required

**Example 1**: "Fix typo in README.md"
- Exempt: Rule 4 (documentation only)
- Action: Proceed without snapshot

**Example 2**: "Show me how the Media module works"
- Exempt: Rule 4 (read-only)
- Action: Proceed without snapshot

**Example 3**: "Update comment in user.ex to clarify validation"
- Exempt: Rule 4 (single trivial edit)
- Action: Proceed without snapshot

**Example 4**: "Add this small feature, no snapshot needed"
- Exempt: Rule 5 (user override)
- Action: Proceed without snapshot

## Verification Checklist

Before starting any task, Claude Code evaluates:

```
[ ] Will I modify ≥3 files?
[ ] Will I create ≥2 new files?
[ ] Will I delete any files?
[ ] Am I touching migrations, config, schema, mix.exs, or router?
[ ] Does the request contain trigger keywords?
[ ] Did the user explicitly request/forbid snapshot?

If ANY checkbox is YES → Create snapshot first
If user forbid snapshot → Skip snapshot
Otherwise → Proceed without snapshot
```

## Policy Updates

This policy can be updated by:
1. User explicitly requesting changes to the rules
2. Mutual agreement that a rule is too strict/loose
3. Discovery of edge cases not covered

All changes must be documented in this file with rationale.

---

**Last Updated**: 2025-11-15
**Version**: 1.0
**Status**: Active
