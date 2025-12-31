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
# Function to parse config from URL
parse_config_from_url() {
    local config_url=$1
    local temp_config="/tmp/init-config-$$.txt"
    
    # Validate URL format (only allow http/https protocols)
    if [[ ! "$config_url" =~ ^https?:// ]]; then
        echo -e "❌ Ungültige URL. Nur HTTP und HTTPS URLs sind erlaubt."
        return 1
    fi
    
    echo -e "${GREEN}📥 Lade Konfiguration von $config_url...${NC}"
    
    if wget -q -O "$temp_config" "$config_url"; then
        echo -e "${GREEN}✅ Konfiguration erfolgreich geladen${NC}"
        
        # Define allowed configuration keys (whitelist)
        local allowed_keys=(
            "XTREE_KEY_STORE_ACCESS_GRANT"
            "XTREE_KEY_STORE_BUCKET"
            "XTREE_PUBLISH_CONTEXT_STORE_ACCESS_GRANT"
            "XTREE_PUBLISH_CONTEXT_STORE_BUCKET"
            "XTREE_USER_SETTINGS_STORE_ACCESS_GRANT"
            "XTREE_USER_SETTINGS_STORE_BUCKET"
            "XTREE_TABLE_DATA_ACCESS_GRANT"
            "XTREE_OPENAI_API_KEY"
            "XTREE_DOCUPIPE_API_KEY"
            "XTREE_COUNTER_API_KEY"
            "CLERK_SECRET_KEY"
            "CLERK_PUBLISHABLE_KEY_FOREST"
            "ENTERA_CLIENT_ID"
            "ENTERA_CLIENT_SECRET"
            "SUPABASE_URL"
            "SUPABASE_SERVICE_KEY"
            "SUPABASE_PUBLISHABLE_KEY"
            "XTREE_TEMP_ACCESSGRANT"
            "XTREE_TEMP_KEYHASH"
            "AUTO_UPDATE"
        )
        
        # Parse config file
        while IFS=: read -r key value || [ -n "$key" ]; do
            # Skip empty lines and comments
            [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
            
            # Trim whitespace
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs)
            
            # Skip if key or value is empty
            [[ -z "$key" || -z "$value" ]] && continue
            
            # Check if key is in whitelist
            local key_allowed=false
            for allowed_key in "${allowed_keys[@]}"; do
                if [[ "$key" == "$allowed_key" ]]; then
                    key_allowed=true
                    break
                fi
            done
            
            if [[ "$key_allowed" == false ]]; then
                echo -e "⚠️  Warnung: Unbekannter Konfigurationsparameter '$key' wird ignoriert"
                continue
            fi
            
            # Export the variable
            case "$key" in
                XTREE_KEY_STORE_ACCESS_GRANT) XTREE_KEY_STORE_ACCESS_GRANT="$value" ;;
                XTREE_KEY_STORE_BUCKET) XTREE_KEY_STORE_BUCKET="$value" ;;
                XTREE_PUBLISH_CONTEXT_STORE_ACCESS_GRANT) XTREE_PUBLISH_CONTEXT_STORE_ACCESS_GRANT="$value" ;;
                XTREE_PUBLISH_CONTEXT_STORE_BUCKET) XTREE_PUBLISH_CONTEXT_STORE_BUCKET="$value" ;;
                XTREE_USER_SETTINGS_STORE_ACCESS_GRANT) XTREE_USER_SETTINGS_STORE_ACCESS_GRANT="$value" ;;
                XTREE_USER_SETTINGS_STORE_BUCKET) XTREE_USER_SETTINGS_STORE_BUCKET="$value" ;;
                XTREE_TABLE_DATA_ACCESS_GRANT) XTREE_TABLE_DATA_ACCESS_GRANT="$value" ;;
                XTREE_OPENAI_API_KEY) XTREE_OPENAI_API_KEY="$value" ;;
                XTREE_DOCUPIPE_API_KEY) XTREE_DOCUPIPE_API_KEY="$value" ;;
                XTREE_COUNTER_API_KEY) XTREE_COUNTER_API_KEY="$value" ;;
                CLERK_SECRET_KEY) CLERK_SECRET_KEY="$value" ;;
                CLERK_PUBLISHABLE_KEY_FOREST) CLERK_PUBLISHABLE_KEY_FOREST="$value" ;;
                ENTERA_CLIENT_ID) ENTERA_CLIENT_ID="$value" ;;
                ENTERA_CLIENT_SECRET) ENTERA_CLIENT_SECRET="$value" ;;
                SUPABASE_URL) SUPABASE_URL="$value" ;;
                SUPABASE_SERVICE_KEY) SUPABASE_SERVICE_KEY="$value" ;;
                SUPABASE_PUBLISHABLE_KEY) SUPABASE_PUBLISHABLE_KEY="$value" ;;
                XTREE_TEMP_ACCESSGRANT) XTREE_TEMP_ACCESSGRANT="$value" ;;
                XTREE_TEMP_KEYHASH) XTREE_TEMP_KEYHASH="$value" ;;
                AUTO_UPDATE) AUTO_UPDATE="$value" ;;
            esac
        done < "$temp_config"
        
        rm -f "$temp_config"
        return 0
    else
        echo -e "❌ Fehler beim Herunterladen der Konfiguration von $config_url"
        rm -f "$temp_config"
        return 1
    fi
}

