{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/21e69ee7-963c-4105-b29f-d241873be25e";
    fsType = "btrfs";
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/21e69ee7-963c-4105-b29f-d241873be25e";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/21e69ee7-963c-4105-b29f-d241873be25e";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5973-2063";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/e13c3e01-c56b-4e85-9b4b-66a30cc13a92"; } ];
  # Hibernate target (noctalia's session menu offers hibernate; without
  # resumeDevice the kernel can't resume from the swap image).
  boot.resumeDevice = "/dev/disk/by-uuid/e13c3e01-c56b-4e85-9b4b-66a30cc13a92";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
