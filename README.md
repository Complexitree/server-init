# Complexitree-Server-Init

The repository contains the init-script to setup a new Complexitree-Server. Follow the instructions to start.

## Install on a clean linux server

```bash
wget -O init.sh https://raw.githubusercontent.com/Complexitree/server-init/refs/heads/main/init.sh
chmod +x init.sh
sudo ./init.sh
```

For servers behind a Hetzner load balancer that terminates TLS and forwards only HTTP traffic, use the `init-lb.sh` script:

```bash
wget -O init-lb.sh https://raw.githubusercontent.com/Complexitree/server-init/refs/heads/main/init-lb.sh
chmod +x init-lb.sh
sudo ./init-lb.sh
```

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
