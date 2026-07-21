{ pkgs, ... }:
let
  sources = import ../../npins;
  flakeCompat = src: (import sources.flake-compat { inherit src; }).defaultNix;
  zen-browser =
    (flakeCompat sources.zen-browser).packages.${pkgs.stdenv.hostPlatform.system}.default;
  agenix-cli =
    (flakeCompat sources.agenix).packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  environment.systemPackages = [
    agenix-cli    # editing/rekeying secrets (bundles age)
    pkgs.stow     # applies the dotfiles
    pkgs.git
    pkgs.nixfmt-rfc-style
  ];

  users.users.ryv.packages = with pkgs; [
    # Browsers / desktop apps
    zen-browser
    google-chrome
    obsidian
    spotify
    libreoffice
    vlc
    gimp
    inkscape
    openshot-qt
    vesktop
    (wrapOBS { plugins = with obs-studio-plugins; [ obs-vaapi obs-pipewire-audio-capture ]; })
    # Gaming (steam/gamescope/gamemode system-side)
    prismlauncher
    wine
    bottles
    protonup-qt
    protontricks
    lutris
    vulkan-tools
    mangohud
    # niri / noctalia backends
    xwayland-satellite
    brightnessctl
    cliphist
    wl-clipboard
    grim
    slurp
    satty
    matugen
    cava
    playerctl
    # Terminal / editors (configs are stow-managed)
    alacritty
    tmux
    neovim
    zed-editor
    # Shell toolchain (formerly home-manager programs.*)
    starship
    bat
    fzf
    zoxide
    eza
    fd
    ripgrep
    jq
    direnv
    nix-direnv
    delta
    gh
    yazi
    btop
    fastfetch
    # File manager + viewers
    nautilus
    file-roller
    zathura
    imv
    pavucontrol
    # Theming (referenced by stow'd gtk settings)
    adw-gtk3
    papirus-icon-theme
    bibata-cursors
    # LSPs for zed (its downloaded binaries don't run on NixOS)
    nixd
    gopls
    pyright
    # Dev
    gcc
    gnumake
    python3
    nodejs
    go
    rustup
    kubectl
    k9s
    lazydocker
    cloudflared
    claude-code
  ];
}
