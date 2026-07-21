# Eval-only entry: instantiate the system toplevel without nixos-rebuild.
# Used by CI and dev checks:  nix-instantiate nixos/eval.nix
let
  sources = import ../npins;
in
(import (sources.nixpkgs + "/nixos") {
  configuration = ./configuration.nix;
}).system
