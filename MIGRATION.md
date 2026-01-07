# Migration Guide: Hetzner to Fly.io

This guide helps you migrate your Complexitree server from Hetzner (or any traditional server) to Fly.io.

## Why Migrate to Fly.io?

### Benefits
- **Auto-scaling**: Scales from 0 to 5 machines automatically
- **Multi-region**: Deploy to Germany and Australia with one command
- **Cost-effective**: Pay only for running machines, scales to zero when idle
- **Zero-downtime deploys**: Rolling updates with automatic health checks
- **Built-in load balancing**: Automatic load distribution across machines
- **No manual server management**: No SSH, no server updates, no security patches
- **Built-in TLS**: Automatic HTTPS certificates

### Considerations
- **Docker-based**: Uses the complexitree/server Docker image
- **Environment changes**: Secrets managed through Fly.io CLI
- **No nginx management**: Fly.io handles reverse proxy and TLS
- **Different monitoring**: Use Fly.io dashboard instead of server logs

## Pre-Migration Checklist

- [ ] Fly.io account created and CLI installed
- [ ] All environment variables documented (see current server)
- [ ] Custom domain DNS can be updated (if using custom domain)
- [ ] Backup of current configuration
- [ ] Team notified of migration window

## Migration Steps

### 1. Document Current Configuration

On your Hetzner server, export current environment variables:

```bash
docker exec complexitree-server env | grep XTREE > current-config.txt
docker exec complexitree-server env | grep CLERK >> current-config.txt
docker exec complexitree-server env | grep ENTERA >> current-config.txt
docker exec complexitree-server env | grep SUPABASE >> current-config.txt
```

### 2. Prepare Fly.io Secrets

Create a `secrets.txt` file using `secrets.txt.template`:

```bash
# Copy template
cp secrets.txt.template secrets.txt

# Edit with your values from current-config.txt
nano secrets.txt
```

### 3. Initial Fly.io Deployment

```bash
# Clone this repository
git clone https://github.com/Complexitree/server-init.git
cd server-init

# Configure app name in fly.toml
nano fly.toml  # Change app name if needed

# Login to Fly.io
flyctl auth login

# Import secrets
flyctl secrets import < secrets.txt

# Deploy
./deploy-fly.sh
```

### 4. Test Fly.io Deployment

Before switching DNS, test the Fly.io deployment:

```bash
# Get your Fly.io URL
flyctl status

# Test the endpoint (replace with your app name)
curl https://your-app.fly.dev/version
```

### 5. Update DNS (if using custom domain)

#### Option A: Zero-Downtime Migration (Recommended)

1. Add custom domain to Fly.io:
```bash
flyctl certs add yourdomain.com
```

2. Update DNS to point to Fly.io (get addresses from previous command):
```
# Add these DNS records:
A     yourdomain.com     -> <fly.io IP address>
AAAA  yourdomain.com     -> <fly.io IPv6 address>
```

3. Wait for DNS propagation (15 minutes - 24 hours)

4. Verify both old and new are working:
```bash
curl https://yourdomain.com/version
```

5. Once verified, stop old Hetzner server

#### Option B: Quick Cutover (Brief Downtime)

1. Put up maintenance page on Hetzner
2. Update DNS to point to Fly.io
3. Wait for DNS propagation
4. Verify new deployment is working
5. Shut down Hetzner server

### 6. Configure Multi-Region

Deploy to both regions:

```bash
# Frankfurt (primary)
flyctl scale count 1 --region fra

# Sydney (secondary)
flyctl scale count 1 --region syd
```

### 7. Enable Auto-scaling

```bash
# Set autoscaling range for each region
flyctl scale count 0-5 --region fra
flyctl scale count 0-5 --region syd
```

### 8. Monitor Initial Operation

```bash
# Watch logs
flyctl logs -f

# Check status
flyctl status

# View machines
flyctl machines list
```

### 9. Cleanup Old Infrastructure

After confirming everything works (recommended: wait 7 days):

1. Stop Docker containers on Hetzner:
```bash
cd /opt/docker-setup
docker-compose down
```

2. Cancel Hetzner server (if no longer needed)

3. Update any monitoring/alerting to point to Fly.io

## Post-Migration Tasks

### Update Documentation
- [ ] Update team documentation with new deployment process
- [ ] Update monitoring dashboards
- [ ] Update incident response procedures

### Set Up Monitoring
```bash
# Add Fly.io dashboard to bookmarks
flyctl dashboard
```

### Configure Alerts
Consider setting up Fly.io monitoring and alerts:
- Machine health alerts
- Resource usage alerts
- Deployment failure alerts

## Rollback Plan

If you need to rollback to Hetzner:

1. Point DNS back to Hetzner server
2. Restart Docker containers:
```bash
cd /opt/docker-setup
docker-compose up -d
```
3. Wait for DNS propagation
4. Verify service is working

## Common Issues and Solutions

### Issue: Secrets not working
**Solution**: Verify secrets are set correctly:
```bash
flyctl secrets list
```

### Issue: Health checks failing
**Solution**: Ensure `/version` endpoint is accessible:
```bash
flyctl logs
curl https://your-app.fly.dev/version
```

### Issue: Slow performance
**Solution**: Scale up resources or add more machines:
```bash
flyctl scale vm shared-cpu-2x --memory 2048
flyctl scale count 2 --region fra
```

### Issue: Can't connect to database
**Solution**: Check network connectivity and firewall rules

## Cost Comparison

### Hetzner (Current)
- 2-3 servers with load balancer
- Fixed monthly cost regardless of usage
- Manual scaling

### Fly.io (New)
- Auto-scaling (0-5 machines per region)
- Pay only for running machines
- Scales to zero when idle
- Typical costs:
  - Light usage: ~$5-10/month
  - Medium usage: ~$20-40/month
  - High usage: Scales automatically

## Support

- Fly.io Community: https://community.fly.io/
- Fly.io Documentation: https://fly.io/docs/
- GitHub Issues: https://github.com/Complexitree/server-init/issues

## Next Steps

After successful migration:

1. Set up regular monitoring
2. Configure automated backups (if needed)
3. Test auto-scaling behavior
4. Optimize resource allocation
5. Consider adding more regions if needed

## Questions?

Open an issue in this repository or consult Fly.io documentation.
