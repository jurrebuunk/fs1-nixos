{ config, pkgs, ... }:

{
  # Enable SSH for Ansible
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes"; 
    };
  };

  # Ensure Python is available for Ansible modules
  environment.systemPackages = with pkgs; [
    python3
  ];

  # Optional: Add your SSH public key for Ansible access
  # users.users.jurre.openssh.authorizedKeys.keys = [
  #   "ssh-ed25519 AAAAC3Nza..." 
  # ];
}
