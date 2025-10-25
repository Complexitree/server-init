#!/bin/bash

set -e  # Beendet das Skript bei Fehlern

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "%########%@ %###########%% %####################  %###########%@ %#%%#%@     %#########@ %%#@##@ ###%#%  ##%##% ############% %############% %#########%% %#########@"
echo -e "##%%%%%%%%  ###%%%%%%%%##% %##%%%%%%%%%%%%%%%%##  ###%%%%%%%%#%% %#%%#%@     %#%%%%%%%%@ ###@##@ ###%##  ##%##% %%%%%%%%%%%%@ %##%%%%%%%%##% %##%%%%%%%%@ %#%%%%%%%%@"
echo -e "##@##%%%%%@ ###%##%%##%##% %##%##%%##%##%%%##%##  ###%##%%##%#%% %#%%#%@     %#%%#%%%%%@ ###@##@ ###%##  ##%##% %%%%##%##%%%@ %##%##%%##%##% %##%##%%%%%@ %#%###%%%%@"
echo -e "##@##@      ###%#% %##%##% %##%#%% ##%##@ %##%##  ###%## %##%#%% %#%%#%@     %#%%#@      ###@##@ ###%##  ##%##%     ##%#%@    %##%#%@%##%##% %##%##%      %#%##%@    "
echo -e "##@##@      ###%#% %##%##% %##%#%% ##%##@ %##%##  ###%## %##%#%% %#%%#%@     %#%%#@      ###@##@ ###%##  ##%##%     ##%#%@    %##%#%@%##%##% %##%##%      %#%##%@    "
echo -e "##@##@      ###%#% %##%##% %##%#%% ##%##@ %##%##  ###%## %##%#%% %#%%#%@     %#%%#@       ###%##%##%#%@  ##%##%     ##%#%@    %##%######%##% %##%##%      %#%##%@    "
echo -e "##@##@      ###%#% %##%##% %##%#%% ##%##@ %##%##  ###%## %##%#%% %#%%#%@     %#%%#@        %##%###%##@   ##%##%     ##%#%@    %##@###%%####% %##%##%      %#%##%@    "
echo -e "##@##@      ###%#% %##%##% %##%#%% ##%##@ %##%##  ###%## %##%#%% %#%%#%@     %#%%######@    %##%#%##@    ##%##%     ##%#%@    %##%###%%#%%%@ %##%######%@ %#%#######@"
echo -e "##@##@      ###%#% %##%##% %##%#%% ##%##@ %##%##  ###%## %##%#%% %#%%#%@     %#%@%%%%%%@     %##%##@     ##%##%     ##%#%@    %##%#%##%##%   %##%@%%%%%@@ %#%%%%%%%@@"
echo -e "##@##@      ###%#% %##%##% %##%#%% ##%##@ %##%##  ###%##%%##%#%% %#%%#%@     %#%%######@    ###%%%##%    ##%##%     ##%#%@    %##%#%%#%%#%   %##%######%% %#%#######@"
echo -e "##@##@      ###%#% %##%##% %##%#%% ##%##@ %##%##  ###%#####%%#%% %#%%#%@     %#%%#@        ###%###%##%   ##%##%     ##%#%@    %##%#%%##%##%  %##%##%      %#%##%@    "
echo -e "##@##@      ###%#% %##%##% %##%#%% ##%##@ %##%##  ###%########%% %#%%#%@     %#%%#@       ###%##%##%##%  ##%##%     ##%#%@    %##%#%@%#%%#%  %##%##%      %#%##%@    "
echo -e "##@#######@ ###%######%##% %##%#%% ##%##@ %##%##  ###%##@%%%%%@  %#%%######%@%#%%######@ %##@##%%######  ##%##%     ##%#%@    %##%#%@###%##% %##%######%% %#%#######@"
echo -e "##%#%%%%%%  ###%%%%%%%###% %##%#%% ##%##@ %##%##  ###%##         %##%#%%%%%@ %#%#%%%%%%@ ###@##@ ###%##  ##%##%     ##%#%@    %##%#%@%##%%#%@%##%#%%%%%%@ %####%%%%%@"
echo -e "%########%@ %###########%% %#%%#%% %#@%#@ @#%%#%  %#%%#%         %#########@ %#########@ %%#@##@ %#%%%%  ##%%%%     #%%#%@    @#%%#%  %#%%#%@%%########%@ %#########@"
echo ""
echo ""
echo -e "${GREEN}Willkommen zum Complexitree-Server Setup${NC}"
echo ""
echo -e "Dieses Skript installiert und konfiguriert die notwendigen Komponenten, einschließlich Docker, Zertifikatsverwaltung und Server-Setup."
echo -e "Bitte stellen Sie sicher, dass die eingegebene(n) Domain(s) bereits im DNS auf diesen Server zeigen, bevor Sie fortfahren.${NC}"
echo ""

