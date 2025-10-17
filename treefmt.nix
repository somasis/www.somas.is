# <https://github.com/numtide/treefmt-nix>
# Used by ./shell.nix.
let
  sources = import ./npins;

  pkgs = import sources.nixpkgs { };
  treefmt-nix = import sources.treefmt-nix;
in
treefmt-nix.mkWrapper pkgs {
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
      excludes = [ "templates/*" ];
    };
  };
}
