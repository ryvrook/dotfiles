{ ... }:
{
  # File manager backends. gvfs for trash/MTP/SMB, udisks2 for mounting drives.
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  services.fwupd.enable = true;
  # Add flathub once after boot:
  #   flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  services.flatpak.enable = true;

  # Hourly btrfs snapshots of /home, capped small (system rollback = generations).
  services.snapper.configs.home = {
    SUBVOLUME = "/home";
    ALLOW_USERS = [ "ryv" ];
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = 2;
    TIMELINE_LIMIT_DAILY = 2;
    TIMELINE_LIMIT_WEEKLY = 1;
    TIMELINE_LIMIT_MONTHLY = 0;
    TIMELINE_LIMIT_YEARLY = 0;
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "ryv" ];
  };
}
