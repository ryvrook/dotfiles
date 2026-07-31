{ ... }:
{
  # File manager backends. gvfs for trash/MTP/SMB, udisks2 for mounting drives.
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  services.fwupd.enable = true;
  # Add flathub once after boot:
  #   flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  services.flatpak.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "ryv" ];
  };
}
