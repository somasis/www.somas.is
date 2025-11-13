# <https://github.com/numtide/treefmt-nix>
# Used by ./shell.nix.
{
  sources ? import ./npins,
  nixpkgs ? sources.nixpkgs,
  treefmt-nix ? sources.treefmt-nix,

  pkgs ? import nixpkgs { },
}:
(import treefmt-nix).mkWrapper pkgs {
  # See also <https://github.com/numtide/treefmt-nix/tree/main/programs>
  projectRootFile = "npins/sources.json";

  programs = {
    # Allow keeping certain lines sorted
    # <https://github.com/google/keep-sorted>
    keep-sorted.enable = true;

    nixfmt.enable = true;
    oxipng.enable = true;

    prettier = {
      enable = true;
      package =
        with pkgs;
        prettier.override {
          plugins = with nodePackages; [
            (
              prettier-plugin-go-template
              // {
                packageName = "prettier-plugin-go-template";
                outPath = toString prettier-plugin-go-template;
              }
            )
          ];
        };

      excludes = [
        "themes/somasis/layouts/_partials/*"
      ];

      settings.overrides = [
        {
          files = [ "*.html" ];
          options.parser = "go-template";
        }
      ];
    };
  };
}
