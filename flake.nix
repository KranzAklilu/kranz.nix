{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    prisma = { url = "github:pimeys/nixos-prisma"; };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    monitor-affinity.url = "github:davidmreed/monitor-affinity";
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
          ({ config, ... }: { _module.args = { unstable = unstablePkgs; }; })
          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          ./hosts/default/configuration.nix

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
