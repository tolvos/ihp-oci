{
  description = "IHP development packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  architectures = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  outputs = { self, nixpkgs }:
    let
      forAllArchs = nixpkgs.lib.genAttrs self.architectures;
      ihpTools = pkgs: with pkgs; [
        ihp-new
        direnv
        nix-direnv
        devenv
      ];

      mkOutputs = arch:
        let
          pkgs = nixpkgs.legacyPackages.${arch};
          tools = ihpTools pkgs;
        in
        {
          ihpNew = pkgs.ihp-new;
          direnv = pkgs.direnv;
          nixDirenv = pkgs.nix-direnv;
          devenv = pkgs.devenv;
          default = pkgs.buildEnv {
            name = "ihp-dev-environment";
            paths = tools;
          };
        };
    in
    {
      packages = forAllArchs mkOutputs;
    };
}
