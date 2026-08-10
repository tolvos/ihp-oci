{
  description = "IHP development packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      devPackages = with pkgs; [
        ihp-new
        direnv
        nix-direnv
        devenv
      ];
    in {
      packages.${system} = {
        inherit (pkgs)
          ihp-new
          direnv
          nix-direnv
          devenv;

        default = pkgs.buildEnv {
          name = "ihp-dev-packages";
          paths = devPackages;
        };
      };
    };
}
