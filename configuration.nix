{ config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ./modules/storage/virtiofs.nix
    ./modules/services/ansible.nix
    ./modules/services/copyparty.nix
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages (required for oCIS)
  nixpkgs.config.allowUnfree = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Disable OOMD if it's failing (common on some kernels/VMs)
  systemd.oomd.enable = false;

  # Basic system configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # Change this to your actual boot device

  networking.hostName = "fs1";

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Define a user account.
  users.users.jurre = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  services.nfs.client.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    htop
  ];

  system.stateVersion = "23.11";
}
