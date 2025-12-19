{ config, pkgs, ... }:

{
  # Enable Docker
  virtualisation.docker.enable = true;

  # Run oCIS as a Docker container
  virtualisation.oci-containers = {
    backend = "docker";
    containers.ocis = {
      image = "owncloud/ocis:latest";
      ports = [ "9200:9200" ];
      volumes = [
        "/data/nfs/ocis:/var/lib/ocis"
      ];
      environment = {
        OCIS_URL = "http://fs1.lan.buunk.org:9200";
        OCIS_INSECURE = "true";
        PROXY_TLS = "false";
        PROXY_HTTP_ADDR = "0.0.0.0:9200";
        IDP_INSECURE = "true";
        # This helps with the "invalid iss" error by explicitly setting the issuer
        OCIS_OIDC_ISSUER = "http://fs1.lan.buunk.org:9200";
      };
      extraOptions = [
        "--name=ocis"
      ];
    };
  };

  # Ensure the data directory exists
  systemd.tmpfiles.rules = [
    "d /data/nfs/ocis 0777 root root - -"
  ];

  # Open firewall for oCIS
  networking.firewall.allowedTCPPorts = [ 9200 ];

  # Ensure Docker waits for the NFS mount
  systemd.services.docker-ocis = {
    requires = [ "data-nfs.mount" ];
    after = [ "data-nfs.mount" ];
  };
}
