#!/bin/bash
set -e

SNAPSHOT_DIR="$HOME/.olivia-snapshots"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
SNAPSHOT_NAME="snapshot-${TIMESTAMP}"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "========================================"
echo "Creating Olivia Snapshot: ${SNAPSHOT_NAME}"
echo "========================================"
echo ""

mkdir -p "${SNAPSHOT_DIR}"

echo "Step 1: Checking Git status..."
cd "${PROJECT_DIR}"

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "ERROR: Not a Git repository!"
    exit 1
fi

if [[ -n $(git status --porcelain) ]]; then
    echo "  - Found uncommitted changes, creating commit..."
    git add -A
    git commit -m "Snapshot ${SNAPSHOT_NAME}: Auto-commit before snapshot" || true
else
    echo "  - No uncommitted changes"
fi

CURRENT_COMMIT=$(git rev-parse HEAD)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo ""
echo "Step 2: Recording Git state..."
echo "  - Branch: ${CURRENT_BRANCH}"
echo "  - Commit: ${CURRENT_COMMIT}"

cat > "${SNAPSHOT_DIR}/${SNAPSHOT_NAME}.info" <<EOF
SNAPSHOT_NAME=${SNAPSHOT_NAME}
TIMESTAMP=${TIMESTAMP}
BRANCH=${CURRENT_BRANCH}
COMMIT=${CURRENT_COMMIT}
PROJECT_DIR=${PROJECT_DIR}
EOF

echo ""
echo "Step 3: Creating database backup..."

DB_FILE="${SNAPSHOT_DIR}/${SNAPSHOT_NAME}.sql"

if MIX_ENV=dev mix ecto.dump > "${DB_FILE}" 2>&1; then
    echo "  - Database dumped to ${SNAPSHOT_NAME}.sql"
    DB_CHECKSUM=$(shasum -a 256 "${DB_FILE}" | cut -d' ' -f1)
    echo "DB_CHECKSUM=${DB_CHECKSUM}" >> "${SNAPSHOT_DIR}/${SNAPSHOT_NAME}.info"
else
    echo "  - Warning: Database dump failed (might not exist yet)"
    echo "DB_CHECKSUM=none" >> "${SNAPSHOT_DIR}/${SNAPSHOT_NAME}.info"
fi

echo ""
echo "Step 4: Backing up uploaded files..."
UPLOADS_DIR="${PROJECT_DIR}/priv/static/uploads"
if [ -d "${UPLOADS_DIR}" ]; then
    UPLOADS_BACKUP="${SNAPSHOT_DIR}/${SNAPSHOT_NAME}-uploads.tar.gz"
    tar czf "${UPLOADS_BACKUP}" -C "${UPLOADS_DIR}" . 2>/dev/null || true
    UPLOADS_CHECKSUM=$(shasum -a 256 "${UPLOADS_BACKUP}" | cut -d' ' -f1)
    echo "  - Uploaded files backed up"
    echo "UPLOADS_CHECKSUM=${UPLOADS_CHECKSUM}" >> "${SNAPSHOT_DIR}/${SNAPSHOT_NAME}.info"
else
    echo "  - No uploads directory found"
    echo "UPLOADS_CHECKSUM=none" >> "${SNAPSHOT_DIR}/${SNAPSHOT_NAME}.info"
fi

echo ""
echo "Step 5: Creating verification checksums..."

CODE_FILES="${SNAPSHOT_DIR}/${SNAPSHOT_NAME}-files.txt"
find "${PROJECT_DIR}/lib" -type f -name "*.ex" -o -name "*.exs" | sort > "${CODE_FILES}"
cat "${CODE_FILES}" | xargs shasum -a 256 | shasum -a 256 | cut -d' ' -f1 > "${SNAPSHOT_DIR}/${SNAPSHOT_NAME}.checksum"
CODE_CHECKSUM=$(cat "${SNAPSHOT_DIR}/${SNAPSHOT_NAME}.checksum")
echo "CODE_CHECKSUM=${CODE_CHECKSUM}" >> "${SNAPSHOT_DIR}/${SNAPSHOT_NAME}.info"

echo "  - Code checksum: ${CODE_CHECKSUM:0:16}..."

echo ""
echo "========================================"
echo "SUCCESS: Snapshot created!"
echo "========================================"
echo ""
echo "Snapshot ID: ${SNAPSHOT_NAME}"
echo "Location: ${SNAPSHOT_DIR}/${SNAPSHOT_NAME}.info"
echo ""
echo "To restore this snapshot later, run:"
echo "  ./scripts/restore.sh ${SNAPSHOT_NAME}"
echo ""
echo "To see all snapshots, run:"
echo "  ./scripts/list-snapshots.sh"
echo ""
