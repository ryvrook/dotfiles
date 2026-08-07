{ ... }:
{
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.system76-scheduler.enable = true;

  # Disable direct scanout to avoid freezing
  environment.sessionVariables.COSMIC_DISABLE_DIRECT_SCANOUT = "true";
}
