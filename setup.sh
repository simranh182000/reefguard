#!/bin/bash

# ReefGuard - Setup Script
# This script sets up the project from a clean state

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🚀 ReefGuard - Setup Script${NC}"
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
        echo -e "${RED}❌ Could not find virtual environment!${NC}"
        echo -e "${YELLOW}Looked in: ../venv, ./venv, ../env, ./env${NC}"
        echo ""
        echo -e "${YELLOW}Please create a virtual environment first:${NC}"
        echo "  python3 -m venv ../venv"
        echo "  source ../venv/bin/activate"
        echo "  ./setup.sh"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Virtual environment already active: $VIRTUAL_ENV${NC}"
fi

echo ""

# Check if database already exists
if [ -f "db.sqlite3" ]; then
    echo -e "${YELLOW}⚠️  WARNING: Database already exists!${NC}"
    echo -e "${YELLOW}This may cause conflicts. Consider running ./reset.sh first.${NC}"
    echo ""
    read -p "Continue anyway? (yes/no): " continue_anyway
    if [ "$continue_anyway" != "yes" ]; then
        echo -e "${RED}❌ Setup cancelled.${NC}"
        echo -e "${YELLOW}Run ./reset.sh first, then ./setup.sh${NC}"
        exit 0
    fi
    echo ""
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}📦 STEP 1: Checking Dependencies${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Django is installed (key dependency)
python -c "import django" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dependencies already installed${NC}"
    echo -e "${YELLOW}ℹ️  Run 'pip install -r requirements.txt' to update if needed${NC}"
else
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    pip install -r requirements.txt --quiet
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Dependencies installed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to install dependencies${NC}"
        echo ""
        echo -e "${YELLOW}Try manually:${NC}"
        echo "  pip install -r requirements.txt"
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🗄️  STEP 2: Database Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Ensure migrations folder exists with __init__.py
if [ ! -d "core/migrations" ]; then
    echo -e "${YELLOW}📁 Creating migrations folder...${NC}"
    mkdir -p core/migrations
    touch core/migrations/__init__.py
    echo -e "${GREEN}✅ Migrations folder created${NC}"
fi

# Create migrations
echo -e "${YELLOW}📋 Creating migrations...${NC}"
python manage.py makemigrations
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Migrations created${NC}"
else
    echo -e "${RED}❌ Failed to create migrations${NC}"
    exit 1
fi

echo ""

# Apply migrations
echo -e "${YELLOW}📋 Applying migrations...${NC}"
python manage.py migrate
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Migrations applied${NC}"
else
    echo -e "${RED}❌ Failed to apply migrations${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}📊 STEP 3: Loading Initial Data${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}📥 Loading fixtures...${NC}"
python manage.py loaddata core/fixtures/initial_data.json
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Initial data loaded successfully${NC}"
    echo -e "${GREEN}   - 6 coral reefs${NC}"
    echo -e "${GREEN}   - 5 educational articles${NC}"
else
    echo -e "${RED}❌ Failed to load fixtures${NC}"
    echo -e "${YELLOW}⚠️  This is not critical. You can continue.${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}👤 STEP 4: Create Superuser${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}Choose an option:${NC}"
echo "  1) Create superuser interactively (recommended)"
echo "  2) Create default superuser (admin/admin123)"
echo "  3) Skip superuser creation"
echo ""
read -p "Enter choice (1-3): " superuser_choice

case $superuser_choice in
    1)
        echo ""
        echo -e "${YELLOW}📝 Please enter superuser details:${NC}"
        python manage.py createsuperuser
        ;;
    2)
        echo ""
        echo -e "${YELLOW}📝 Creating default superuser...${NC}"
        python manage.py shell -c "
from core.models import CustomUser
if not CustomUser.objects.filter(username='admin').exists():
    CustomUser.objects.create_superuser('admin', 'admin@reefguard.org', 'admin123', role='admin')
    print('✅ Default superuser created')
    print('   Username: admin')
    print('   Password: admin123')
    print('   Email: admin@reefguard.org')
