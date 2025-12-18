{ ... }:

{
  services.nfs.server.exports = ''
    /data/nfs 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash,fsid=1)
    /data/nfs nixos-usb(rw,sync,no_subtree_check,no_root_squash,fsid=1)
  '';
}
