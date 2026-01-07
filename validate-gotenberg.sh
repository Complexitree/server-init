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

if flyctl apps list | grep -q "^$GOTENBERG_APP[[:space:]]"; then
    echo "✅ Gotenberg app '$GOTENBERG_APP' exists"
    
    # Check status
    echo ""
    echo "📊 Gotenberg Status:"
    flyctl status --app "$GOTENBERG_APP" || echo "⚠️  Could not get status"
    
    echo ""
    echo "🔍 Checking for public IPs..."
    PUBLIC_IPS=$(flyctl ips list --app "$GOTENBERG_APP" 2>/dev/null || echo "")
    if [ -z "$PUBLIC_IPS" ] || [ "$PUBLIC_IPS" = "No IP addresses found" ]; then
        echo "✅ No public IPs (private network only) ✓"
    else
        echo "⚠️  Warning: Public IPs found:"
        echo "$PUBLIC_IPS"
        echo "   Gotenberg may be publicly accessible!"
    fi
else
    echo "❌ Gotenberg app '$GOTENBERG_APP' not found"
    echo "   Deploy it using: ./deploy-gotenberg.sh"
fi

echo ""

if flyctl apps list | grep -q "^$MAIN_APP[[:space:]]"; then
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

if flyctl apps list | grep -q "^$MAIN_APP[[:space:]]"; then
    # Try to get a running machine
    MAIN_MACHINES=$(flyctl machines list --app "$MAIN_APP" -j 2>/dev/null || echo "[]")
    
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
