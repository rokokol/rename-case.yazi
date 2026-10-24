{
  description = "A Yazi plugin that changes filename case and transliterates Russian Cyrillic";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        default = rename-case;
        rename-case = pkgs.callPackage ./nix/package.nix { };
      });

      homeModules.default = import ./nix/module.nix { inherit self; };
      homeManagerModules.default = self.homeModules.default;

      overlays.default = final: prev: {
        yaziPlugins = prev.yaziPlugins // {
          inherit (self.packages.${final.stdenv.hostPlatform.system}) rename-case;
        };
      };

      checks = forAllSystems (
        pkgs:
        import ./nix/checks.nix {
          inherit
            lib
            pkgs
            home-manager
            self
            ;
        }
      );

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            lua5_5
            stylua
            luajitPackages.luacheck
            python3
            ruff
            nixfmt
            statix
            deadnix
            jq
            git
            nix
          ];
          UNICODE_DATA = "${pkgs.unicode-character-database}/share/unicode/UnicodeData.txt";
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
