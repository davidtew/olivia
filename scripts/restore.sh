#!/bin/bash
set -e

SNAPSHOT_DIR="$HOME/.olivia-snapshots"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ -z "$1" ]; then
    echo "ERROR: Please specify a snapshot to restore"
    echo ""
    echo "Usage: ./scripts/restore.sh SNAPSHOT_NAME"
    echo ""
    echo "To see available snapshots, run:"
    echo "  ./scripts/list-snapshots.sh"
    echo ""
    exit 1
fi

SNAPSHOT_NAME="$1"
SNAPSHOT_INFO="${SNAPSHOT_DIR}/${SNAPSHOT_NAME}.info"

if [ ! -f "${SNAPSHOT_INFO}" ]; then
    echo "ERROR: Snapshot '${SNAPSHOT_NAME}' not found!"
    echo ""
    echo "Available snapshots:"
    ./scripts/list-snapshots.sh
    exit 1
fi

source "${SNAPSHOT_INFO}"

echo "========================================"
echo "Restoring Olivia Snapshot"
echo "========================================"
echo ""
echo "WARNING: This will:"
echo "  1. Reset all code to the snapshot state"
echo "  2. Restore the database"
echo "  3. Restore uploaded files"
echo ""
echo "Snapshot details:"
echo "  - Name: ${SNAPSHOT_NAME}"
echo "  - Date: ${TIMESTAMP}"
echo "  - Branch: ${BRANCH}"
echo "  - Commit: ${COMMIT:0:8}"
echo ""
read -p "Continue? (yes/no): " CONFIRM

if [ "${CONFIRM}" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

echo ""
echo "Step 1: Creating safety backup of current state..."
SAFETY_BACKUP="restore-safety-$(date +%Y%m%d-%H%M%S)"
./scripts/snapshot.sh > /dev/null 2>&1 || echo "  - Warning: Safety backup failed"
echo "  - Safety backup created: ${SAFETY_BACKUP}"

echo ""
echo "Step 2: Stopping any running servers..."
pkill -f "mix phx.server" || true
sleep 2
echo "  - Servers stopped"

echo ""
echo "Step 3: Restoring Git state..."
cd "${PROJECT_DIR}"

if [[ -n $(git status --porcelain) ]]; then
    echo "  - Stashing uncommitted changes..."
    git stash push -m "Auto-stash before restore to ${SNAPSHOT_NAME}"
fi

echo "  - Checking out commit ${COMMIT:0:8}..."
git checkout -f "${COMMIT}"

if [ "${BRANCH}" != "HEAD" ]; then
    echo "  - Switching to branch ${BRANCH}..."
    git checkout -B "${BRANCH}"
fi

echo ""
echo "Step 4: Restoring database..."
DB_FILE="${SNAPSHOT_DIR}/${SNAPSHOT_NAME}.sql"

if [ -f "${DB_FILE}" ] && [ "${DB_CHECKSUM}" != "none" ]; then
    ACTUAL_CHECKSUM=$(shasum -a 256 "${DB_FILE}" | cut -d' ' -f1)
    if [ "${ACTUAL_CHECKSUM}" == "${DB_CHECKSUM}" ]; then
        echo "  - Database checksum verified"
        echo "  - Dropping existing database..."
        MIX_ENV=dev mix ecto.drop --force || true
        echo "  - Creating database..."
        MIX_ENV=dev mix ecto.create
        echo "  - Loading database snapshot..."
        MIX_ENV=dev mix ecto.load < "${DB_FILE}"
        echo "  - Database restored successfully"
    else
        echo "  - ERROR: Database checksum mismatch!"
        echo "    Expected: ${DB_CHECKSUM}"
        echo "    Got:      ${ACTUAL_CHECKSUM}"
        exit 1
    fi
else
    echo "  - No database backup found, skipping"
fi

echo ""
echo "Step 5: Restoring uploaded files..."
UPLOADS_DIR="${PROJECT_DIR}/priv/static/uploads"
UPLOADS_BACKUP="${SNAPSHOT_DIR}/${SNAPSHOT_NAME}-uploads.tar.gz"

if [ -f "${UPLOADS_BACKUP}" ] && [ "${UPLOADS_CHECKSUM}" != "none" ]; then
    ACTUAL_CHECKSUM=$(shasum -a 256 "${UPLOADS_BACKUP}" | cut -d' ' -f1)
    if [ "${ACTUAL_CHECKSUM}" == "${UPLOADS_CHECKSUM}" ]; then
        echo "  - Uploads checksum verified"
        rm -rf "${UPLOADS_DIR}"
        mkdir -p "${UPLOADS_DIR}"
        tar xzf "${UPLOADS_BACKUP}" -C "${UPLOADS_DIR}"
        echo "  - Uploaded files restored"
    else
        echo "  - ERROR: Uploads checksum mismatch!"
        exit 1
    fi
else
    echo "  - No uploads backup found, skipping"
fi

echo ""
echo "Step 6: Verifying code restoration..."
EXPECTED_CHECKSUM="${CODE_CHECKSUM}"

CODE_FILES_TEMP=$(mktemp)
find "${PROJECT_DIR}/lib" -type f -name "*.ex" -o -name "*.exs" | sort > "${CODE_FILES_TEMP}"
ACTUAL_CHECKSUM=$(cat "${CODE_FILES_TEMP}" | xargs shasum -a 256 | shasum -a 256 | cut -d' ' -f1)
rm "${CODE_FILES_TEMP}"

if [ "${ACTUAL_CHECKSUM}" == "${EXPECTED_CHECKSUM}" ]; then
    echo "  ✓ Code checksum verified: ${ACTUAL_CHECKSUM:0:16}..."
else
    echo "  ✗ WARNING: Code checksum mismatch!"
    echo "    Expected: ${EXPECTED_CHECKSUM}"
    echo "    Got:      ${ACTUAL_CHECKSUM}"
    echo ""
    echo "  This might be normal if:"
    echo "  - Git line endings changed"
    echo "  - File permissions changed"
    echo ""
    read -p "Continue anyway? (yes/no): " CONTINUE
    if [ "${CONTINUE}" != "yes" ]; then
        exit 1
    fi
fi

echo ""
echo "Step 7: Installing dependencies..."
mix deps.get
echo "  - Dependencies installed"

echo ""
echo "Step 8: Compiling code..."
mix compile
echo "  - Code compiled successfully"

echo ""
echo "========================================"
echo "SUCCESS: Restoration complete!"
echo "========================================"
echo ""
echo "Your project has been restored to:"
echo "  - Snapshot: ${SNAPSHOT_NAME}"
echo "  - Date: ${TIMESTAMP}"
echo "  - Commit: ${COMMIT:0:8}"
echo ""
echo "To start the server:"
echo "  UPLOADS_STORAGE=local mix phx.server"
echo ""
echo "If something went wrong, you can restore the"
echo "safety backup that was created:"
echo "  ./scripts/restore.sh ${SAFETY_BACKUP}"
echo ""
