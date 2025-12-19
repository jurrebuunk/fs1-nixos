# FS1 NixOS Server - System Information

This repository manages the configuration for the `fs1` server.

## Services

### ownCloud Infinite Scale (oCIS)
- **URL**: [https://fs1.lan.buunk.org:9200](https://fs1.lan.buunk.org:9200)
- **Deployment**: Docker-based (managed via NixOS `virtualisation.oci-containers`)
- **Storage**: Virtio-FS mount at `/data/nfs`

#### Login Credentials
- **Admin Username**: `admin`
- **Admin Password**: `Kn3La9DLGsvJoS*%IwVJc12-Q7URk1h7`
- **Demo Users**:
  - `einstein` / `relativity`
  - `marie` / `curie`

#### Directory Structure
- `/data/nfs/ocis`: Main data storage (on Virtio-FS)
- `/data/nfs/ocis/config`: Configuration files (including `ocis.yaml`)
- `/etc/nixos`: NixOS configuration files (symlinked from this repo)

#### Management Commands
- **Check Status**: `sudo systemctl status docker-ocis.service`
- **View Logs**: `sudo journalctl -u docker-ocis.service -f`
- **Restart**: `sudo systemctl restart docker-ocis.service`
- **Rebuild System**: `sudo nixos-rebuild switch --flake .#nixos-server`

## Storage
- **Virtio-FS**: Mounted at `/data/nfs` from Proxmox host.
- **NFS Server**: Exports `/data/nfs` to the local network.

## Maintenance
To update the system:
1. Edit files in this repository.
2. Commit and push changes.
3. On the server: `git pull && sudo nixos-rebuild switch --flake .#nixos-server`
