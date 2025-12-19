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
        "/data/nfs/ocis:/var/lib/ocis",
        "/data/nfs/ocis/config:/etc/ocis"
      ];
      environment = {
        OCIS_URL = "http://fs1.lan.buunk.org:9200";
        OCIS_INSECURE = "true";
        PROXY_TLS = "false";
        PROXY_HTTP_ADDR = "0.0.0.0:9200";
        IDP_INSECURE = "true";
        OCIS_OIDC_ISSUER = "http://fs1.lan.buunk.org:9200";
        OCIS_CONFIG_DIR = "/etc/ocis";
      };
      extraOptions = [
        "--name=ocis"
      ];
    };
  };

  # One-time initialization service using Docker
  systemd.services.docker-ocis-init = {
    description = "Initialize oCIS configuration via Docker";
    before = [ "docker-ocis.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if [ ! -f /data/nfs/ocis/config/ocis.yaml ]; then
        echo "Initializing oCIS configuration..."
        mkdir -p /data/nfs/ocis/config
        ${pkgs.docker}/bin/docker run --rm \
          -v /data/nfs/ocis/config:/etc/ocis \
          owncloud/ocis:latest \
          init --insecure true
        
        # Ensure permissions are open enough for the container
        chmod -R 777 /data/nfs/ocis
      fi
    '';
  };

  # Ensure the data directory exists
  systemd.tmpfiles.rules = [
    "d /data/nfs/ocis 0777 root root - -"
  ];

  # Open firewall for oCIS
  networking.firewall.allowedTCPPorts = [ 9200 ];

  # Ensure Docker waits for the NFS mount and init
  systemd.services.docker-ocis = {
    requires = [ "data-nfs.mount" "docker-ocis-init.service" ];
    after = [ "data-nfs.mount" "docker-ocis-init.service" ];
  };
}
