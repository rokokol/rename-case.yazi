{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.programs.rename-case-yazi.enable = lib.mkEnableOption "rename-case.yazi";

  config = lib.mkIf config.programs.rename-case-yazi.enable {
    programs.yazi.plugins.rename-case.package =
      self.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
