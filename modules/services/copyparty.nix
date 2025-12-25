{ config, pkgs, ... }:

{
  services.copyparty = {
    enable = true;
    # the user to run the service as
    user = "copyparty"; 
    # the group to run the service as
    group = "copyparty"; 
    
    settings = {
      i = "0.0.0.0";
      p = 3210;
      no-reload = true;
    };

    # create a volume
    volumes = {
      "/" = {
        # share the contents of "/mnt/virtiofs/data"
        path = "/mnt/virtiofs/data";
        access = {
          # everyone gets read-access
          r = "*";
        };
        flags = {
          # "fk" enables filekeys (necessary for upget permission) (4 chars long)
          fk = 4;
          # scan for new files every 60sec
          scan = 60;
          # volflag "e2d" enables the uploads database
          e2d = true;
        };
      };
    };
    # you may increase the open file limit for the process
    openFilesLimit = 8192;
  };

  # Ensure the directory exists and has correct permissions
  systemd.tmpfiles.rules = [
    "d /mnt/virtiofs/data 0750 copyparty copyparty -"
  ];

  # Open port in firewall
  networking.firewall.allowedTCPPorts = [ 3210 ];

  # Add copyparty to system packages
  environment.systemPackages = [ pkgs.copyparty ];
}
