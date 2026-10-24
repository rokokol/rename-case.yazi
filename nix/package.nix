{ lib, yaziPlugins }:

yaziPlugins.mkYaziPlugin {
  pname = "rename-case.yazi";
  version = lib.fileContents ../VERSION;
  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      ../main.lua
      ../case.lua
      ../translit.lua
      ../LICENSE
      ../README.md
    ];
  };

  meta = {
    description = "Yazi plugin that changes filename case and transliterates Russian Cyrillic";
    homepage = "https://github.com/rokokol/rename-case.yazi";
    license = with lib.licenses; [
      mit
      unicode-30
    ];
    platforms = lib.platforms.all;
  };
}
