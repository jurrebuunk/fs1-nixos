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
      ah-alg = "argon2";
    };

    # create users
    accounts = {
      jurre = {
        # This creates a file in the Nix store containing the hashed password.
        # Generate your hash by running `copyparty --ah-cli` on the server.
        # Replace the placeholder below with your actual hash.
        passwordFile = "${pkgs.writeText "jurre-password-hash" "$argon2id$v=19$m=65536,t=3,p=4$+4MDOXr7LhzGpoFgfJCL6p31QFSHWgl4f"}";
      };
    };

    # create a volume
    volumes = {
      "/" = {
        # share the contents of "/mnt/virtiofs/data"
        path = "/mnt/virtiofs/data";
        access = {
          # Only jurre has access, and they have admin rights
          a = [ "jurre" ];
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

  # Ensure the service waits for the mount and the directory exists
  systemd.services.copyparty-setup = {
    description = "Prepare copyparty data directory";
    after = [ "mnt-virtiofs.mount" ];
    requires = [ "mnt-virtiofs.mount" ];
    before = [ "copyparty.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/mkdir -p /mnt/virtiofs/data";
      ExecStartPost = [
        "${pkgs.coreutils}/bin/chown copyparty:copyparty /mnt/virtiofs/data"
        "${pkgs.coreutils}/bin/chmod 0750 /mnt/virtiofs/data"
      ];
    };
  };

  systemd.services.copyparty = {
    unitConfig.RequiresMountsFor = [ "/mnt/virtiofs/data" ];
    after = [ "mnt-virtiofs.mount" "copyparty-setup.service" ];
    requires = [ "mnt-virtiofs.mount" "copyparty-setup.service" ];
  };

  # Add copyparty to system packages
  environment.systemPackages = [ pkgs.copyparty ];
}
