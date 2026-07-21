{ config, pkgs, lib, ... }:
let
  sources = import ../npins;
in
{
  imports = [
    ./hardware-configuration.nix
    (sources.agenix + "/modules/age.nix")
    ./modules/desktop.nix
    ./modules/greetd.nix
    ./modules/services.nix
    ./modules/packages.nix
  ]
  # Machine-local, never committed. local.nix: Omarchy chainload entry (disk
  # identifiers). secret.nix: legacy password hash for machines whose host key
  # isn't enrolled in secrets/secrets.nix yet.
  ++ lib.optionals (builtins.pathExists ./local.nix) [ ./local.nix ]
  ++ lib.optionals (builtins.pathExists ./secret.nix) [ ./secret.nix ];

  # Bootloader Limine UEFI, chainloading Omarchy
  boot.loader.limine.enable = true;
  boot.loader.limine.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.limine.style.interface.branding = "Ryv Limine Bootloader";
  boot.loader.limine.style.backdrop = "001429";
  boot.loader.limine.style.interface.brandingColor = "ffffff";

  networking.hostName = "ryv";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;
  # pnpm 10.29.2 was flagged insecure on pre-lock nixpkgs-unstable and pulled
  # in as a build dep. Kept in case a future re-pin lands on a rev where it's
  # flagged again.
  nixpkgs.config.permittedInsecurePackages = [ "pnpm-10.29.2" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  # Noctalia binary cache (avoids compiling Quickshell/Qt).
  nix.settings.extra-substituters = [ "https://noctalia.cachix.org" ];
  nix.settings.extra-trusted-public-keys = [
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
  ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Secrets (agenix). Encrypted .age files are committed; decryption happens
  # at activation with the host SSH key (must be listed in secrets/secrets.nix).
  age.secrets.ryv-password.file = ../secrets/ryv-password.age;

  users.users.ryv = {
    isNormalUser = true;
    description = "ryv";
    extraGroups = [ "wheel" "networkmanager" "docker" "video" ];
    shell = pkgs.fish;
    # Login password comes from the agenix secret. A machine-local secret.nix
    # (legacy hashedPassword) wins while present, so a machine whose host key
    # isn't enrolled yet keeps working.
    hashedPasswordFile = lib.mkIf (!(builtins.pathExists ./secret.nix))
      config.age.secrets.ryv-password.path;
    # 1Password SSH keys (github.com/ryvrook.keys); sshd is key-only.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIoWx4/Tb6RdokMIweOMRuhtZbj3+LNwves+gxoC1uRW"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILEtVzIbnAEsxYMWYmczpM4uzZAXJpcR5kMovRGV7sNH"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG13G0zoBFUItdKeGQ+EIL/OuA6d4eC21GlyjIQJEpIw"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIEHVaZdwY2YiGodSrMNlgt/yXRX8D8Wt+vJId+UFzxb"
    ];
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.dconf.enable = true;

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  security.polkit.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.fstrim.enable = true;
  zramSwap.enable = true;

  programs.fish.enable = true;   # needed for fish login shell
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };
  virtualisation.docker.enable = true;

  # Session env formerly set by home-manager.
  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    BROWSER = "zen-beta";
  };

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
  ];

  system.stateVersion = "26.11";   # do not lower
}
