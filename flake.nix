{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    prisma = { url = "github:pimeys/nixos-prisma"; };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      common = { pkgs, config, ... }: {
        nixpkgs.overlays = [ inputs.prisma.overlay ];
      };
    in {
      nixosConfigurations.kranz-rog = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect

          ./hosts/default/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.kranz = import ./hosts/default/home.nix;

          }
        ];
      };
    };
}
