{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    prisma = { url = "github:pimeys/nixos-prisma"; };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      common = { pkgs, config, ... }: {
        nixpkgs.overlays = [
          inputs.prisma.overlay
          inputs.fenix.overlays.default # Add Fenix overlay
        ];
      };
    in {
      nixosConfigurations.kranz-rog = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
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
          # ({ pkgs, ... }: {
          #   environment.systemPackages = with pkgs; [
          #     inputs.fenix.packages.${pkgs.system}.minimal.toolchain
          #     rust-analyzer
          #   ];
          # })
        ];
      };
    };
}
