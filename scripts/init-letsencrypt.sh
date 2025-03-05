#!/bin/bash

set -e  # Beende Skript bei Fehlern

DOMAIN="DOMAIN_PLACEHOLDER"
EMAIL="EMAIL_PLACEHOLDER"
CERT_PATH="/etc/letsencrypt/live/$(echo $DOMAIN | awk '{print $1}')"  # Erste Domain als Hauptdomain

echo "🔐 Erstelle Let's Encrypt Zertifikat für $DOMAIN..."

# 🔹 Falls Zertifikat bereits existiert, nicht erneut anfordern
if [ -d "$CERT_PATH" ]; then
    echo "✅ Zertifikat für $DOMAIN existiert bereits. Überspringe Anforderung."
else
    echo "📜 Fordere Let's Encrypt Zertifikat für $DOMAIN an..."

    certbot certonly --standalone $(echo $DOMAIN | awk '{for (i=1; i<=NF; i++) print "-d", $i}') \
        --email "$EMAIL" --agree-tos --no-eff-email --force-renewal

    echo "🔧 Setze Berechtigungen für Nginx..."
    chown -R root:www-data /etc/letsencrypt
    chmod -R 750 /etc/letsencrypt
fi

echo "✅ SSL-Zertifikat wurde erfolgreich eingerichtet."
