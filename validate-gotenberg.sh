#!/bin/bash

# Validation script for Gotenberg Fly.io integration
# This script helps verify that Gotenberg is correctly deployed and accessible

set -euo pipefail

echo "🔍 Gotenberg Integration Validation"
echo "==================================="
echo ""

# Check if flyctl is installed
if ! command -v flyctl &> /dev/null; then
    echo "❌ Error: flyctl is not installed."
    exit 1
fi

echo "✅ flyctl is installed"

# Check if user is logged in
if ! flyctl auth whoami &> /dev/null; then
    echo "❌ Not logged in to Fly.io"
    exit 1
fi

echo "✅ Logged in to Fly.io"
echo ""

# Check if Gotenberg app exists
GOTENBERG_APP="gotenberg-complexitree"
MAIN_APP="complexitree-server"

echo "📋 Checking apps..."
echo ""

# Check if Gotenberg app exists using JSON output for reliability
# Try to use jq for reliable JSON parsing, fallback to grep if jq is not available
if command -v jq &> /dev/null; then
    GOTENBERG_EXISTS=$(flyctl apps list --json 2>/dev/null | jq -r '.[].Name' | grep -cx "$GOTENBERG_APP" || echo "0")
else
    GOTENBERG_EXISTS=$(flyctl apps list --json 2>/dev/null | grep -c "\"Name\":\"$GOTENBERG_APP\"" || echo "0")
fi

if [ "$GOTENBERG_EXISTS" -gt 0 ]; then
    echo "✅ Gotenberg app '$GOTENBERG_APP' exists"
    
    # Check status
    echo ""
    echo "📊 Gotenberg Status:"
    flyctl status --app "$GOTENBERG_APP" || echo "⚠️  Could not get status"
    
    echo ""
    echo "🔍 Checking for public IPs..."
    # Use JSON output for more reliable parsing
    if command -v jq &> /dev/null; then
        PUBLIC_IP_COUNT=$(flyctl ips list --app "$GOTENBERG_APP" --json 2>/dev/null | jq '. | length' || echo "0")
    else
        PUBLIC_IP_COUNT=$(flyctl ips list --app "$GOTENBERG_APP" --json 2>/dev/null | grep -c "\"Address\"" || echo "0")
    fi
    
    if [ "$PUBLIC_IP_COUNT" -eq 0 ]; then
        echo "✅ No public IPs (private network only) ✓"
    else
        echo "⚠️  Warning: $PUBLIC_IP_COUNT public IP(s) found"
        flyctl ips list --app "$GOTENBERG_APP"
        echo "   Gotenberg may be publicly accessible!"
    fi
else
    echo "❌ Gotenberg app '$GOTENBERG_APP' not found"
    echo "   Deploy it using: ./deploy-gotenberg.sh"
fi

echo ""

if command -v jq &> /dev/null; then
    MAIN_EXISTS=$(flyctl apps list --json 2>/dev/null | jq -r '.[].Name' | grep -cx "$MAIN_APP" || echo "0")
else
    MAIN_EXISTS=$(flyctl apps list --json 2>/dev/null | grep -c "\"Name\":\"$MAIN_APP\"" || echo "0")
fi

if [ "$MAIN_EXISTS" -gt 0 ]; then
    echo "✅ Main app '$MAIN_APP' exists"
    
    # Check if GOTENBERG_URL secret is set
    echo ""
    echo "🔐 Checking secrets..."
    if flyctl secrets list --app "$MAIN_APP" | grep -q "GOTENBERG_URL"; then
        echo "✅ GOTENBERG_URL secret is set in main app"
    else
        echo "⚠️  GOTENBERG_URL secret not found in main app"
        echo "   Set it using:"
        echo "   flyctl secrets set GOTENBERG_URL=http://$GOTENBERG_APP.internal:3000 --app $MAIN_APP"
    fi
else
    echo "❌ Main app '$MAIN_APP' not found"
    echo "   Deploy it using: ./deploy-fly.sh"
fi

echo ""
echo "🧪 Testing private network connection..."
echo "   (This requires the main app to be running)"
echo ""

if [ "$MAIN_EXISTS" -gt 0 ]; then
    # Try to get a running machine
    MAIN_MACHINES=$(flyctl machines list --app "$MAIN_APP" --json 2>/dev/null || echo "[]")
    
    if [ "$MAIN_MACHINES" != "[]" ] && [ -n "$MAIN_MACHINES" ]; then
        echo "📝 To test the connection manually:"
        echo "   1. SSH into the main app:"
        echo "      flyctl ssh console --app $MAIN_APP"
        echo ""
        echo "   2. Test connection to Gotenberg:"
        echo "      curl -v http://$GOTENBERG_APP.internal:3000/health"
        echo "      or"
        echo "      wget -O- http://$GOTENBERG_APP.internal:3000/health"
    else
        echo "⚠️  No running machines found in main app"
        echo "   Start the main app first to test connectivity"
    fi
else
    echo "⚠️  Cannot test connection: Main app not found"
fi

echo ""
echo "✅ Validation complete!"
echo ""
echo "📚 For more information, see:"
echo "   - GOTENBERG.md (comprehensive guide)"
echo "   - FLY_REFERENCE.md (quick commands)"
echo "   - README.md (deployment instructions)"
echo ""
