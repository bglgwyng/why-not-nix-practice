{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      flake = {
        nixosModules.pizza = ./pizza.nix;
      };
      perSystem =
        { pkgs, lib, ... }:
        {
          apps.default =
            let
              eval = lib.evalModules {
                modules = [
                  ./pizza.nix
                  #
                  ./john.nix
                  ./jane.nix
                ];
              };
            in
            {
              type = "app";
              program = "${pkgs.writeShellScript "show-order" ''
                cat ${pkgs.writeText "pizza-order" eval.config.pizza.order}
              ''}";
            };
        };
    };
}
