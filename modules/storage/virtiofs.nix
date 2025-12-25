{ config, pkgs, ... }:

{
  fileSystems."/mnt/virtiofs" = {
    device = "virtiofs1"; # must match Proxmox tag
    fsType = "virtiofs";
    options = [ "defaults" "nofail" ];
  };

  # Enable QEMU guest agent (required for Virtio-FS)
  services.qemuGuest.enable = true;
}
