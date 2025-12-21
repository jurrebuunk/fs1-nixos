{ config, pkgs, ... }:

{
  # Enable Nginx
  services.nginx = {
    enable = true;
    
    # Recommended settings for reverse proxy
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Virtual host for drive.buunk.org
    virtualHosts."drive.buunk.org" = {
      # Enable HTTPS with Let's Encrypt
      enableACME = true;
      forceSSL = true;
      
      # Reverse proxy to oCIS
      locations."/" = {
        proxyPass = "http://localhost:9200";
        proxyWebsockets = true; # Enable WebSocket support for oCIS
        
        extraConfig = ''
          # Headers for oCIS
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          
          # Increase timeouts for large file uploads
          proxy_connect_timeout 3600;
          proxy_send_timeout 3600;
          proxy_read_timeout 3600;
          send_timeout 3600;
          
          # Increase buffer sizes for large uploads
          client_max_body_size 10G;
          proxy_buffering off;
          proxy_request_buffering off;
        '';
      };
    };
  };

  # ACME (Let's Encrypt) configuration
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@buunk.org"; # Change this to your email
  };

  # Open firewall ports for HTTP and HTTPS
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
