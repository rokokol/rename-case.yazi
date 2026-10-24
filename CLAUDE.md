# rename-case.yazi

This repository contains a Yazi plugin. `main.lua` converts names and calls the Yazi file API

`scripts/generate.py` generates `case.lua` from UnicodeData.txt and `translit.lua` from `translit/`. Never edit generated tables by hand. The `case-is-current` check compares both outputs with a fresh generation

Yazi's `require` returns a proxy whose index accepts string keys only, so every generated module keeps its data under a named field and `main.lua` reads `require(...).entries`. The tests wrap preloaded modules in the same proxy, so a field that stops unwrapping fails there

`nix/package.nix` packages the runtime files that `ya pkg` installs. `nix/module.nix` installs the plugin and leaves user keys outside the module

Run the commands in [CONTRIBUTING.md](CONTRIBUTING.md) after changes. Also test file operations in a real Yazi instance before a release
