#!/bin/bash

set -e

DOMAIN=DOMAIN_PLACEHOLDER
EMAIL=EMAIL_PLACEHOLDER
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"

if [ -d "$CERT_PATH" ]; then
    echo "Zertifikat für $DOMAIN existiert bereits. Überspringe Anforderung."
else
    echo "Fordere Let's Encrypt Zertifikat für $DOMAIN an..."
    certbot certonly --webroot -w /var/www/certbot -d $DOMAIN --email $EMAIL --agree-tos --no-eff-email --force-renewal
fi

echo "SSL-Zertifikat wurde erfolgreich eingerichtet."
