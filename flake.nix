{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    prisma = { url = "github:pimeys/nixos-prisma"; };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    monitor-affinity.url = "github:davidmreed/monitor-affinity";
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      system = "x86_64-linux";
      common = { pkgs, config, ... }: {
        nixpkgs.overlays = [
          inputs.prisma.overlay
          inputs.fenix.overlays.default # Add Fenix overlay
        ];
      };
      unstablePkgs = nixpkgs-unstable.legacyPackages.${system};
    in {
      nixosConfigurations.kranz-rog = nixpkgs.lib.nixosSystem {
        system = system;

        modules = [
          ./hosts/default/configuration.nix

          ({ config, ... }: {
            nixpkgs.config.allowUnfree = true;
            _module.args = { unstable = unstablePkgs; };
          })

          common
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.kranz = import ./hosts/default/home.nix;

          }
          ({ pkgs, ... }: {
            environment.systemPackages = with pkgs;
              [
                # inputs.fenix.packages.${pkgs.system}.minimal.toolchain
                # inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
                inputs.monitor-affinity.packages.${pkgs.stdenv.hostPlatform.system}.default
              ];
          })
        ];
      };
    };
}