# Always ask for DOMAIN and EMAIL from user first
read -p "🌍 Unter welcher Domain soll der Server erreichbar sein (mehrere Domains mit Leerzeichen getrennt): " DOMAIN
read -p "💎 Welche E-Mailadresse soll für Let's Encrypt verwendet werden: " EMAIL

# Ask if user wants to provide init-url
read -p "📋 Möchten Sie eine Init-URL mit allen Konfigurationsparametern angeben? (y/n): " USE_INIT_URL

if [[ "$USE_INIT_URL" == "y" || "$USE_INIT_URL" == "Y" ]]; then
    read -p "🔗 Bitte geben Sie die Init-URL ein: " INIT_URL
    
    if parse_config_from_url "$INIT_URL"; then
        echo -e "${GREEN}✅ Konfiguration aus URL geladen${NC}"
        CONFIG_FROM_URL=true
    else
        echo -e "⚠️  Fehler beim Laden der Konfiguration. Fahre mit manueller Eingabe fort..."
        CONFIG_FROM_URL=false
    fi
else
    CONFIG_FROM_URL=false
fi

# If config was not loaded from URL, ask for parameters interactively
if [[ "$CONFIG_FROM_URL" != true ]]; then
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

    echo -e "${GREEN}🔑 Bitte geben Sie den Wert für den Table-Data Access Grant ein:${NC}"
    read XTREE_TABLE_DATA_ACCESS_GRANT

    echo -e "${GREEN}🔑 Bitte geben Sie den OpenAI-API-Key für KI-Funktionen ein:${NC}"
    read XTREE_OPENAI_API_KEY

    echo -e "${GREEN}🔑 Bitte geben Sie den Docupipe-API-Key für KI-Datenextratkion ein:${NC}"
    read XTREE_DOCUPIPE_API_KEY

    echo -e "${GREEN}🔑 Bitte geben Sie den Counter-API-Key ein:${NC}"
    read XTREE_COUNTER_API_KEY

    echo -e "${GREEN}🔑 Bitte geben Sie den Clerk Secret Key ein:${NC}"
    read CLERK_SECRET_KEY

    echo -e "${GREEN}🔑 Bitte geben Sie den Clerk Publishable Key Forest ein:${NC}"
    read CLERK_PUBLISHABLE_KEY_FOREST

    echo -e "${GREEN}🔑 Bitte geben Sie die Entera Client-ID ein:${NC}"
    read ENTERA_CLIENT_ID

    echo -e "${GREEN}🔑 Bitte geben Sie das Entera Client-Secret ein:${NC}"
    read ENTERA_CLIENT_SECRET

    echo -e "${GREEN}🔑 Bitte geben Sie die Supabase URL ein:${NC}"
    read SUPABASE_URL

    echo -e "${GREEN}🔑 Bitte geben Sie den Supabase Service Key ein:${NC}"
    read SUPABASE_SERVICE_KEY

    echo -e "${GREEN}🔑 Bitte geben Sie den Supabase Publishable Key ein:${NC}"
    read SUPABASE_PUBLISHABLE_KEY

    echo -e "${GREEN}🔑 Temporär - XTREE_TEMP_ACCESSGRANT:${NC}"
    read XTREE_TEMP_ACCESSGRANT
    echo -e "${GREEN}🔑 Temporär - XTREE_TEMP_KEYHASH:${NC}"
    read XTREE_TEMP_KEYHASH

    read -p "🔄 Sollen die Docker-Container automatisch täglich aktualisiert werden? (y/n): " AUTO_UPDATE
fi

