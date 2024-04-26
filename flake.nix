{
  description = "Personal monorepo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dhall-vmadm = {
      url = "github:morgib/dhall-vmadm/master";
      # url = "/home/nixos/dhall-vmadm";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils/main";
  };

  outputs =
    { self, nixpkgs, flake-utils, home-manager, nixos-wsl, dhall-vmadm }:
    let
      # map over pkgs rather than system string
      pkgsSystem = f: system:
        f (import nixpkgs {
          inherit system;
          overlays = [ self.overlays.groundmacs dhall-vmadm.overlay ];
        });
      eachPkgs = systems: f: flake-utils.lib.eachSystem systems (pkgsSystem f);

      # Outputs supported on all systems
      defaultSystemOutputs = pkgs: {
        packages = {
          inherit (pkgs) groundmacs;
          homeConfigurations = {
            # Systemd service requires linux
            groundmacsmac = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                ./nix/home-manager/groundmacs.nix
                {
                  home.homeDirectory = "/Users/morgib";
                  home.username = "morgib";
                }
              ];
            };
          };
        };
      };

      # Outputs for Linux systems only
      linuxSystemOutputs = pkgs: {
        homeConfigurations = {
          # Systemd service requires linux
          groundmacs = home-manager.lib.homeManagerConfiguration {
            configuration = ./nix/home-manager/groundmacs.nix;
            inherit pkgs;
            system = pkgs.stdenv.hostPlatform.system;
            homeDirectory = "/home/mgibson";
            username = "mgibson";
          };
        };
        devShells = import ./nix/devShells/dhall-vmadm.nix {
          inherit pkgs;
          dhall-vmadm = dhall-vmadm.packages.x86_64-linux.dhall-vmadm;
        };
      };

      # Outputs without system hierarchy
      nonSystemOutputs = {
        overlays = { groundmacs = import ./nix/overlays/groundmacs.nix; };

        nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
          modules = [
            nixos-wsl.nixosModules.wsl
            home-manager.nixosModule
            self.nixosModules.base
            self.nixosModules.groundmacs
            {
              wsl.enable = true;
              wsl.nativeSystemd = true;
              wsl.defaultUser = "nixos";
              users.users.nixos = {
                isNormalUser = true;
                home = "/home/nixos";
                extraGroups = [ "wheel" ];
                uid = 1000;
              };
              system.stateVersion = "22.05";
              nixpkgs.localSystem = { system = "x86_64-linux"; };
              nixpkgs.overlays = [ self.overlays.groundmacs ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nixos =
                import ./nix/home-manager/groundmacs.nix;
              # Binary Cache for Haskell.nix
              nix.settings.trusted-public-keys = [
                "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
                "loony-tools:pr9m4BkM/5/eSTZlkQyRt57Jz7OMBxNSUiMC4FkcNfk="
              ];
              nix.settings.substituters = [ "https://cache.iog.io" "https://cache.zw3rk.com"];
            }
          ];
        };

        nixosModules = {
          base = import ./nix/nixos-modules/base.nix;
          groundmacs = import ./nix/nixos-modules/groundmacs.nix;
        };
      };
    in nixpkgs.lib.lists.fold nixpkgs.lib.recursiveUpdate { } [
      (eachPkgs flake-utils.lib.defaultSystems defaultSystemOutputs)
      (eachPkgs (nixpkgs.lib.filter (nixpkgs.lib.hasInfix "linux")
        flake-utils.lib.defaultSystems) linuxSystemOutputs)
      nonSystemOutputs
    ];
}
