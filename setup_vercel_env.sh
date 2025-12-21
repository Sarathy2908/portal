#!/bin/bash

# Helper script to generate environment variables for Vercel deployment

echo "============================================================"
echo "Vercel Environment Variables Setup Helper"
echo "============================================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Backend Environment Variables:${NC}"
echo "-----------------------------------------------------------"

# Check if .env exists
if [ -f backend/.env ]; then
    echo -e "${GREEN}✓${NC} Found backend/.env file"
    echo ""
    
    # Extract Firebase credentials
    echo -e "${YELLOW}FIREBASE_CREDENTIALS_JSON:${NC}"
    echo "Copy the entire JSON value from backend/.env"
    echo "(The value after FIREBASE_CREDENTIALS_JSON=)"
    echo ""
else
    echo -e "${YELLOW}⚠${NC} backend/.env not found"
    echo "Please create it first with your Firebase credentials"
    echo ""
fi

# Generate SECRET_KEY
echo -e "${YELLOW}SECRET_KEY:${NC}"
if command -v openssl &> /dev/null; then
    SECRET_KEY=$(openssl rand -hex 32)
    echo "$SECRET_KEY"
    echo ""
else
    echo "Install openssl to generate, or use any random 64-character string"
    echo ""
fi

# ALLOWED_ORIGINS
echo -e "${YELLOW}ALLOWED_ORIGINS:${NC}"
echo "*"
echo "(Update this after frontend deployment with your frontend URL)"
echo ""

echo "============================================================"
echo -e "${BLUE}Frontend Environment Variables:${NC}"
echo "-----------------------------------------------------------"

echo -e "${YELLOW}BACKEND_URL:${NC}"
echo "https://your-backend.vercel.app"
echo "(Replace with your actual backend URL after backend deployment)"
echo ""

echo "============================================================"
echo -e "${GREEN}Next Steps:${NC}"
echo "1. Deploy backend to Vercel with above environment variables"
echo "2. Copy backend URL"
echo "3. Deploy frontend with BACKEND_URL set to backend URL"
echo "4. Update backend ALLOWED_ORIGINS with frontend URL"
echo "5. Redeploy backend"
echo ""
echo "See VERCEL_QUICK_START.md for detailed instructions"
echo "============================================================"
