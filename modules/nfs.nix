{ config, pkgs, ... }:

{
  services.nfs.server = {
    enable = true;
    # Fixed ports for predictability behind the firewall
    mountdPort = 20048;
    lockdPort = 4001;
    statdPort = 4002;
  };

  # Open ports in the firewall
  networking.firewall.allowedTCPPorts = [ 111 2049 20048 4001 4002 ];
  networking.firewall.allowedUDPPorts = [ 111 2049 20048 4001 4002 ];

  # Ensure the mount point exists
  systemd.tmpfiles.rules = [
    "d /data/nfs 0755 root root -"
  ];

  # Import the exports configuration
  imports = [
    ./nfs-exports.nix
  ];
}
