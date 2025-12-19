{ config, pkgs, ... }:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = "fs1-nixos.lan.buunk.org"; # Change this to your actual domain or IP
    
    # Use the virtiofs mount for data
    datadir = "/data/nfs/nextcloud";

    config = {
      dbtype = "pgsql";
      adminpassFile = "/var/lib/nextcloud/adminpass";
      adminuser = "admin";
    };

    # Enable recommended settings
    configureRedis = true;
    database.createLocally = true;
    maxUploadSize = "10G";
    
    # Basic Nginx setup
    https = false; 
  };

  # Ensure the directory exists with correct permissions
  # We use a systemd service to ensure the directory is created on the virtiofs mount
  # and has the correct ownership for the nextcloud user.
  systemd.tmpfiles.rules = [
    "d /data/nfs/nextcloud 0750 nextcloud nextcloud - -"
  ];

  # Create a default admin password if it doesn't exist
  # This is just to get things started; the user should change it later.
  systemd.services.nextcloud-setup-pass = {
    description = "Nextcloud admin password setup";
    before = [ "nextcloud-setup.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if [ ! -f /var/lib/nextcloud/adminpass ]; then
        mkdir -p /var/lib/nextcloud
        echo "admin123" > /var/lib/nextcloud/adminpass
        chown nextcloud:nextcloud /var/lib/nextcloud/adminpass
        chmod 600 /var/lib/nextcloud/adminpass
      fi
    '';
  };

  # Open firewall for HTTP
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # PostgreSQL optimization for Nextcloud
  services.postgresql = {
    enable = true;
    settings = {
      log_connections = true;
      log_statement = "all";
    };
  };
}
