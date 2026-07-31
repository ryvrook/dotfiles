{ lib, ... }:
{
  imports = [ ./common.nix ];

  fileSystems."/" = lib.mkDefault {
    device = "none";
    fsType = "tmpfs";
  };

  boot.loader.limine.enable = true;
  boot.loader.limine.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.limine.style.interface.branding = "Limine Bootloader";
  boot.loader.limine.style.backdrop = "001429";
  boot.loader.limine.style.interface.brandingColor = "ffffff";

  networking.hostName = "ryv";
}