else:
    print('ℹ️  Superuser \"admin\" already exists')
"
        ;;
    3)
        echo -e "${YELLOW}⏭️  Skipping superuser creation${NC}"
        ;;
    *)
        echo -e "${RED}❌ Invalid choice. Skipping superuser creation.${NC}"
        ;;
esac

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}📋 STEP 5: Creating Test Users${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

read -p "Create test users (researcher1, student1)? (y/n): " create_test_users

if [ "$create_test_users" = "y" ] || [ "$create_test_users" = "Y" ]; then
    echo ""
    echo -e "${YELLOW}📝 Creating test users...${NC}"
    python manage.py shell -c "
from core.models import CustomUser

# Create researcher
if not CustomUser.objects.filter(username='researcher1').exists():
    CustomUser.objects.create_user(
        username='researcher1',
        email='researcher@reefguard.org',
        password='test123',
        role='researcher',
        first_name='John',
        last_name='Researcher',
        organization='Marine Institute'
    )
    print('✅ Researcher account created: researcher1 / test123')
else:
    print('ℹ️  Researcher \"researcher1\" already exists')

# Create student
if not CustomUser.objects.filter(username='student1').exists():
    CustomUser.objects.create_user(
        username='student1',
        email='student@reefguard.org',
        password='test123',
        role='student',
        first_name='Jane',
        last_name='Student',
        organization='Ocean University'
    )
    print('✅ Student account created: student1 / test123')
else:
    print('ℹ️  Student \"student1\" already exists')

print('✅ Test users ready')
"
else
    echo -e "${YELLOW}⏭️  Skipping test user creation${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ SETUP COMPLETE!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}📋 Summary:${NC}"
echo -e "   ${GREEN}✅${NC} Dependencies installed"
echo -e "   ${GREEN}✅${NC} Database created and migrated"
echo -e "   ${GREEN}✅${NC} Initial data loaded (6 reefs, 5 articles)"
echo -e "   ${GREEN}✅${NC} User accounts ready"
echo ""
echo -e "${BLUE}👥 Default Test Accounts:${NC}"
echo ""
echo -e "${YELLOW}Admin:${NC}"
echo "   Username: admin"
echo "   Password: admin123"
echo "   URL: http://127.0.0.1:8000/admin/"
echo ""
echo -e "${YELLOW}Researcher:${NC}"
echo "   Username: researcher1"
echo "   Password: test123"
echo "   Access: Dashboard, CSV exports"
echo ""
echo -e "${YELLOW}Student:${NC}"
echo "   Username: student1"
echo "   Password: test123"
echo "   Access: Report events, upload media"
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}🚀 Ready to Start!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
read -p "Start development server now? (y/n): " start_server

if [ "$start_server" = "y" ] || [ "$start_server" = "Y" ]; then
    echo ""
    echo -e "${GREEN}🚀 Starting development server...${NC}"
    echo ""
    echo -e "${BLUE}Access the application at:${NC}"
    echo -e "   🌐 Main Site: ${GREEN}http://127.0.0.1:8000/${NC}"
    echo -e "   👑 Admin Panel: ${GREEN}http://127.0.0.1:8000/admin/${NC}"
    echo ""
    echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    python manage.py runserver
else
    echo ""
    echo -e "${GREEN}✅ All set! Start the server when ready:${NC}"
    echo -e "   ${YELLOW}python manage.py runserver${NC}"
    echo ""
    echo -e "${BLUE}📖 Useful Commands:${NC}"
    echo "   python manage.py runserver     - Start dev server"
    echo "   python manage.py shell         - Django shell"
    echo "   python manage.py createsuperuser - Create admin"
    echo ""
    echo -e "${BLUE}📖 Documentation:${NC}"
    echo "   TESTING_GUIDE.md    - Complete testing guide"
    echo "   QUICK_REFERENCE.md  - Quick reference card"
    echo "   PYCHARM_SETUP.md    - PyCharm IDE setup"
    echo ""
fi
