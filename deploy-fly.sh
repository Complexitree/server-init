#!/bin/bash

# Fly.io Deployment Script for Complexitree Server
# This script helps configure and deploy the Complexitree server to Fly.io

set -euo pipefail

echo "🚀 Complexitree Server - Fly.io Deployment"
echo "==========================================="
echo ""

# Check if flyctl is installed
if ! command -v flyctl &> /dev/null; then
    echo "❌ Error: flyctl is not installed."
    echo "Please install it from: https://fly.io/docs/hands-on/install-flyctl/"
    exit 1
fi

echo "✅ flyctl is installed"
echo ""

# Check if user is logged in
if ! flyctl auth whoami &> /dev/null; then
    echo "❌ Not logged in to Fly.io"
    echo "Please run: flyctl auth login"
    exit 1
fi

echo "✅ Logged in to Fly.io"
echo ""

# Check if app exists
APP_NAME=$(grep "^app = " fly.toml | sed 's/app = "\(.*\)"/\1/')

if [ -z "$APP_NAME" ]; then
    echo "❌ Error: Could not find app name in fly.toml"
    exit 1
fi

echo "📱 App name: $APP_NAME"
echo ""

# Check if app exists on Fly.io
if flyctl apps list | grep -q "^$APP_NAME[[:space:]]"; then
    echo "✅ App '$APP_NAME' exists on Fly.io"
else
    echo "⚠️  App '$APP_NAME' does not exist. Creating it now..."
    flyctl apps create "$APP_NAME"
fi

echo ""
echo "🔐 Setting up secrets..."
echo "You need to configure the following secrets:"
echo ""
echo "Required secrets:"
echo "  - XTREE_KEY_STORE_ACCESS_GRANT"
echo "  - XTREE_KEY_STORE_BUCKET"
echo "  - XTREE_PUBLISH_CONTEXT_STORE_ACCESS_GRANT"
echo "  - XTREE_PUBLISH_CONTEXT_STORE_BUCKET"
echo "  - XTREE_USER_SETTINGS_STORE_ACCESS_GRANT"
echo "  - XTREE_USER_SETTINGS_STORE_BUCKET"
echo "  - XTREE_TABLE_DATA_ACCESS_GRANT"
echo "  - XTREE_OPENAI_API_KEY"
echo "  - XTREE_DOCUPIPE_API_KEY"
echo "  - XTREE_COUNTER_API_KEY"
echo "  - CLERK_SECRET_KEY"
echo "  - CLERK_PUBLISHABLE_KEY_FOREST"
echo "  - XTREE_TEMP_ACCESSGRANT"
echo "  - XTREE_TEMP_KEYHASH"
echo "  - ENTERA_CLIENT_ID"
echo "  - ENTERA_CLIENT_SECRET"
echo "  - SUPABASE_URL"
echo "  - SUPABASE_SERVICE_KEY"
echo "  - SUPABASE_PUBLISHABLE_KEY"
echo ""
echo "You can set secrets one by one using:"
echo "  flyctl secrets set KEY=VALUE"
echo ""
echo "Or import from a file using:"
echo "  flyctl secrets import < secrets.txt"
echo ""
echo "Format for secrets.txt:"
echo "  KEY1=value1"
echo "  KEY2=value2"
echo ""

read -p "Have you configured all secrets? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Please configure secrets before deploying."
    echo "Run this script again after setting up secrets."
    exit 1
fi

echo ""
echo "🌍 Deploying to regions: Frankfurt (fra) and Sydney (syd)..."
echo ""

# Deploy the application
echo "📦 Deploying application..."
flyctl deploy

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Useful commands:"
echo "  - View status:        flyctl status"
echo "  - View logs:          flyctl logs"
echo "  - Scale machines:     flyctl scale count 0-5 --region fra"
echo "  - List machines:      flyctl machines list"
echo "  - SSH into machine:   flyctl ssh console"
echo "  - View metrics:       flyctl dashboard"
echo ""
echo "🌐 Your app should be available at: https://$APP_NAME.fly.dev"
echo ""
