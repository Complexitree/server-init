#!/bin/bash

set -e  # Beendet das Skript bei Fehlern

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Setup für Complexitree-Server${NC}"

# 🔹 1. Root-Rechte prüfen
if [[ $EUID -ne 0 ]]; then
   echo "⚠️  Bitte das Skript mit sudo ausführen!"
   exit 1
fi

# 🔹 2. Abfrage von Domain & Umgebungsvariablen
read -p "🌍 Unter welcher Domain soll der Server erreichbar sein (mehrere Domains mit Leerzeichen getrennt): " DOMAIN
read -p "💎 Welche E-Mailadresse soll für Let's Encrypt verwendet werden: " EMAIL
read -p "🔑 Wert für Umgebungsvariable MY_KEY: " MY_KEY
read -p "🔄 Sollen die Docker-Container automatisch täglich aktualisiert werden? (y/n): " AUTO_UPDATE

# 🔹 3. Installiere Docker & Certbot
echo -e "${GREEN}📦 Installiere Docker, Docker Compose & Certbot...${NC}"
apt-get update
apt-get install -y ca-certificates curl gnupg

# GPG-Schlüssel für Docker hinzufügen
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | tee /etc/apt/keyrings/docker.asc > /dev/null
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin certbot

# Docker-Dienst starten und aktivieren
systemctl enable --now docker

# 🔹 4. Repository mit den Konfigurationsdateien herunterladen
echo -e "${GREEN}📅 Lade Konfigurationsdateien von GitHub...${NC}"
if [ -d "/opt/docker-setup/.git" ]; then
    echo "🔄 Repository existiert bereits. Aktualisiere mit git pull..."
    cd /opt/docker-setup
    git pull
else
    echo "📅 Klone Repository..."
    git clone https://github.com/Complexitree/server-init.git /opt/docker-setup
fi

# 🔹 5. Ersetze Platzhalter in `docker-compose.yml` und `init-letsencrypt.sh`
cd /opt/docker-setup
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" docker-compose.yml
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" scripts/init-letsencrypt.sh
sed -i "s/EMAIL_PLACEHOLDER/$EMAIL/g" scripts/init-letsencrypt.sh
sed -i "s/MY_KEY_PLACEHOLDER/$MY_KEY/g" docker-compose.yml

# 🔹 6. Docker-Compose starten
echo -e "${GREEN}🚀 Starte Docker-Container...${NC}"
docker compose up -d
sleep 10  # Warte auf vollständigen Start

# 🔹 7. SSL-Zertifikat beantragen
echo -e "${GREEN}🔒 Erstelle Let's Encrypt Zertifikat...${NC}"
scripts/init-letsencrypt.sh

# 🔹 8. Falls automatische Updates aktiviert wurden, Cronjob einrichten
if [[ "$AUTO_UPDATE" == "y" ]]; then
    echo -e "${GREEN}📅 Richte tägliche automatische Updates ein...${NC}"

    cat <<EOF > /opt/docker-setup/update-containers.sh
#!/bin/bash
echo "🔄 Starte Update-Prozess: \$(date)" >> /var/log/docker-update.log
cd /opt/docker-setup
docker compose pull >> /var/log/docker-update.log 2>&1
docker compose up -d --remove-orphans >> /var/log/docker-update.log 2>&1
docker image prune -f >> /var/log/docker-update.log 2>&1
echo "📅 Update abgeschlossen: \$(date)" >> /var/log/docker-update.log
EOF

    chmod +x /opt/docker-setup/update-containers.sh
    (crontab -l 2>/dev/null; echo "0 3 * * * /opt/docker-setup/update-containers.sh") | crontab -
    echo -e "${GREEN}✅ Automatische Updates sind jetzt aktiv.${NC}"
else
    echo -e "${GREEN}❌ Automatische Updates wurden deaktiviert.${NC}"
fi

echo -e "${GREEN}✅ Setup abgeschlossen! Der Complexitree-Server läuft nun unter: https://$DOMAIN ${NC}"
