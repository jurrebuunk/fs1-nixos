{ config, pkgs, ... }:

{
  services.nfs.server = {
    enable = true;
    # Fixed ports for predictability behind the firewall
    mountdPort = 20048;
    lockdPort = 4001;
    statdPort = 4002;
    
    exports = ''
      /data/nfs *(rw,sync,no_subtree_check,insecure,fsid=0)
    '';
  };
}
