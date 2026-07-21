{ pkgs, lib, ... }:
let
  loginDir = ../assets/login;
  entries = builtins.attrNames (builtins.readDir loginDir);
  findImage = base:
    let matches = lib.filter (n: lib.hasPrefix "${base}." n) entries;
    in if matches == [ ]
       then throw "login screen: no ${base}.* image in nixos/assets/login/"
       else loginDir + "/${lib.head matches}";
  avatar = findImage "avatar";
  wallpaper = findImage "wallpaper";
in
{
  services.accounts-daemon.enable = true;

  programs.regreet = {
    enable = true;

    theme       = { name = "adw-gtk3-dark";      package = pkgs.adw-gtk3; };
    iconTheme   = { name = "Papirus-Dark";       package = pkgs.papirus-icon-theme; };
    cursorTheme = { name = "Bibata-Modern-Ice";  package = pkgs.bibata-cursors; };
    font        = { name = "Noto Sans";          package = pkgs.noto-fonts; size = 12; };

    settings = {
      background = {
        path = wallpaper;
        fit = "Cover";
      };
      GTK.application_prefer_dark_theme = true;
      commands = {
        reboot   = [ "systemctl" "reboot" ];
        poweroff = [ "systemctl" "poweroff" ];
      };
    };
  };

  system.activationScripts.ryvAvatar = ''
    mkdir -p /var/lib/AccountsService/icons /var/lib/AccountsService/users
    cp -f ${avatar} /var/lib/AccountsService/icons/ryv
    cat > /var/lib/AccountsService/users/ryv <<EOF
    [User]
    Icon=/var/lib/AccountsService/icons/ryv
    EOF
  '';
}
