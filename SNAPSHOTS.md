# Olivia Snapshot System

## What This Is

The snapshot system creates complete backups of your Olivia website that you can restore with a single command. It's designed for people who don't know Git or coding - you just run simple commands.

Think of it like Time Machine for your website: you create snapshots before making risky changes, and if something breaks, you can go back in time to when everything was working.

## Why You Need This

When working with AI assistants (like me, Claude) to modify your website:
- The AI might make changes that break things
- The AI loses context between conversations
- You might not know when to save your work
- You need a safety net that doesn't require technical knowledge

**This system solves all of that.**

## The Three Commands

### 1. Create a Snapshot (Before Making Changes)

```bash
./scripts/snapshot.sh
```

Run this **before** asking the AI to make any significant changes. It saves:
- All your code
- Your database
- Uploaded images/files
- Everything needed to go back to this exact moment

You'll see output like:
```
Creating Olivia Snapshot: snapshot-20251115-143022
SUCCESS: Snapshot created!

Snapshot ID: snapshot-20251115-143022

To restore this snapshot later, run:
  ./scripts/restore.sh snapshot-20251115-143022
```

**Copy that snapshot ID** - you might need it later.

### 2. List Your Snapshots

```bash
./scripts/list-snapshots.sh
```

This shows all your saved snapshots with dates, so you can see what you have:

```
Available Olivia Snapshots

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Snapshot: snapshot-20251115-143022
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Date:     2025-11-15 14:30:22
  Branch:   master
  Database: ✓ included
  Uploads:  ✓ included

  To restore this snapshot:
    ./scripts/restore.sh snapshot-20251115-143022
```

### 3. Restore a Snapshot (When Something Breaks)

```bash
./scripts/restore.sh snapshot-20251115-143022
```

Replace `snapshot-20251115-143022` with your actual snapshot ID.

This will:
1. Ask you to confirm (type `yes`)
2. Create a safety backup of the current state (just in case)
3. Restore everything from the snapshot
4. Verify the restoration worked
5. Tell you if it was successful

If the restore works, your website will be exactly as it was when you created that snapshot.

## Recommended Workflow

### Starting a New Feature

1. **Create a snapshot first:**
   ```bash
   ./scripts/snapshot.sh
   ```

2. **Note the snapshot ID** (something like `snapshot-20251115-143022`)

3. **Ask the AI to make changes:**
   "Claude, please add a dark mode toggle to the website"

4. **Test the changes** - does everything work?

### If Something Breaks

1. **Don't panic** - you have a snapshot

2. **List your snapshots to find the one before the changes:**
   ```bash
   ./scripts/list-snapshots.sh
   ```

3. **Restore the snapshot:**
   ```bash
   ./scripts/restore.sh snapshot-20251115-143022
   ```

4. **Confirm when asked** (type `yes`)

5. **Wait for it to finish** - it will tell you when it's done

6. **Restart your server:**
   ```bash
   UPLOADS_STORAGE=local mix phx.server
   ```

Your website should now be back to its working state.

### If the Restore Itself Breaks

The restore script **automatically creates a safety backup** before restoring. If the restore makes things worse, you'll see output like:

```
Safety backup created: restore-safety-20251115-150000
```

You can restore that safety backup:
```bash
./scripts/restore.sh restore-safety-20251115-150000
```

## What Gets Saved

Each snapshot includes:

1. **All Code** - Every `.ex` and `.exs` file
2. **Database** - All your data (users, posts, media, etc.)
3. **Uploaded Files** - Images and files in `priv/static/uploads`
4. **Checksums** - To verify restoration worked correctly

## Where Snapshots Are Stored

All snapshots go to: `~/.olivia-snapshots/` (in your home directory)

Each snapshot is actually several files:
- `snapshot-XXXXXXXX-XXXXXX.info` - Snapshot details
- `snapshot-XXXXXXXX-XXXXXX.sql` - Database backup
- `snapshot-XXXXXXXX-XXXXXX-uploads.tar.gz` - Uploaded files
- `snapshot-XXXXXXXX-XXXXXX.checksum` - Verification data

You don't need to understand these files - just use the scripts.

## Common Questions

**Q: How often should I create snapshots?**
A: Before any significant change. When in doubt, create one - they're cheap and fast.

**Q: Can I delete old snapshots?**
A: Yes, but keep at least a few recent ones. You can manually delete files from `~/.olivia-snapshots/` if you're running out of space.

**Q: What if I restore the wrong snapshot?**
A: The restore script creates a safety backup automatically. You can restore that to undo the restore.

**Q: Do snapshots slow down my website?**
A: No - snapshots are saved to your computer, not part of the running website.

**Q: Can I create snapshots while the server is running?**
A: Yes for `snapshot.sh`, but `restore.sh` will stop the server automatically.

**Q: What if the AI forgets which snapshot to use?**
A: Run `./scripts/list-snapshots.sh` and tell the AI which one to restore. You can also decide yourself by looking at the dates.

## Example: Complete Workflow

Let's say you want to add a new feature:

```bash
./scripts/snapshot.sh
```
(Copy the snapshot ID it gives you)

Then tell the AI:
> "Claude, I want to add user profiles. I just created snapshot-20251115-120000 in case we need to revert."

The AI makes changes, but the website breaks. You can:

```bash
./scripts/restore.sh snapshot-20251115-120000
```
(Type `yes` when asked)

Wait for it to complete, then restart:
```bash
UPLOADS_STORAGE=local mix phx.server
```

You're back to the working state before the changes.

## Technical Notes (For the AI)

When working with the user on this project:

1. **Always suggest creating a snapshot** before major changes
2. **Tell the user the snapshot ID** so they can reference it later
3. **If you make changes that break things**, suggest restoring the last snapshot
4. **Never assume Git knowledge** - use the snapshot scripts instead
5. **After a restore**, remind the user to restart the server
6. **The restore script has verification** - trust its output

## Summary: The Three Commands

```bash
./scripts/snapshot.sh              # Create a backup
./scripts/list-snapshots.sh        # See all backups
./scripts/restore.sh SNAPSHOT_ID   # Restore a backup
```

That's it. You don't need to know Git, databases, or programming to use this safely.
