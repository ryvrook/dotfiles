{ pkgs, ... }:
let
  niri =
    pkgs.runCommand "${pkgs.niri.name}-session"
      {
        inherit (pkgs.niri) meta passthru;
      }
      ''
        cp -a ${pkgs.niri} "$out"
        chmod u+w "$out/bin/niri-session"
        substituteInPlace "$out/bin/niri-session" \
          --replace-fail \
          "systemctl --user import-environment" \
          "systemctl --user import-environment PATH"
      '';
in
{
  imports = [
    ./modules/desktop.nix
    ./modules/greetd.nix
    ./modules/services.nix
    ./modules/packages.nix
  ];

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
  nixpkgs.config.permittedInsecurePackages = [ "pnpm-10.29.2" ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.auto-optimise-store = true;
  nix.settings.extra-substituters = [ "https://noctalia.cachix.org" ];
  nix.settings.extra-trusted-public-keys = [
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
  ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  users.mutableUsers = true;
  users.users.ryv = {
    isNormalUser = true;
    description = "ryv";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "video"
    ];
    shell = pkgs.fish;
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
  programs.niri.package = niri;
  services.displayManager.defaultSession = "niri";

  hardware.enableRedistributableFirmware = true;

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

  programs.fish.enable = true;
  programs.steam.enable = true;
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };
  virtualisation.docker.enable = true;

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

  system.stateVersion = "26.11";
}
