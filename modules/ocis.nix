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

  # Ensure oCIS waits for the mount
  systemd.services.ocis = {
    requires = [ "data-nfs.mount" ];
    after = [ "data-nfs.mount" ];
  };

  # Open firewall for oCIS
  networking.firewall.allowedTCPPorts = [ 9200 ];
}
