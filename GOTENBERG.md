# Gotenberg Service Integration on Fly.io

This document explains how to deploy and integrate Gotenberg as a private service on Fly.io.

## Overview

Gotenberg is a document conversion service that provides PDF generation and document conversion capabilities. In this setup, Gotenberg runs as a separate Fly.io app that is only accessible via Fly.io's private networking.

## Architecture

```
┌─────────────────────────────────────────────────┐
│  Fly.io Private Network (IPv6)                  │
│                                                  │
│  ┌──────────────────┐      ┌─────────────────┐ │
│  │ complexitree-    │─────▶│ gotenberg-      │ │
│  │ server           │      │ complexitree    │ │
│  │ (public access)  │      │ (private only)  │ │
│  └──────────────────┘      └─────────────────┘ │
│                                                  │
└─────────────────────────────────────────────────┘
         ▲
         │
    Public Internet
```

## Security Features

1. **No Public Access**: Gotenberg has no public endpoints configured
2. **Private Networking**: Only accessible via Fly.io's `.internal` DNS
3. **Organization Isolation**: Only apps in your Fly.io organization can access it
4. **Automatic Encryption**: All traffic within Fly.io's private network is encrypted via WireGuard
5. **Network Segmentation**: Each organization has its own private IPv6 network

## Deployment Steps

### 1. Deploy Gotenberg Service

```bash
./deploy-gotenberg.sh
```

This script will:
- Create the `gotenberg-complexitree` app if it doesn't exist
- Deploy Gotenberg using the official Docker image
- Configure it with no public endpoints
- Set up autoscaling (0-2 machines)

### 2. Configure Main App

Set the Gotenberg URL in your main application:

```bash
flyctl secrets set GOTENBERG_URL=http://gotenberg-complexitree.internal:3000 --app complexitree-server
```

The `.internal` domain is Fly.io's private DNS that resolves to the private IPv6 address of the Gotenberg app.

### 3. Verify Connection

SSH into your main app and test the connection:

```bash
# SSH into main app
flyctl ssh console --app complexitree-server

# Test connection to Gotenberg
curl http://gotenberg-complexitree.internal:3000/health
```

### 4. Validate Setup

Run the validation script to check your configuration:

```bash
./validate-gotenberg.sh
```

This script will:
- Verify both apps exist
- Check that Gotenberg has no public IPs
- Confirm GOTENBERG_URL secret is set
- Provide instructions for testing connectivity

## Configuration Files

### fly-gotenberg.toml

The Gotenberg app configuration:
- **App name**: `gotenberg-complexitree`
- **Image**: `gotenberg/gotenberg:8.15.3`
- **Internal port**: 3000
- **No public ports**: Security by design
- **Resources**: 1 CPU, 512 MB memory
- **Autoscaling**: 0-2 machines

### Key Differences from Main App

Unlike the main `fly.toml`, the Gotenberg configuration has:
- **No `[[services.ports]]` section**: No public access
- **Smaller resources**: 512 MB vs 1024 MB memory
- **Lower concurrency limits**: 80/100 vs 200/250
- **Fewer machines**: 0-2 vs 0-5 autoscaling range

## How Fly.io Private Networking Works

### DNS Resolution

When your app queries `gotenberg-complexitree.internal`:
1. Fly.io's internal DNS server resolves it to the private IPv6 address
2. The address is within Fly.io's private network (fdaa::/16)
3. Only apps in the same organization can resolve and reach this address

### Network Transport

- All traffic uses Fly.io's WireGuard-based network
- Automatic encryption between apps
- Low latency within the same region
- Cross-region traffic goes through Fly.io's backbone

### Service Discovery

Fly.io automatically:
- Registers apps in the private DNS
- Updates DNS when machines start/stop
- Load balances across multiple machines
- Handles machine failures gracefully

## Managing Gotenberg

### View Status

```bash
flyctl status --app gotenberg-complexitree
```

### View Logs

```bash
# Real-time logs
flyctl logs --app gotenberg-complexitree

# Follow logs
flyctl logs -f --app gotenberg-complexitree
```

