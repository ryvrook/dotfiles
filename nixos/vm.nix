{
  lib,
  modulesPath,
  pkgs,
  ...
}:
let
  qemu = pkgs.runCommand "host-qemu" { inherit (pkgs.qemu) meta; } ''
    mkdir -p "$out/bin"
    ln -s /usr/bin/qemu-img "$out/bin/qemu-img"
    ln -s /usr/bin/qemu-system-x86_64 "$out/bin/qemu-system-x86_64"
  '';
in
{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
    ./common.nix
  ];

  networking.hostName = "ryv-vm";

  users.users.ryv.initialPassword = "ryv";
  security.sudo.wheelNeedsPassword = false;

  programs.steam.enable = lib.mkForce false;
  programs.steam.gamescopeSession.enable = lib.mkForce false;
  programs.gamescope.enable = lib.mkForce false;
  programs.gamemode.enable = lib.mkForce false;

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
    qemu.package = qemu;
    qemu.options = [
      "-device virtio-vga-gl"
      "-display gtk,gl=on"
    ];
  };
}
