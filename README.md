# FS1 NixOS Server

This repository contains the declarative NixOS configuration for the `fs1` server running on Proxmox.

## 🏗️ Architecture

- **OS**: NixOS 24.11
- **Deployment**: Flake-based configuration
- **Storage**: Virtio-FS mount from Proxmox host
- **Services**: Docker-based ownCloud Infinite Scale (oCIS)

## 📁 Repository Structure

```
.
├── configuration.nix           # Main system configuration
├── hardware-configuration.nix  # Hardware-specific settings
├── flake.nix                  # Flake definition
├── modules/
│   ├── services/
│   │   ├── ocis.nix          # ownCloud Infinite Scale
│   │   └── ansible.nix       # Ansible configuration
│   └── storage/
│       ├── virtiofs.nix      # Virtio-FS mount
│       └── nfs.nix           # NFS server
├── SYSTEM_INFO.md            # Login credentials & system info (gitignored)
└── docker-compose.yml        # Reference Docker Compose file
```

## 🚀 Services

### ownCloud Infinite Scale (oCIS)
- **Access**: https://fs1.lan.buunk.org:9200
- **Storage**: `/data/nfs/ocis` (on Virtio-FS)
- **Deployment**: Docker container managed via NixOS
- **Credentials**: See `SYSTEM_INFO.md` (local only)

### NFS Server
- **Export**: `/data/nfs` to local network
- **Ports**: 2049 (NFS), 20048 (mountd), 4001 (lockd), 4002 (statd)

## 🔧 Management

### Rebuild System
```bash
sudo nixos-rebuild switch --flake .#nixos-server
```

### Update Configuration
1. Edit files in this repository
2. Commit and push changes
3. On the server:
   ```bash
   cd ~/fs1-nixos
   git pull
   sudo nixos-rebuild switch --flake .#nixos-server
   ```

### Service Management
```bash
# Check oCIS status
sudo systemctl status docker-ocis.service

# View logs
sudo journalctl -u docker-ocis.service -f

# Restart service
sudo systemctl restart docker-ocis.service

# Check Docker container
sudo docker ps
sudo docker logs ocis
```

## 📦 Storage

- **Virtio-FS**: Mounted at `/data/nfs` from Proxmox host
- **NFS Export**: `/data/nfs` shared to `*` (all hosts)
- **oCIS Data**: `/data/nfs/ocis`
- **oCIS Config**: `/data/nfs/ocis/config`

## 🔐 Security Notes

- oCIS uses self-signed HTTPS certificates
- Browser will show security warning on first access
- Credentials stored in `SYSTEM_INFO.md` (not committed to git)
- NFS export is currently open to all hosts (`*`)

## 📝 Notes

- System state version: 23.11
- Hostname: `fs1`
- Timezone: Europe/Amsterdam
- Locale: en_US.UTF-8 with nl_NL regional settings
