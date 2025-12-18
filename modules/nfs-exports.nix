{ ... }:

{
  services.nfs.server.exports = ''
    /data/nfs *(rw,sync,no_subtree_check,insecure,fsid=0)
  '';
}
