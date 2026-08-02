{ pkgs, ... }:
let
  # grim+slurp capture to satty annotation. Bound to Print in the COSMIC
  # shortcuts (see desktop/.config/cosmic/.../Shortcuts/v1/custom), replacing cosmic's built-in screenshot tool.
  screenshot-satty = pkgs.writeShellApplication {
    name = "screenshot-satty";
    runtimeInputs = with pkgs; [
      grim
      slurp
      satty
      wl-clipboard
      coreutils
    ];
    text = ''
      export WAYLAND_DISPLAY="''${WAYLAND_DISPLAY:-wayland-0}"

      out_dir="$HOME/Pictures/Screenshots"
      mkdir -p "$out_dir"
      final="$out_dir/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"

      tmp="$(mktemp --suffix=.png)"
      trap 'rm -f "$tmp"' EXIT

      # slurp -o: click a display to grab whole, or drag to select a region.
      if ! geometry="$(slurp -o)"; then
        exit 0
      fi
      [ -n "$geometry" ] || exit 0

      grim -g "$geometry" "$tmp"

      # Annotate, then on save write to $final and copy to the clipboard.
      satty --filename "$tmp" \
        --output-filename "$final" \
        --copy-command wl-copy \
        --save-after-copy \
        --actions-on-enter save-to-file,save-to-clipboard,exit \
        --actions-on-escape exit
    '';
  };

  # COSMIC's custom-shortcut can be unreliable, so the Print binding
  # launches this through gtk-launch (needs gtk3 on PATH) instead of spawning directly.
  desktopItem = pkgs.makeDesktopItem {
    name = "screenshot-satty";
    desktopName = "Screenshot (satty)";
    exec = "${screenshot-satty}/bin/screenshot-satty";
    icon = "camera-photo";
    terminal = false;
    categories = [ "Utility" ];
    noDisplay = true;
  };
in
{
  environment.systemPackages = [
    screenshot-satty
    desktopItem
    pkgs.gtk3 # provides gtk-launch, used by the COSMIC Print shortcut
  ];
}
