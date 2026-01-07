# Complexitree-Server-Init

The repository contains the init-script to setup a new Complexitree-Server. Follow the instructions to start.

## Deployment Options

This repository supports two deployment methods:

1. **Fly.io (Recommended)** - Cloud-native deployment with auto-scaling and multi-region support
2. **Traditional Server** - Manual setup on Linux servers (Hetzner, etc.)

---

## Deploy on Fly.io

Fly.io provides a modern cloud platform with built-in auto-scaling, multi-region deployment, and zero-downtime deployments.

### Prerequisites

1. Install the Fly.io CLI (`flyctl`):
   ```bash
   curl -L https://fly.io/install.sh | sh
   ```

2. Sign up and log in:
   ```bash
   flyctl auth signup
   # or if you already have an account
   flyctl auth login
   ```

### Quick Start

1. **Clone this repository**:
   ```bash
   git clone https://github.com/Complexitree/server-init.git
   cd server-init
   ```

2. **Configure your app name** in `fly.toml`:
   - Edit the `app = "complexitree-server"` line to use your desired app name

3. **Set up secrets**:
   Create a file called `secrets.txt` with your configuration:
   ```
   XTREE_KEY_STORE_ACCESS_GRANT=your_value_here
   XTREE_KEY_STORE_BUCKET=keys
   XTREE_PUBLISH_CONTEXT_STORE_ACCESS_GRANT=your_value_here
   XTREE_PUBLISH_CONTEXT_STORE_BUCKET=publishcontext
   XTREE_USER_SETTINGS_STORE_ACCESS_GRANT=your_value_here
   XTREE_USER_SETTINGS_STORE_BUCKET=usersettings
   XTREE_TABLE_DATA_ACCESS_GRANT=your_value_here
   XTREE_OPENAI_API_KEY=your_value_here
   XTREE_DOCUPIPE_API_KEY=your_value_here
   XTREE_COUNTER_API_KEY=your_value_here
   CLERK_SECRET_KEY=your_value_here
   CLERK_PUBLISHABLE_KEY_FOREST=your_value_here
   XTREE_TEMP_ACCESSGRANT=your_value_here
   XTREE_TEMP_KEYHASH=your_value_here
   ENTERA_CLIENT_ID=your_value_here
   ENTERA_CLIENT_SECRET=your_value_here
   SUPABASE_URL=your_value_here
   SUPABASE_SERVICE_KEY=your_value_here
   SUPABASE_PUBLISHABLE_KEY=your_value_here
   ```

   Then import the secrets:
   ```bash
   flyctl secrets import < secrets.txt
   ```

4. **Deploy Gotenberg service** (optional but recommended):
   
   Gotenberg is a document conversion service that runs as a separate private app:
   ```bash
   ./deploy-gotenberg.sh
   ```
   
   After deploying Gotenberg, set the URL in your main app:
   ```bash
   flyctl secrets set GOTENBERG_URL=http://gotenberg-complexitree.internal:3000 --app complexitree-server
   ```
   
   **Security Note**: Gotenberg runs with no public endpoints and is only accessible via Fly.io's private networking by apps in your organization.

5. **Deploy the main server**:
   ```bash
   ./deploy-fly.sh
   ```

   Or deploy manually:
   ```bash
   flyctl deploy
   ```

### Multi-Region Configuration

The `fly.toml` configuration is set up for multi-region deployment:

- **Primary region**: Frankfurt, Germany (`fra`)
- **Secondary region**: Sydney, Australia (`syd`)

To scale in specific regions:
```bash
# Scale in Frankfurt
flyctl scale count 0-5 --region fra

# Scale in Sydney
flyctl scale count 0-5 --region syd
```

### Auto-Scaling

The configuration includes auto-scaling from 0 to 5 machines:

- **Minimum machines**: 0 (scales to zero when idle)
- **Maximum machines**: 5 per region
- **Auto-start**: Machines start automatically when requests arrive
- **Auto-stop**: Machines stop when idle to save costs

To view current scaling:
```bash
flyctl status
flyctl machines list
```

### Useful Commands

```bash
# View application status
flyctl status

# View logs
flyctl logs

# SSH into a machine
flyctl ssh console

# View metrics and dashboard
flyctl dashboard

# List all machines
flyctl machines list

# Update secrets
flyctl secrets set KEY=VALUE

# View current secrets (names only, not values)
flyctl secrets list
```

### Health Checks

The application includes health checks on the `/version` endpoint:
- Check interval: 15 seconds
- Timeout: 10 seconds
- Grace period: 30 seconds

### Resources

Each machine is configured with:
- **CPU**: 1 shared CPU
- **Memory**: 1024 MB
- **Concurrency**: 200 soft limit, 250 hard limit

To adjust resources:
```bash
flyctl scale vm shared-cpu-2x --memory 2048
```

### Gotenberg Service (Private Network)

Gotenberg is a document conversion service that runs as a separate private app. It provides PDF generation and document conversion capabilities.

#### Deploying Gotenberg

```bash
./deploy-gotenberg.sh
```

#### Connecting to Gotenberg

After deployment, Gotenberg is accessible via Fly.io's private network:

```bash
# Set the Gotenberg URL in your main app
flyctl secrets set GOTENBERG_URL=http://gotenberg-complexitree.internal:3000 --app complexitree-server
```

#### Security

- **No public access**: Gotenberg has no public endpoints
- **Private networking only**: Only accessible by apps in your Fly.io organization
- **Internal DNS**: Uses `.internal` domain for private communication
- **Automatic encryption**: All traffic within Fly.io's private network is encrypted

#### Managing Gotenberg

```bash
# View Gotenberg status
flyctl status --app gotenberg-complexitree

# View Gotenberg logs
flyctl logs --app gotenberg-complexitree

# Scale Gotenberg
flyctl scale count 0-2 --region fra --app gotenberg-complexitree
```

Gotenberg is configured with smaller resources (512 MB memory) since it typically handles fewer requests than the main server.


### Custom Domain

To add a custom domain:
```bash
flyctl certs add yourdomain.com
flyctl certs show yourdomain.com
```

Then add the DNS records shown in the output.

---

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
