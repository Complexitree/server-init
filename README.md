# Complexitree-Server-Init

The repository contains the init-script to setup a new Complexitree-Server. Follow the instructions to start.

## Install on a clean linux server

```bash
wget -O init.sh https://raw.githubusercontent.com/Complexitree/server-init/refs/heads/main/init.sh
chmod +x init.sh
sudo ./init.sh
```

For servers behind a load balancer that terminates TLS and forwards only HTTP traffic, use the `init-lb.sh` script:

```bash
wget -O init-lb.sh https://raw.githubusercontent.com/Complexitree/server-init/refs/heads/main/init-lb.sh
chmod +x init-lb.sh
sudo ./init-lb.sh
```

## Configuration via Init-URL

Both init scripts support automated configuration via an init-url. Instead of entering parameters manually, you can provide a URL to a configuration file containing all required parameters.

### Using Init-URL

When running the init script, you will be asked:

```
📋 Möchten Sie eine Init-URL mit allen Konfigurationsparametern angeben? (y/n):
```

If you answer `y`, you can provide a URL to your configuration file. The script will download and parse it automatically.

### Configuration File Format

The configuration file must follow this format:
- One parameter per line
- Format: `KEY:VALUE`
- Lines starting with `#` are comments and will be ignored
- Empty lines will be ignored

See `config-sample.txt` in this repository for a complete template with all available parameters.

### Example Configuration File

```
# Complexitree Server Configuration
# Note: DOMAIN and EMAIL are NOT included here - they will be requested interactively
XTREE_KEY_STORE_ACCESS_GRANT:your_access_grant_here
XTREE_KEY_STORE_BUCKET:keys
AUTO_UPDATE:y
```

### Required Parameters

- **For init.sh**: All XTREE_* parameters in config file. DOMAIN and EMAIL will be requested interactively.
- **For init-lb.sh**: All XTREE_* parameters in config file. DOMAIN will be requested interactively.

If the init-url is not provided or fails to load, the script will fall back to interactive parameter entry.

## Updating the server

If selected in the setup the server updates the docker containers automatically. You may see update-information with this command:

```bash
journalctl -t docker-update
```

You may update the server manually by this command:

```bash
bash /opt/docker-setup/update-containers.sh
```

## Version-Info

You may get info about the current server version by opening the following URL in the browser:

``
htps://[server]/version
``
