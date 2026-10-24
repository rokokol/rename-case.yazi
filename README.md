# rename-case.yazi

[![Yazi plugin](https://img.shields.io/badge/Yazi-plugin-blue?style=flat)](https://yazi-rs.github.io/docs/plugins/overview/)
[![assets](https://img.shields.io/badge/docs-assets-555?style=flat)](ASSETS.md)

Rename selected files and folders, or the hovered item, with Unicode-aware case conversion. You can also transliterate Russian Cyrillic to ICAO Latin

File extensions and dotfile prefixes stay unchanged. Folder names change in full. The plugin skips existing destination names and keeps the cursor on the renamed item

## Install

```sh
ya pkg add rokokol/rename-case
```

The plugin needs only Yazi. It does not need Nix, Python, or external programs at runtime. No setup call is required

## Use

Add a key to `keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on = [ "<Space>", "r", "k" ]
run = "plugin rename-case kebab"
desc = "Rename to kebab-case"
```

Replace `kebab` with the desired mode:

| Mode | Result |
| --- | --- |
| `kebab` | `my-file-name.txt` |
| `snake` | `my_file_name.txt` |
| `caps` | `MY_FILE_NAME.txt` |
| `pascal` | `MyFileName.txt` |
| `camel` | `myFileName.txt` |
| `icao` | `Щука.txt` becomes `Shchuka.txt` |

Case conversion keeps one code point per character. It does not expand a letter into several letters, so uppercase conversion keeps `ß` unchanged

## Home Manager

Add the flake input:

```nix
inputs.rename-case-yazi = {
  url = "github:rokokol/rename-case.yazi";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Import its module into your home configuration:

```nix
{
  imports = [ inputs.rename-case-yazi.homeModules.default ];
  programs.yazi.enable = true;
  programs.rename-case-yazi.enable = true;
}
```

The module installs the plugin. Add keys separately, as shown above
