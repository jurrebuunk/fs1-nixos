{ ... }:

{
  services.nfs.server.exports = ''
    /data/nfs 192.168.1.0/24(rw,sync,no_subtree_check,insecure,no_root_squash)
  '';
}