# Apply defaults for bucket names if not set
XTREE_KEY_STORE_BUCKET=${XTREE_KEY_STORE_BUCKET:-keys}
XTREE_PUBLISH_CONTEXT_STORE_BUCKET=${XTREE_PUBLISH_CONTEXT_STORE_BUCKET:-publishcontext}
XTREE_USER_SETTINGS_STORE_BUCKET=${XTREE_USER_SETTINGS_STORE_BUCKET:-usersettings}

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
MAIN_DOMAIN_PLACEHOLDER="$(echo $DOMAIN | awk '{print $1}')"
echo "MAIN_DOMAIN_PLACEHOLDER is: $MAIN_DOMAIN_PLACEHOLDER"
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" scripts/init-letsencrypt.sh
sed -i "s|MAIN_DOMAIN_PLACEHOLDER|${MAIN_DOMAIN_PLACEHOLDER}|g" nginx.conf
sed -i "s|DOMAIN_PLACEHOLDER|${DOMAIN}|g" nginx.conf
sed -i "s/EMAIL_PLACEHOLDER/$EMAIL/g" scripts/init-letsencrypt.sh
sed -i "s/XTREE_KEY_STORE_ACCESS_GRANT_PLACEHOLDER/$XTREE_KEY_STORE_ACCESS_GRANT/g" docker-compose.yml
sed -i "s/XTREE_KEY_STORE_BUCKET_PLACEHOLDER/$XTREE_KEY_STORE_BUCKET/g" docker-compose.yml
sed -i "s/XTREE_PUBLISH_CONTEXT_STORE_ACCESS_GRANT_PLACEHOLDER/$XTREE_PUBLISH_CONTEXT_STORE_ACCESS_GRANT/g" docker-compose.yml
sed -i "s/XTREE_PUBLISH_CONTEXT_STORE_BUCKET_PLACEHOLDER/$XTREE_PUBLISH_CONTEXT_STORE_BUCKET/g" docker-compose.yml
sed -i "s/XTREE_USER_SETTINGS_STORE_ACCESS_GRANT_PLACEHOLDER/$XTREE_USER_SETTINGS_STORE_ACCESS_GRANT/g" docker-compose.yml
sed -i "s/XTREE_USER_SETTINGS_STORE_BUCKET_PLACEHOLDER/$XTREE_USER_SETTINGS_STORE_BUCKET/g" docker-compose.yml
sed -i "s/XTREE_TABLE_DATA_ACCESS_GRANT_PLACEHOLDER/$XTREE_TABLE_DATA_ACCESS_GRANT/g" docker-compose.yml
sed -i "s/XTREE_OPENAI_API_KEY_PLACEHOLDER/$XTREE_OPENAI_API_KEY/g" docker-compose.yml
sed -i "s/XTREE_DOCUPIPE_API_KEY_PLACEHOLDER/$XTREE_DOCUPIPE_API_KEY/g" docker-compose.yml
sed -i "s/XTREE_COUNTER_API_KEY_PLACEHOLDER/$XTREE_COUNTER_API_KEY/g" docker-compose.yml
sed -i "s/CLERK_SECRET_KEY_PLACEHOLDER/$CLERK_SECRET_KEY/g" docker-compose.yml
sed -i "s/CLERK_PUBLISHABLE_KEY_FOREST_PLACEHOLDER/$CLERK_PUBLISHABLE_KEY_FOREST/g" docker-compose.yml
sed -i "s/ENTERA_CLIENT_ID_PLACEHOLDER/$ENTERA_CLIENT_ID/g" docker-compose.yml
sed -i "s/ENTERA_CLIENT_SECRET_PLACEHOLDER/$ENTERA_CLIENT_SECRET/g" docker-compose.yml
sed -i "s|SUPABASE_URL_PLACEHOLDER|$SUPABASE_URL|g" docker-compose.yml
sed -i "s|SUPABASE_SERVICE_KEY_PLACEHOLDER|$SUPABASE_SERVICE_KEY|g" docker-compose.yml
sed -i "s|SUPABASE_PUBLISHABLE_KEY_PLACEHOLDER|$SUPABASE_PUBLISHABLE_KEY|g" docker-compose.yml

# 🔹 6. SSL-Zertifikat beantragen
echo -e "${GREEN}🔒 Erstelle Let's Encrypt Zertifikat...${NC}"
chmod +x scripts/init-letsencrypt.sh
scripts/init-letsencrypt.sh

# 🔹 7. Docker-Compose starten
echo -e "${GREEN}🚀 Starte Docker-Container...${NC}"
docker compose up -d
sleep 10  # Warte auf vollständigen Start

# 🔹 8. Update-Skript vorbereiten
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

# 🔹 9. Falls automatische Updates aktiviert wurden, Cronjob einrichten
if [[ "$AUTO_UPDATE" == "y" ]]; then
    echo -e "${GREEN}📅 Richte tägliche automatische Updates ein...${NC}"

    # Cronjob sicher hinzufügen
    crontab -l > /tmp/mycron 2>/dev/null || true  # Falls keine Crontab existiert, wird eine neue erstellt
    echo "0 3 * * * flock -n /tmp/docker-update.lock /opt/docker-setup/update-containers.sh" >> /tmp/mycron
    crontab /tmp/mycron
    rm /tmp/mycron

    echo -e "${GREEN}✅ Automatische Updates sind jetzt aktiv.${NC}"
else
    echo -e "${GREEN}❌ Automatische Updates wurden deaktiviert. Du kannst manuell /opt/docker-setup/update-containers.sh ausführen.${NC}"
fi


echo -e "${GREEN}✅ Setup abgeschlossen! Der Complexitree-Server läuft nun unter: https://$DOMAIN ${NC}"
