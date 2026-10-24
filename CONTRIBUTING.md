# Contribute

Explain the problem and expected behavior in an issue or pull request. Keep each change focused on one problem

Run these checks before you submit a change:

```sh
nix flake check
nix fmt -- --ci
```

After a Unicode update or a change to the transliteration source, regenerate the tables:

```sh
nix develop --command bash -c 'python scripts/generate.py "$UNICODE_DATA"'
```

Add name conversion tests for new case rules. For file operation changes, also test selected files, folders, collisions, and the cursor in Yazi
