{ config, pkgs, ... }:

{
  services.nfs.server = {
    enable = true;
    # Fixed ports for NFS to make firewall configuration easier
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4003;
  };

  # Import the exports configuration
  imports = [
    ./nfs-exports.nix
  ];
}
