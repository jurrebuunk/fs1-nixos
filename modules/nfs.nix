{ config, pkgs, ... }:

{
  services.nfs.server.enable = true;

  # Import the exports configuration
  imports = [
    ./nfs-exports.nix
  ];
}