echo -e "${GREEN}🚀 Setup für Complexitree-Server${NC}"

# 🔹 1. Root-Rechte prüfen
if [[ $EUID -ne 0 ]]; then
   echo "⚠️  Bitte das Skript mit sudo ausführen!"
   exit 1
fi

# 🔹 2. Abfrage von Domain & Umgebungsvariablen
read -p "🌍 Unter welcher Domain soll der Server erreichbar sein (mehrere Domains mit Leerzeichen getrennt): " DOMAIN
read -p "💎 Welche E-Mailadresse soll für Let's Encrypt verwendet werden: " EMAIL

echo -e "${GREEN}🔑 Bitte geben Sie den Wert für XTREE_KEY_STORE_ACCESS_GRANT ein:${NC}"
read XTREE_KEY_STORE_ACCESS_GRANT

echo -e "${GREEN}🔑 Bitte geben Sie den Wert für XTREE_KEY_STORE_BUCKET ein (Standard: keys):${NC}"
read XTREE_KEY_STORE_BUCKET
XTREE_KEY_STORE_BUCKET=${XTREE_KEY_STORE_BUCKET:-keys}

echo -e "${GREEN}🔑 Bitte geben Sie den Wert für XTREE_PUBLISH_CONTEXT_STORE_ACCESS_GRANT ein:${NC}"
read XTREE_PUBLISH_CONTEXT_STORE_ACCESS_GRANT

echo -e "${GREEN}🔑 Bitte geben Sie den Wert für XTREE_PUBLISH_CONTEXT_STORE_BUCKET ein (Standard: publishcontext):${NC}"
read XTREE_PUBLISH_CONTEXT_STORE_BUCKET
XTREE_PUBLISH_CONTEXT_STORE_BUCKET=${XTREE_PUBLISH_CONTEXT_STORE_BUCKET:-publishcontext}

echo -e "${GREEN}🔑 Bitte geben Sie den Wert für XTREE_USER_SETTINGS_STORE_ACCESS_GRANT ein:${NC}"
read XTREE_USER_SETTINGS_STORE_ACCESS_GRANT

echo -e "${GREEN}🔑 Bitte geben Sie den Wert für XTREE_USER_SETTINGS_STORE_BUCKET ein (Standard: usersettings):${NC}"
read XTREE_USER_SETTINGS_STORE_BUCKET
XTREE_USER_SETTINGS_STORE_BUCKET=${XTREE_USER_SETTINGS_STORE_BUCKET:-usersettings}

echo -e "${GREEN}🔑 Bitte geben Sie den OpenAI-API-Key für KI-Funktionen ein:${NC}"
read XTREE_OPENAI_API_KEY

echo -e "${GREEN}🔑 Bitte geben Sie den Docupipe-API-Key für KI-Datenextratkion ein:${NC}"
read XTREE_DOCUPIPE_API_KEY

echo -e "${GREEN}🔑 Bitte geben Sie die Entera Client-ID ein:${NC}"
read ENTERA_CLIENT_ID

echo -e "${GREEN}🔑 Bitte geben Sie das Entera Client-Secret ein:${NC}"
read ENTERA_CLIENT_SECRET

echo -e "${GREEN}🔑 Temporär - XTREE_TEMP_ACCESSGRANT:${NC}"
read XTREE_TEMP_ACCESSGRANT
echo -e "${GREEN}🔑 Temporär - XTREE_TEMP_KEYHASH:${NC}"
read XTREE_TEMP_KEYHASH

read -p "🔄 Sollen die Docker-Container automatisch täglich aktualisiert werden? (y/n): " AUTO_UPDATE

# 🔹 3. Installiere Docker
echo -e "${GREEN}📦 Installiere Docker und Docker Compose...${NC}"
apt-get update
apt-get install -y ca-certificates curl gnupg

# GPG-Schlüssel für Docker hinzufügen
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | tee /etc/apt/keyrings/docker.asc > /dev/null
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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

