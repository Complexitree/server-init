#!/bin/bash

set -e  # Beende Skript bei Fehlern

DOMAIN=DOMAIN_PLACEHOLDER
EMAIL=EMAIL_PLACEHOLDER
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"

echo "🔐 Erstelle Let's Encrypt Zertifikat für $DOMAIN..."

# 🔹 Starte einen temporären Webserver für die Zertifikatsanfrage
echo "🌍 Starte temporären Nginx für ACME-Challenge..."
docker run -d --name certbot-nginx -p 80:80 \
  -v certbot-www:/var/www/certbot \
  nginx:alpine

# Warte kurz, damit Nginx startet
sleep 5

# 🔹 Falls Zertifikat bereits existiert, nicht erneut anfordern
if [ -d "$CERT_PATH" ]; then
    echo "✅ Zertifikat für $DOMAIN existiert bereits. Überspringe Anforderung."
else
    echo "📜 Fordere Let's Encrypt Zertifikat an..."
    mkdir -p /var/www/certbot
    certbot certonly --webroot -w /var/www/certbot -d $DOMAIN --email $EMAIL --agree-tos --no-eff-email --force-renewal
fi

# 🔹 Stoppe den temporären Nginx-Container
echo "🛑 Stoppe temporären Nginx..."
docker stop certbot-nginx
docker rm certbot-nginx

echo "✅ SSL-Zertifikat wurde erfolgreich eingerichtet."
