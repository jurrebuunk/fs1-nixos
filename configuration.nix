{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./modules/nfs.nix
      ./modules/ansible.nix
      ./modules/ocis.nix
    ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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

  fileSystems."/data/nfs" = {
    device = "virtiofs1"; # must match Proxmox tag
    fsType = "virtiofs";
    options = [ "defaults" "nofail" ];
  };

  # Enable QEMU guest agent (required for Virtio-FS)
  services.qemuGuest.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    nfs-utils # Useful for debugging
  ];

  system.stateVersion = "23.11"; # Did you read the comment?
}
