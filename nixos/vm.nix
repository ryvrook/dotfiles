{ lib, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
    ./common.nix
  ];

  networking.hostName = "ryv-vm";

  users.users.ryv.initialPassword = "ryv";
  security.sudo.wheelNeedsPassword = false;

  services.fwupd.enable = lib.mkForce false;
  services.fstrim.enable = lib.mkForce false;
  services.snapper.configs = lib.mkForce { };
  hardware.bluetooth.enable = lib.mkForce false;
  services.blueman.enable = lib.mkForce false;
  virtualisation.docker.enable = lib.mkForce false;

  virtualisation = {
    memorySize = 8192;
    cores = 4;
    diskSize = 20480;
    graphics = true;
  };
}
