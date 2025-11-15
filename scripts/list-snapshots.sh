#!/bin/bash

SNAPSHOT_DIR="$HOME/.olivia-snapshots"

if [ ! -d "${SNAPSHOT_DIR}" ]; then
    echo "No snapshots found."
    echo ""
    echo "To create your first snapshot, run:"
    echo "  ./scripts/snapshot.sh"
    echo ""
    exit 0
fi

SNAPSHOT_COUNT=$(find "${SNAPSHOT_DIR}" -name "*.info" | wc -l | tr -d ' ')

if [ "${SNAPSHOT_COUNT}" == "0" ]; then
    echo "No snapshots found."
    echo ""
    echo "To create your first snapshot, run:"
    echo "  ./scripts/snapshot.sh"
    echo ""
    exit 0
fi

echo "========================================"
echo "Available Olivia Snapshots"
echo "========================================"
echo ""
echo "Total snapshots: ${SNAPSHOT_COUNT}"
echo ""

for INFO_FILE in $(find "${SNAPSHOT_DIR}" -name "*.info" | sort -r); do
    source "${INFO_FILE}"

    SNAPSHOT_DATE=$(echo "${TIMESTAMP}" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)-\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Snapshot: ${SNAPSHOT_NAME}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Date:     ${SNAPSHOT_DATE}"
    echo "  Branch:   ${BRANCH}"
    echo "  Commit:   ${COMMIT:0:8}"

    if [ "${DB_CHECKSUM}" != "none" ]; then
        echo "  Database: ✓ included"
    else
        echo "  Database: - not included"
    fi

    if [ "${UPLOADS_CHECKSUM}" != "none" ]; then
        echo "  Uploads:  ✓ included"
    else
        echo "  Uploads:  - not included"
    fi

    echo ""
    echo "  To restore this snapshot:"
    echo "    ./scripts/restore.sh ${SNAPSHOT_NAME}"
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Snapshot location: ${SNAPSHOT_DIR}"
echo ""
