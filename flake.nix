{
  description = "Standalone canonical apply_patch from OpenAI Codex";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          applyPatch = pkgs.codex.overrideAttrs (old: {
            pname = "codex-applypatch";
            cargoBuildFlags = [
              "--package"
              "codex-apply-patch"
              "--bin"
              "apply_patch"
            ];
            cargoCheckFlags = [
              "--package"
              "codex-apply-patch"
              "--bin"
              "apply_patch"
            ];
            postInstall = "";
            postFixup = "";
            doInstallCheck = false;
            nativeInstallCheckInputs = [ ];
            passthru = { };
            meta = old.meta // {
              description = "Canonical standalone apply_patch CLI from OpenAI Codex";
              mainProgram = "apply_patch";
            };
          });
        in
        {
          default = applyPatch;
          codex-applypatch = applyPatch;
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/apply_patch";
          meta.description = "Apply an OpenAI Codex patch to the current working tree";
        };
      });

      checks = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          applyPatch = self.packages.${system}.default;
        in
        {
          semantics = pkgs.runCommand "codex-applypatch-semantics" { nativeBuildInputs = [ applyPatch ]; } ''
            mkdir -p work
            cd work
            printf 'alpha\nbeta\ngamma\n' > sample.txt
            apply_patch <<'PATCH'
            *** Begin Patch
            *** Update File: sample.txt
            @@
             alpha
            -beta
            +beta patched
             gamma
            *** Add File: nested/new.txt
            +new content
            *** End Patch
            PATCH
            apply_patch <<'PATCH'
            *** Begin Patch
            *** Update File: nested/new.txt
            *** Move to: moved.txt
            @@
            -new content
            +moved content
            *** Delete File: sample.txt
            *** End Patch
            PATCH
            test ! -e sample.txt
            test ! -e nested/new.txt
            test "$(cat moved.txt)" = "moved content"
            touch "$out"
          '';
        }
      );
    };
}
