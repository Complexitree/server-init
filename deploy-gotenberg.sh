#!/bin/bash

# Fly.io Deployment Script for Gotenberg Service
# This script helps configure and deploy the Gotenberg service to Fly.io
# The Gotenberg service will be private and only accessible from complexitree-server

set -euo pipefail

echo "🚀 Gotenberg Service - Fly.io Deployment"
echo "========================================="
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
APP_NAME=$(grep "^app = " fly-gotenberg.toml | cut -d'"' -f2 | head -1)

if [ -z "$APP_NAME" ]; then
    echo "❌ Error: Could not find app name in fly-gotenberg.toml"
    exit 1
fi

echo "📱 App name: $APP_NAME"
echo ""

# Check if app exists on Fly.io
# Try to use jq for reliable JSON parsing, fallback to grep if jq is not available
if command -v jq &> /dev/null; then
    APP_EXISTS=$(flyctl apps list --json 2>/dev/null | jq -r '.[].Name' | grep -cx "$APP_NAME" || echo "0")
else
    APP_EXISTS=$(flyctl apps list --json 2>/dev/null | grep -c "\"Name\":\"$APP_NAME\"" || echo "0")
fi

if [ "$APP_EXISTS" -gt 0 ]; then
    echo "✅ App '$APP_NAME' exists on Fly.io"
else
    echo "⚠️  App '$APP_NAME' does not exist. Creating it now..."
    flyctl apps create "$APP_NAME"
fi

echo ""
echo "🔒 This Gotenberg service will be PRIVATE (no public access)"
echo "   It will only be accessible via Fly.io private networking"
echo ""

# Check if main server app exists
MAIN_APP="complexitree-server"
if command -v jq &> /dev/null; then
    MAIN_APP_EXISTS=$(flyctl apps list --json 2>/dev/null | jq -r '.[].Name' | grep -cx "$MAIN_APP" || echo "0")
else
    MAIN_APP_EXISTS=$(flyctl apps list --json 2>/dev/null | grep -c "\"Name\":\"$MAIN_APP\"" || echo "0")
fi

if [ "$MAIN_APP_EXISTS" -gt 0 ]; then
    echo "✅ Main app '$MAIN_APP' found"
else
    echo "⚠️  Warning: Main app '$MAIN_APP' not found"
    echo "   Make sure to deploy the main app first using ./deploy-fly.sh"
fi

echo ""
echo "📦 Deploying Gotenberg service..."
flyctl deploy --config fly-gotenberg.toml

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🔐 Important: Setting up private networking..."
echo ""
echo "To allow complexitree-server to access Gotenberg:"
echo "  1. Both apps are now in your Fly.io organization's private network"
echo "  2. The Gotenberg app is accessible at: http://$APP_NAME.internal:3000"
echo "  3. Set the GOTENBERG_URL secret in complexitree-server:"
echo ""
echo "     flyctl secrets set GOTENBERG_URL=http://$APP_NAME.internal:3000 --app complexitree-server"
echo ""
echo "📊 Useful commands:"
echo "  - View status:        flyctl status --app $APP_NAME"
echo "  - View logs:          flyctl logs --app $APP_NAME"
echo "  - Scale machines:     flyctl scale count 0-2 --region fra --app $APP_NAME"
echo "  - List machines:      flyctl machines list --app $APP_NAME"
echo ""
echo "🔒 Security: Gotenberg has no public endpoints and is only accessible"
echo "   via Fly.io private networking by apps in your organization."
echo ""
