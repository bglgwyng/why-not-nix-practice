# https://wiki.nixos.org/wiki/Flakes
{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {

      packages.${system}.default = pkgs.cowsay;

      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.rustc ];
      };

      # `nix run .#cowsay -- hello` / `nix run .` (default)
      apps.${system} = {
        sl = {
          type = "app";
          program = "${pkgs.sl}/bin/sl";
        };
      };

      # `nix flake check`
      checks.${system} = {
        # 1. 기존 패키지를 그대로 check로 재사용 — 빌드가 성공하면 통과
        build = self.packages.${system}.default;

        # 2. 커스텀 테스트: cowsay가 정상 실행되는지 확인
        cowsay-runs = pkgs.runCommand "cowsay-runs" { } ''
          ${pkgs.cowsay}/bin/cowsay hello > $out
          grep -q hello $out
        '';

        # 3. 포매팅 체크 예시 (nixfmt)
        format = pkgs.runCommand "check-format" { } ''
          ${pkgs.nixfmt-rfc-style}/bin/nixfmt --check ${./flake.nix}
          touch $out
        '';
      };

      # `nix fmt`
      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
