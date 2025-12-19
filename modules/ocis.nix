{ config, pkgs, ... }:

{
  services.ocis = {
    enable = true;
    # Point the state directory to your virtiofs mount
    stateDir = "/data/nfs/ocis";
    
    # Basic network settings
    address = "0.0.0.0";
    port = 9200;
    url = "http://fs1.lan.buunk.org:9200"; # Change to https if you set up a proxy later

    # Initial environment setup
    # Note: On first run, oCIS usually needs to be initialized.
    # The NixOS module handles basic service setup, but you might need to set OCIS_INSECURE=true 
    # if you aren't using SSL yet.
    environment = {
      OCIS_INSECURE = "true";
      IDP_INSECURE = "true";
      PROXY_TLS = "false";
      PROXY_HTTP_ADDR = "0.0.0.0:9200";
    };
  };

  # Ensure the directory exists with correct permissions
  systemd.tmpfiles.rules = [
    "d /data/nfs/ocis 0750 ocis ocis - -"
  ];

  # Automatic initialization service
  systemd.services.ocis-init = {
    description = "Initialize oCIS configuration";
    before = [ "ocis.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "ocis";
      Group = "ocis";
      RemainAfterExit = true;
      StateDirectory = "ocis";
    };
    script = ''
      if [ ! -f /data/nfs/ocis/config/ocis.yaml ]; then
        mkdir -p /data/nfs/ocis/config
        # Run init non-interactively
        # We set OCIS_CONFIG_DIR to ensure it writes to our NFS mount
        export OCIS_CONFIG_DIR=/data/nfs/ocis/config
        ${pkgs.ocis-bin}/bin/ocis init --insecure true
      fi
    '';
  };

  # Ensure oCIS waits for the mount and the init service
  systemd.services.ocis = {
    requires = [ "data-nfs.mount" "ocis-init.service" ];
    after = [ "data-nfs.mount" "ocis-init.service" ];
  };

  # Open firewall for oCIS
  networking.firewall.allowedTCPPorts = [ 9200 ];
}