### Scale Machines

```bash
# Scale to specific count
flyctl scale count 1 --region fra --app gotenberg-complexitree

# Enable autoscaling
flyctl scale count 0-2 --region fra --app gotenberg-complexitree
```

### Update Gotenberg

To update to a new version, edit `fly-gotenberg.toml`:

```toml
[build]
  image = "gotenberg/gotenberg:8.16.0"  # Update version
```

Then redeploy:

```bash
flyctl deploy --config fly-gotenberg.toml
```

### SSH Access

```bash
flyctl ssh console --app gotenberg-complexitree
```

## Multi-Region Deployment

Deploy Gotenberg to multiple regions for better performance:

```bash
# Deploy to Frankfurt
flyctl scale count 1 --region fra --app gotenberg-complexitree

# Deploy to Sydney
flyctl scale count 1 --region syd --app gotenberg-complexitree
```

The `.internal` DNS automatically routes to the nearest available machine.

## Troubleshooting

### Connection Issues

If the main app cannot connect to Gotenberg:

1. **Check if Gotenberg is running**:
   ```bash
   flyctl status --app gotenberg-complexitree
   ```

2. **Verify private network**:
   ```bash
   # From main app
   flyctl ssh console --app complexitree-server
   # Then inside the container
   dig gotenberg-complexitree.internal
   ```

3. **Check logs for errors**:
   ```bash
   flyctl logs --app gotenberg-complexitree
   ```

### Performance Issues

If Gotenberg is slow:

1. **Scale up machines**:
   ```bash
   flyctl scale count 2 --region fra --app gotenberg-complexitree
   ```

2. **Increase resources**:
   ```bash
   flyctl scale vm shared-cpu-1x --memory 1024 --app gotenberg-complexitree
   ```

3. **Deploy to multiple regions** to reduce latency

### Security Audit

Verify that Gotenberg has no public access:

```bash
# Check app configuration
flyctl config show --app gotenberg-complexitree

# Verify no public IPs
flyctl ips list --app gotenberg-complexitree
```

The output should show no public IP addresses.

## Cost Optimization

Gotenberg is configured for cost efficiency:

- **Auto-stop**: Machines stop when idle
- **Auto-start**: Machines start on first request
- **Scale to zero**: No cost when not in use
- **Smaller resources**: 512 MB memory vs 1024 MB for main app

With autoscaling from 0 to 2 machines:
- **No traffic**: $0/month (machines sleep)
- **Light traffic**: ~$3-5/month (1 machine)
- **Moderate traffic**: ~$6-10/month (2 machines)

## Best Practices

1. **Pin Docker versions**: Use specific tags like `8.15.3` instead of `latest`
2. **Monitor logs**: Set up log forwarding for production
3. **Regular updates**: Keep Gotenberg updated for security patches
4. **Test privately**: Always test private network connectivity after deployment
5. **Multi-region**: Deploy to multiple regions for high availability
6. **Resource monitoring**: Watch CPU and memory usage, scale as needed

## Alternatives to Private Networking

If you need different security models:

### Option 1: API Key Authentication

Add API key requirement in your app code:
```bash
flyctl secrets set GOTENBERG_API_KEY=your-secret-key --app gotenberg-complexitree
flyctl secrets set GOTENBERG_API_KEY=your-secret-key --app complexitree-server
```

### Option 2: mTLS (Mutual TLS)

Use Fly.io's mTLS support for certificate-based authentication.

### Option 3: IP Allowlist

Use Fly.io's firewall rules (coming soon) to restrict access by IP.

## Additional Resources

- [Fly.io Private Networking Docs](https://fly.io/docs/networking/private-networking/)
- [Gotenberg Documentation](https://gotenberg.dev/)
- [Fly.io Security Best Practices](https://fly.io/docs/security/)

## Support

For issues or questions:
- Fly.io Community: https://community.fly.io/
- Gotenberg GitHub: https://github.com/gotenberg/gotenberg
- Complexitree Issues: https://github.com/Complexitree/server-init/issues
