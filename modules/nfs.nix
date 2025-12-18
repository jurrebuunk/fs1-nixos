{ config, pkgs, ... }:

{
  services.nfs.server = {
    enable = true;
    # Fixed ports for predictability behind the firewall
    mountdPort = 20048;
    lockdPort = 4001;
    statdPort = 4002;
  };

  # Import the exports configuration
  imports = [
    ./nfs-exports.nix
  ];
}
