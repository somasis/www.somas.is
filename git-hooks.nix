# <https://github.com/cachix/git-hooks.nix>
# Used by ./shell.nix.
let
  sources = import ./npins;
  git-hooks = import sources.git-hooks;
in
git-hooks.run {
  src = ./.;

  hooks = {
    # Git style
    gitlint.enable = true;

    check-merge-conflicts.enable = true;

    check-vcs-permalinks.enable = true; # don't use version control links that could rot

    # Ensure we don't have dead links.
    lychee.enable = true;

    markdownlint.enable = true;
    nixfmt-rfc-style.enable = true;

    treefmt = {
      enable = true;
      package = import ./treefmt.nix;
    };
  };
}
