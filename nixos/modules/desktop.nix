{ pkgs, lib, ... }:
{
  # niri from nixpkgs; config is a stow-managed plain file (~/.config/niri/config.kdl).
  programs.niri.enable = true;

  # Supervised noctalia startup: restarts on crash, binds to the session.
  # path carries the backends noctalia shells out to.
  systemd.user.services.noctalia = {
    description = "Noctalia desktop shell";
    bindsTo = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    path = with pkgs; [ brightnessctl cliphist wl-clipboard matugen cava ];
    serviceConfig = {
      ExecStart = lib.getExe pkgs.noctalia-shell;
      Restart = "on-failure";
      RestartSec = 1;
      Slice = "session.slice";
    };
  };

  # Polkit agent (formerly home-manager's lxqt-policykit-agent service).
  systemd.user.services.lxqt-policykit-agent = {
    description = "LXQt polkit agent";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent";
      Restart = "on-failure";
    };
  };

  # Proxies media keys to the most recently active player (niri binds use playerctl).
  systemd.user.services.playerctld = {
    description = "playerctld";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "org.mpris.MediaPlayer2.playerctld";
      ExecStart = "${pkgs.playerctl}/bin/playerctld";
    };
  };

  # Qt follows the dark GTK look (formerly home-manager qt.platformTheme).
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
}
