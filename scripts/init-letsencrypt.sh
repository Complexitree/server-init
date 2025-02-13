#!/bin/bash

set -e  # Beende Skript bei Fehlern

DOMAIN=DOMAIN_PLACEHOLDER
EMAIL=EMAIL_PLACEHOLDER
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"

echo "🔐 Erstelle Let's Encrypt Zertifikat für $DOMAIN..."

# 🔹 Falls Zertifikat bereits existiert, nicht erneut anfordern
if [ -d "$CERT_PATH" ]; then
    echo "✅ Zertifikat für $DOMAIN existiert bereits. Überspringe Anforderung."
else
    echo "📜 Fordere Let's Encrypt Zertifikat an..."
    certbot certonly --standalone -d "$DOMAIN" --email "$EMAIL" --agree-tos --no-eff-email --force-renewal
fi

echo "✅ SSL-Zertifikat wurde erfolgreich eingerichtet."
