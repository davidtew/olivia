#!/bin/bash

# Olivia Art Portfolio - Fly.io Deployment Script
# This script deploys the app and syncs local database to production

set -e

APP_NAME="olivia-art-portfolio"
DB_NAME="olivia-art-portfolio-db"
LOCAL_DB="olivia_dev"
REMOTE_DB="olivia_art_portfolio"

echo "=========================================="
echo "Olivia Art Portfolio - Fly.io Deployment"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Check prerequisites
echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"

if ! command -v fly &> /dev/null; then
    echo -e "${RED}Error: fly CLI not found. Install from https://fly.io/docs/hands-on/install-flyctl/${NC}"
    exit 1
fi

if ! command -v psql &> /dev/null; then
    echo -e "${RED}Error: psql not found. Install PostgreSQL client tools.${NC}"
    exit 1
fi

if ! command -v pg_dump &> /dev/null; then
    echo -e "${RED}Error: pg_dump not found. Install PostgreSQL client tools.${NC}"
    exit 1
fi

echo -e "${GREEN}Prerequisites OK${NC}"
echo ""

# Step 2: Export local database
echo -e "${YELLOW}Step 2: Exporting local database...${NC}"

BACKUP_FILE="seed_data_$(date +%Y%m%d_%H%M%S).sql"

pg_dump -h localhost -U postgres $LOCAL_DB \
    --data-only \
    --exclude-table=users \
    --exclude-table=users_tokens \
    --exclude-table=schema_migrations \
    > "$BACKUP_FILE"

echo -e "${GREEN}Database exported to: $BACKUP_FILE${NC}"
echo ""

# Step 3: Confirm with user
echo -e "${YELLOW}Step 3: Ready to deploy${NC}"
echo ""
echo "This will:"
echo "  1. Reset the Fly database (DROP and CREATE)"
echo "  2. Deploy your code to Fly"
echo "  3. Run migrations (create tables)"
echo "  4. Import your local data"
echo ""
echo -e "${RED}WARNING: This will DELETE all existing data on Fly!${NC}"
echo ""
read -p "Continue? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "yes" ]; then
    echo "Deployment cancelled."
    rm "$BACKUP_FILE"
    exit 0
fi

echo ""

# Step 4: Reset Fly database
echo -e "${YELLOW}Step 4: Resetting Fly database...${NC}"
echo ""
echo "Please run these commands in the Postgres shell:"
echo "  DROP DATABASE IF EXISTS $REMOTE_DB;"
echo "  CREATE DATABASE $REMOTE_DB;"
echo "  \\q"
echo ""

fly postgres connect -a $DB_NAME

echo -e "${GREEN}Database reset complete${NC}"
echo ""

# Step 5: Deploy application
echo -e "${YELLOW}Step 5: Deploying application to Fly...${NC}"

fly deploy -a $APP_NAME

echo -e "${GREEN}Deployment complete${NC}"
echo ""

# Step 6: Import data
echo -e "${YELLOW}Step 6: Importing data to Fly database...${NC}"
echo "Starting proxy to Fly database..."

# Start proxy in background
fly proxy 15432:5432 -a $DB_NAME &
PROXY_PID=$!
sleep 3

# Import data
PGPASSWORD=$(fly postgres config show -a $DB_NAME 2>/dev/null | grep -o 'password=[^ ]*' | cut -d'=' -f2 || echo "postgres")

psql -h localhost -p 15432 -U postgres -d $REMOTE_DB < "$BACKUP_FILE"

# Kill proxy
kill $PROXY_PID 2>/dev/null || true

echo -e "${GREEN}Data import complete${NC}"
echo ""

# Step 7: Cleanup
echo -e "${YELLOW}Step 7: Cleaning up...${NC}"

read -p "Delete local backup file? (yes/no): " DELETE_BACKUP
if [ "$DELETE_BACKUP" == "yes" ]; then
    rm "$BACKUP_FILE"
    echo "Backup deleted"
else
    echo "Backup kept at: $BACKUP_FILE"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "Deployment Complete!"
echo "==========================================${NC}"
echo ""
echo "Your app is live at: https://$APP_NAME.fly.dev"
echo ""
echo "To view logs:  fly logs -a $APP_NAME"
echo "To SSH in:     fly ssh console -a $APP_NAME"
echo ""
