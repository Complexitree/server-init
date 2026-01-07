# Fly.io Quick Reference for Complexitree Server

This document provides quick reference commands for managing your Complexitree server on Fly.io.

## Initial Setup

### 1. Install Fly.io CLI
```bash
curl -L https://fly.io/install.sh | sh
```

### 2. Login
```bash
flyctl auth login
```

### 3. Set Secrets
```bash
# Option 1: Import from file
flyctl secrets import < secrets.txt

# Option 2: Set individually
flyctl secrets set XTREE_KEY_STORE_ACCESS_GRANT=your_value
```

### 4. Deploy
```bash
# Using the helper script
./deploy-fly.sh

# Or manually
flyctl deploy
```

## Managing Regions

### Deploy to Multiple Regions
```bash
# Frankfurt (Germany) - Primary
flyctl scale count 1 --region fra

# Sydney (Australia) - Secondary
flyctl scale count 1 --region syd
```

### Check Region Status
```bash
flyctl regions list
flyctl machines list
```

## Scaling

### Auto-scaling (0 to 5 machines)
The app is configured to automatically scale based on traffic:
- Scales to 0 when idle (no cost when not in use)
- Auto-starts when requests arrive
- Scales up to 5 machines per region under load

### Manual Scaling
```bash
# Set count in specific region
flyctl scale count 3 --region fra

# Set count range (enables autoscaling)
flyctl scale count 0-5 --region fra
flyctl scale count 0-5 --region syd
```

### View Current Scale
```bash
flyctl status
flyctl machines list
```

## Monitoring

### View Logs
```bash
# Real-time logs
flyctl logs

# Follow logs
flyctl logs -f

# Logs from specific machine
flyctl logs -i <machine-id>
```

### Application Status
```bash
# Overall status
flyctl status

# Machine details
flyctl machines list

# Resource usage
flyctl dashboard
```

### Health Checks
The app is configured with health checks on `/version`:
```bash
# View health check status
flyctl status
```

## Secrets Management

### List Secrets (names only)
```bash
flyctl secrets list
```

### Set/Update Secret
```bash
flyctl secrets set KEY=VALUE
```

### Unset Secret
```bash
flyctl secrets unset KEY
```

### Import Multiple Secrets
```bash
flyctl secrets import < secrets.txt
```

## Resource Management

### View Current Resources
```bash
flyctl status
```

### Scale VM Resources
```bash
# Change to 2 CPUs and 2GB RAM
flyctl scale vm shared-cpu-2x --memory 2048

# Change to 1 CPU and 1GB RAM (default)
flyctl scale vm shared-cpu-1x --memory 1024
```

## Deployment

### Deploy New Version
```bash
flyctl deploy
```

### Deploy with Specific Image
```bash
# Best practice: Pin to a specific version for production
flyctl deploy --image complexitree/server:v1.2.3

# Or update fly.toml to pin the version permanently:
# [build]
#   image = "complexitree/server:v1.2.3"
```

### Deploy to Specific Region
```bash
flyctl deploy --region fra
```

## Troubleshooting

### SSH into Machine
```bash
# List machines first
flyctl machines list

# SSH into specific machine
flyctl ssh console -s <machine-id>
```

### Restart Machine
```bash
flyctl machines restart <machine-id>
```

### View Machine Details
```bash
flyctl machines show <machine-id>
```

### Force Deploy (if stuck)
```bash
flyctl deploy --force
```

## Custom Domains

### Add Domain
```bash
flyctl certs add yourdomain.com
```

### View Certificate Status
```bash
flyctl certs show yourdomain.com
```

### List All Certificates
```bash
flyctl certs list
```

## Cleanup

### Stop All Machines (but keep app)
```bash
flyctl scale count 0 --region fra
flyctl scale count 0 --region syd
```

### Destroy App (permanent)
```bash
flyctl apps destroy complexitree-server
```

## Pricing Considerations

With autoscaling from 0 to 5:
- **Zero traffic**: $0/month (machines sleep)
- **Light traffic**: ~$5-10/month (1 machine running)
- **High traffic**: Scales automatically, pay for running machines only

View current usage:
```bash
flyctl dashboard
```

## Support

- Fly.io Documentation: https://fly.io/docs/
- Fly.io Community: https://community.fly.io/
- Status Page: https://status.flyio.net/