# 🔹 5. Ersetze Platzhalter in `docker-compose.yml` und `nginx.conf`
cd /opt/docker-setup
MAIN_DOMAIN_PLACEHOLDER="$(echo $DOMAIN | awk '{print $1}')"
echo "MAIN_DOMAIN_PLACEHOLDER is: $MAIN_DOMAIN_PLACEHOLDER"
sed -i "s|MAIN_DOMAIN_PLACEHOLDER|${MAIN_DOMAIN_PLACEHOLDER}|g" nginx.conf
sed -i "s|DOMAIN_PLACEHOLDER|${DOMAIN}|g" nginx.conf
sed -i "s/EMAIL_PLACEHOLDER/$EMAIL/g" nginx.conf
sed -i "s/XTREE_KEY_STORE_ACCESS_GRANT_PLACEHOLDER/$XTREE_KEY_STORE_ACCESS_GRANT/g" docker-compose.yml
sed -i "s/XTREE_KEY_STORE_BUCKET_PLACEHOLDER/$XTREE_KEY_STORE_BUCKET/g" docker-compose.yml
sed -i "s/XTREE_PUBLISH_CONTEXT_STORE_ACCESS_GRANT_PLACEHOLDER/$XTREE_PUBLISH_CONTEXT_STORE_ACCESS_GRANT/g" docker-compose.yml
sed -i "s/XTREE_PUBLISH_CONTEXT_STORE_BUCKET_PLACEHOLDER/$XTREE_PUBLISH_CONTEXT_STORE_BUCKET/g" docker-compose.yml
sed -i "s/XTREE_USER_SETTINGS_STORE_ACCESS_GRANT_PLACEHOLDER/$XTREE_USER_SETTINGS_STORE_ACCESS_GRANT/g" docker-compose.yml
sed -i "s/XTREE_USER_SETTINGS_STORE_BUCKET_PLACEHOLDER/$XTREE_USER_SETTINGS_STORE_BUCKET/g" docker-compose.yml
sed -i "s/XTREE_OPENAI_API_KEY_PLACEHOLDER/$XTREE_OPENAI_API_KEY/g" docker-compose.yml
sed -i "s/XTREE_DOCUPIPE_API_KEY_PLACEHOLDER/$XTREE_DOCUPIPE_API_KEY/g" docker-compose.yml
sed -i "s/ENTERA_CLIENT_ID_PLACEHOLDER/$ENTERA_CLIENT_ID/g" docker-compose.yml
sed -i "s/ENTERA_CLIENT_SECRET_PLACEHOLDER/$ENTERA_CLIENT_SECRET/g" docker-compose.yml

# 🔹 6. SSL-Zertifikat einrichten
echo -e "${GREEN}🔒 Das Nginx ACME Modul kümmert sich beim ersten Start automatisch um die Zertifikatsverwaltung.${NC}"

# 🔹 7. Docker-Compose starten
echo -e "${GREEN}🚀 Starte Docker-Container...${NC}"
docker compose up -d
sleep 10  # Warte auf vollständigen Start

# 🔹 8. Falls automatische Updates aktiviert wurden, Cronjob einrichten
if [[ "$AUTO_UPDATE" == "y" ]]; then
    echo -e "${GREEN}📅 Richte tägliche automatische Updates ein...${NC}"
    
    cat <<EOF > /opt/docker-setup/update-containers.sh
#!/bin/bash

LOG_FILE="/var/log/docker-update.log"
LOCK_FILE="/tmp/docker-update.lock"

# Verwende flock, um parallele Ausführungen zu verhindern
{
    echo "🔄 Starte Update-Prozess: \$(date)" | tee -a "\$LOG_FILE" | logger -t docker-update
    cd /opt/docker-setup || { echo "❌ Fehler: Verzeichnis nicht gefunden!" | tee -a "\$LOG_FILE" | logger -t docker-update; exit 1; }

    docker compose pull | tee -a "\$LOG_FILE" | logger -t docker-update
    docker compose up -d --remove-orphans | tee -a "\$LOG_FILE" | logger -t docker-update
    docker image prune -f | tee -a "\$LOG_FILE" | logger -t docker-update

    echo "✅ Update abgeschlossen: \$(date)" | tee -a "\$LOG_FILE" | logger -t docker-update
} 2>&1 | tee -a "\$LOG_FILE" | logger -t docker-update

EOF

    # Mach die Datei ausführbar
    chmod +x /opt/docker-setup/update-containers.sh

    # Cronjob sicher hinzufügen
    crontab -l > /tmp/mycron 2>/dev/null || true  # Falls keine Crontab existiert, wird eine neue erstellt
    echo "0 3 * * * flock -n /tmp/docker-update.lock /opt/docker-setup/update-containers.sh" >> /tmp/mycron
    crontab /tmp/mycron
    rm /tmp/mycron

    echo -e "${GREEN}✅ Automatische Updates sind jetzt aktiv.${NC}"
else
    echo -e "${GREEN}❌ Automatische Updates wurden deaktiviert.${NC}"
fi


echo -e "${GREEN}✅ Setup abgeschlossen! Der Complexitree-Server läuft nun unter: https://$DOMAIN ${NC}"
