{ config, pkgs, ... }:

{
  imports =
    [ 
      ./modules/nfs.nix
      ./modules/ansible.nix
    ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Basic system configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # Change this to your actual boot device

  networking.hostName = "nixos-server";

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Define a user account.
  users.users.jurre = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
  ];

  system.stateVersion = "23.11"; # Did you read the comment?
}
