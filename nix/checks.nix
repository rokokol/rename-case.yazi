{
  lib,
  pkgs,
  home-manager,
  self,
}:

let
  plugin = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
  root = builtins.path {
    name = "rename-case-check-source";
    path = ../.;
  };
  wiring = import ./module-test.nix {
    inherit
      lib
      pkgs
      home-manager
      self
      ;
  };
in
{
  tests = pkgs.runCommand "rename-case-tests" { nativeBuildInputs = with pkgs; [ lua5_5 ]; } ''
    lua ${root}/tests/unit.lua ${plugin}
    lua ${root}/tests/entry.lua ${plugin}
    test -f ${plugin}/LICENSE
    test -f ${plugin}/README.md
    test ! -e ${plugin}/tests
    test ! -e ${plugin}/scripts
    touch "$out"
  '';

  case-is-current =
    pkgs.runCommand "rename-case-data-is-current"
      {
        nativeBuildInputs = with pkgs; [ python3 ];
      }
      ''
        python ${root}/scripts/generate.py \
          ${pkgs.unicode-character-database}/share/unicode/UnicodeData.txt -o generated
        diff ${plugin}/case.lua generated/case.lua
        diff ${plugin}/translit.lua generated/translit.lua
        touch "$out"
      '';

  module-wiring =
    assert wiring;
    pkgs.runCommand "rename-case-module-wiring" { } ''
      touch "$out"
    '';

  lint =
    pkgs.runCommand "rename-case-lint"
      {
        nativeBuildInputs = with pkgs; [
          stylua
          luajitPackages.luacheck
          ruff
        ];
      }
      ''
        cp -r ${root}/. .
        stylua --check main.lua case.lua translit.lua tests
        luacheck main.lua case.lua translit.lua tests
        ruff check scripts
        ruff format --check scripts
        touch "$out"
      '';

  metadata =
    pkgs.runCommand "rename-case-metadata"
      {
        nativeBuildInputs = with pkgs; [
          bash
          git
          python3
        ];
      }
      ''
        cp -r ${root}/. .
        bash vendor-sync.sh check
        chmod u+w ./*.sh
        patchShebangs ./*.sh
        bash check-pins.sh
        bash check-changelog.sh
        bash check-prose.sh README.md ASSETS.md CHANGELOG.md CONTRIBUTING.md CLAUDE.md
        touch "$out"
      '';

  nix-lint =
    pkgs.runCommand "rename-case-nix-lint"
      {
        nativeBuildInputs = with pkgs; [
          bash
          deadnix
          git
          jq
          nix
          nixfmt
          statix
        ];
      }
      ''
        export HOME="$TMPDIR"
        cp -r ${root}/. .
        chmod -R u+w .
        patchShebangs ./*.sh
        bash check-nix.sh --static -C ${root} -N programs.rename-case-yazi
        touch "$out"
      '';
}
