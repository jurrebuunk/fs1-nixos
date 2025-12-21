# HTTPS Reverse Proxy Setup for oCIS

## What Was Configured

I've set up an Nginx reverse proxy with HTTPS support for your oCIS server using the domain `drive.buunk.org`.

### Changes Made:

1. **Created `/home/jurre/repos/fs1-nixos/modules/services/nginx-reverse-proxy.nix`**
   - Nginx reverse proxy configuration
   - Automatic HTTPS with Let's Encrypt (ACME)
   - WebSocket support for oCIS
   - Optimized for large file uploads (up to 10GB)
   - Opens ports 80 (HTTP) and 443 (HTTPS)

2. **Updated `/home/jurre/repos/fs1-nixos/modules/services/ocis.nix`**
   - Changed `OCIS_URL` from `https://fs1.lan.buunk.org:9200` to `https://drive.buunk.org`
   - Changed `OCIS_OIDC_ISSUER` to `https://drive.buunk.org`
   - Set `OCIS_INSECURE` and `IDP_INSECURE` to `false` (proper HTTPS)
   - Set `PROXY_TLS` to `false` (Nginx handles TLS termination)

3. **Updated `/home/jurre/repos/fs1-nixos/configuration.nix`**
   - Added nginx-reverse-proxy module to imports

4. **Updated `/home/jurre/repos/fs1-nixos/docker-compose.yml`**
   - Synchronized environment variables to match NixOS configuration

## Prerequisites

Before rebuilding, ensure:

1. **DNS is configured**: `drive.buunk.org` must point to your server's public IP address
2. **Ports are open**: Your router/firewall must forward ports 80 and 443 to this server
3. **Email address**: Update the email in `nginx-reverse-proxy.nix` (currently set to `admin@buunk.org`)

## How to Apply

```bash
cd /home/jurre/repos/fs1-nixos
sudo nixos-rebuild switch --flake .#nixos-server
```

## What Happens During First Boot

1. Nginx will start and request an SSL certificate from Let's Encrypt
2. Let's Encrypt will verify domain ownership via HTTP-01 challenge (requires port 80)
3. Once verified, the certificate is issued and HTTPS is enabled
4. oCIS will be accessible at `https://drive.buunk.org`

## Architecture

```
Internet (HTTPS) → Nginx (Port 443) → oCIS Container (Port 9200)
                   ↓
              Let's Encrypt
              (Auto-renewal)
```

## Troubleshooting

### If ACME certificate fails:
- Check DNS: `nslookup drive.buunk.org`
- Check port 80 is accessible from internet
- Check logs: `sudo journalctl -u nginx -f`
- Check ACME logs: `sudo journalctl -u acme-drive.buunk.org -f`

### If oCIS doesn't work after rebuild:
- Restart oCIS: `sudo systemctl restart docker-ocis`
- Check oCIS logs: `sudo journalctl -u docker-ocis -f`
- You may need to clear oCIS config if the URL changed: `sudo rm -rf /data/nfs/ocis/config/ocis.yaml`

## Security Notes

- Port 9200 is still open on the firewall (from ocis.nix). You may want to remove it from `networking.firewall.allowedTCPPorts` in `ocis.nix` to only allow access through Nginx
- SSL certificates auto-renew via systemd timer
- Update the email address in `nginx-reverse-proxy.nix` to receive certificate expiry notifications
