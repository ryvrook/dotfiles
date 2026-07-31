{
  description = "Ryv NixOS system and dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      optionalLocalModule =
        variable:
        let
          value = builtins.getEnv variable;
        in
        nixpkgs.lib.optional (value != "") (builtins.toPath value);

      ryv = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          inputs.agenix.nixosModules.default
          ./nixos/configuration.nix
        ]
        ++ optionalLocalModule "NIXOS_HARDWARE_CONFIG"
        ++ optionalLocalModule "NIXOS_LOCAL_CONFIG";
      };

      ryvVm = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          inputs.agenix.nixosModules.default
          ./nixos/vm.nix
        ];
      };
    in
    {
      nixosConfigurations = {
        inherit ryv;
        ryv-vm = ryvVm;
      };

      packages.${system} = {
        default = ryv.config.system.build.toplevel;
        vm = ryvVm.config.system.build.vm;
      };

      apps.${system}.vm = {
        type = "app";
        program = "${ryvVm.config.system.build.vm}/bin/run-ryv-vm-vm";
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;
    };
}
