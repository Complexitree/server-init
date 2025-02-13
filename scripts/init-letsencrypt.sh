#!/bin/bash

set -e

DOMAIN=DOMAIN_PLACEHOLDER
EMAIL=EMAIL_PLACEHOLDER
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"

echo "🔐 Erstelle Let's Encrypt Zertifikat für $DOMAIN..."

# 🔹 Stelle sicher, dass das Verzeichnis für die Zertifikatsanfrage existiert
mkdir -p /var/www/certbot

# Falls Zertifikat bereits existiert, nicht erneut anfordern
if [ -d "$CERT_PATH" ]; then
    echo "✅ Zertifikat für $DOMAIN existiert bereits. Überspringe Anforderung."
else
    echo "📜 Fordere Let's Encrypt Zertifikat an..."
    certbot certonly --webroot -w /var/www/certbot -d $DOMAIN --email $EMAIL --agree-tos --no-eff-email --force-renewal
fi

echo "✅ SSL-Zertifikat wurde erfolgreich eingerichtet."
