#!/bin/bash

# ReefGuard - Reset/Clean Script
# This script removes all database, migrations, cache, and media files

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🗑️  ReefGuard - Reset Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if virtual environment is activated, if not, try to activate it
if [ -z "$VIRTUAL_ENV" ]; then
    echo -e "${YELLOW}⚠️  Virtual environment not activated. Attempting to activate...${NC}"

    # Try to find and activate venv
    if [ -f "../venv/bin/activate" ]; then
        source ../venv/bin/activate
        echo -e "${GREEN}✅ Virtual environment activated: ../venv/${NC}"
    elif [ -f "venv/bin/activate" ]; then
        source venv/bin/activate
        echo -e "${GREEN}✅ Virtual environment activated: ./venv/${NC}"
    elif [ -f "../env/bin/activate" ]; then
        source ../env/bin/activate
        echo -e "${GREEN}✅ Virtual environment activated: ../env/${NC}"
    elif [ -f "env/bin/activate" ]; then
        source env/bin/activate
        echo -e "${GREEN}✅ Virtual environment activated: ./env/${NC}"
    else
        echo -e "${YELLOW}⚠️  No virtual environment found (not required for reset)${NC}"
    fi
else
    echo -e "${GREEN}✅ Virtual environment already active: $VIRTUAL_ENV${NC}"
fi

echo ""

# Confirmation prompt
echo -e "${YELLOW}⚠️  WARNING: This will DELETE:${NC}"
echo "   - Database (db.sqlite3)"
echo "   - All migrations (except __init__.py)"
echo "   - Python cache files (__pycache__, *.pyc)"
echo "   - All uploaded media files"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo -e "${RED}❌ Reset cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Starting cleanup...${NC}"
echo ""

# Delete database
if [ -f "db.sqlite3" ]; then
    echo -e "${YELLOW}🗑️  Deleting database...${NC}"
    rm db.sqlite3
    echo -e "${GREEN}✅ Database deleted${NC}"
else
    echo -e "${YELLOW}ℹ️  No database found (already clean)${NC}"
fi

# Delete migrations (except __init__.py)
if [ -d "core/migrations" ]; then
    echo -e "${YELLOW}🗑️  Deleting migrations...${NC}"
    find core/migrations -name "*.py" ! -name "__init__.py" -delete 2>/dev/null
    find core/migrations -name "*.pyc" -delete 2>/dev/null
    echo -e "${GREEN}✅ Migrations deleted${NC}"
else
    echo -e "${YELLOW}ℹ️  No migrations folder found${NC}"
fi

# Delete all __pycache__ folders
echo -e "${YELLOW}🗑️  Cleaning Python cache...${NC}"
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
find . -name "*.pyc" -delete 2>/dev/null
find . -name "*.pyo" -delete 2>/dev/null
echo -e "${GREEN}✅ Python cache cleaned${NC}"

# Clean media folder (keep the folder but delete contents)
if [ -d "media" ]; then
    echo -e "${YELLOW}🗑️  Cleaning uploaded media...${NC}"
    rm -rf media/*
    echo -e "${GREEN}✅ Media folder cleaned${NC}"
else
    mkdir -p media
    echo -e "${GREEN}✅ Media folder created${NC}"
fi

# Delete staticfiles if exists
if [ -d "staticfiles" ]; then
    echo -e "${YELLOW}🗑️  Deleting collected static files...${NC}"
    rm -rf staticfiles
    echo -e "${GREEN}✅ Static files deleted${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ RESET COMPLETE!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Cleaned:${NC}"
echo -e "   ${GREEN}✅${NC} Database removed"
echo -e "   ${GREEN}✅${NC} Migrations removed"
echo -e "   ${GREEN}✅${NC} Cache cleared"
echo -e "   ${GREEN}✅${NC} Media files removed"
echo -e "   ${GREEN}✅${NC} Static files removed"
echo ""
echo -e "${BLUE}Next step:${NC}"
echo -e "   Run ${YELLOW}./setup.sh${NC} to set up the project from scratch"
echo ""
