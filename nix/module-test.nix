{
  lib,
  pkgs,
  home-manager,
  self,
}:

let
  plugin = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
  home =
    enabled:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        self.homeModules.default
        {
          home = {
            username = "test";
            homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/test" else "/home/test";
            stateVersion = "26.05";
          };
          programs = {
            yazi = {
              enable = true;
              plugins.sentinel = plugin;
            };
            rename-case-yazi.enable = enabled;
          };
        }
      ];
    };
  enabled = (home true).config.programs.yazi;
  disabled = (home false).config.programs.yazi;
in
assert lib.assertMsg (
  enabled.plugins.rename-case.package == plugin
) "The module must install its plugin";
assert lib.assertMsg (!enabled.plugins.rename-case.setup) "The plugin does not need setup";
assert lib.assertMsg (enabled.plugins ? sentinel) "Other plugin definitions must survive the merge";
assert lib.assertMsg (
  !(disabled.plugins ? rename-case)
) "A disabled module must not install its plugin";
assert lib.assertMsg (enabled.extraPackages == [ ]) "The plugin must not add runtime dependencies";
true
