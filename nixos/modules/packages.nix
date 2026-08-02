{ inputs, pkgs, ... }:
let
  zen-browser = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
  claude-desktop = pkgs.callPackage ../packages/claude-desktop.nix { };
in
{
  environment.systemPackages = [
    pkgs.stow # applies the dotfiles
    pkgs.git
    pkgs.nixfmt
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
    (wrapOBS {
      plugins = with obs-studio-plugins; [
        obs-vaapi
        obs-pipewire-audio-capture
      ];
    })
    # Gaming (steam/gamescope/gamemode system-side)
    prismlauncher
    wine
    bottles
    protonup-qt
    protontricks
    lutris
    vulkan-tools
    mangohud
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
    claude-desktop
    claude-code
    codex
    # File manager + viewers
    nautilus
    file-roller
    zathura
    imv
    pavucontrol
    gparted
    localsend
    # Theming (referenced by stow'd gtk settings)
    adw-gtk3
    papirus-icon-theme
    bibata-cursors
    # LSPs for zed (its downloaded binaries don't run on NixOS)
    nixd
    gopls
    pyright
    # Dev
    bun
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
  ];
}
