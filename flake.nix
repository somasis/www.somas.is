{
  description = "somas.is";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  inputs.git-hooks = {
    url = "github:cachix/git-hooks.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      git-hooks,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
      system = builtins.currentSystem or "x86_64-linux";
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      checks = forAllSystems (system: {
        git-hooks = git-hooks.lib.${system}.run {
          src = ./.;

          hooks = {
            # Git style
            gitlint.enable = true;
            check-merge-conflicts.enable = true;

            # Ensure we don't have commit anything bad
            check-added-large-files.enable = true; # avoid committing binaries when possible
            check-executables-have-shebangs.enable = true;
            check-shebang-scripts-are-executable.enable = true;
            check-vcs-permalinks.enable = true; # don't use version control links that could rot
            check-symlinks.enable = true; # dead symlinks specifically
            detect-private-keys.enable = true;

            # Ensure we actually follow our .editorconfig rules.
            # editorconfig-checker.enable = true;
          };
        };
      });

      devShells = forAllSystems (
        system: with nixpkgsFor.${system}; {
          default = mkShell {
            shellHook = self.checks.${system}.git-hooks.shellHook;

            buildInputs =
              with inputs;
              self.checks.${system}.git-hooks.enabledPackages
              ++ [
                asciidoctor-with-extensions
                coreutils
                gnumake
                jq
                python3Packages.python-slugify
              ];
          };
        }
      );
    };
}
