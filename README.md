# codex-applypatch

`apply_patch` as a normal executable for Linux and macOS.

This flake builds the canonical `codex-apply-patch` package from the OpenAI Codex source already pinned and hashed by nixpkgs. It does not approximate the patch grammar with `patch`, `sed`, or a compatibility parser; the resulting binary is the same standalone implementation Codex uses.

## Run

```sh
nix run github:anghel4d/codex-applypatch -- '*** Begin Patch
*** Add File: hello.txt
+hello
*** End Patch'
```

The executable also accepts a patch on standard input:

```sh
apply_patch <<'PATCH'
*** Begin Patch
*** Update File: hello.txt
@@
-hello
+hello, world
*** End Patch
PATCH
```

## Install

Add the flake as an input and install `inputs.codex-applypatch.packages.${pkgs.system}.default`, or install it directly:

```sh
nix profile install github:anghel4d/codex-applypatch
```

`nix flake check` builds the executable and verifies add, update, move, and delete semantics.
