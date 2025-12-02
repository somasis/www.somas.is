# <https://github.com/cachix/git-hooks.nix>
# Used by ./shell.nix.
{
  sources ? import ./npins,

  nixpkgs ? sources.nixpkgs,
  git-hooks ? sources.git-hooks,

  pkgs ? import nixpkgs { },
  lib ? pkgs.lib,
  ...
}@args:
let
  git-hooks' = import git-hooks;
in
git-hooks'.run {
  src = ./.;

  hooks = {
    check-merge-conflicts.enable = true;

    check-vcs-permalinks.enable = true; # don't use version control links that could rot

    # Ensure we don't have dead links.
    lychee = {
      enable = true;
      excludes = [
        "archetypes/rhizome.md"
        "layouts/.*"
        "npins/.*"
      ];

      settings.flags = lib.concatStringsSep " " [
        "--suggest" # Suggest archived versions of dead URLs.
        "--require-https" # When HTTPS is available, insist on using it.

        "--user-agent"
        "curl"

        # Some sites (LinkedIn for some reason?) give a 999
        "--accept"
        "100..=103,200..=299,403,999"
      ];
    };

    # <https://github.com/DavidAnson/markdownlint#configuration>
    markdownlint = {
      enable = true;
      settings.configuration = {
        # Disable code block style consistency; I use indented code blocks
        # for talking about shell/terminal input, and I use fenced code for
        # everything else.
        code-block-style = false;

        # I use extra spaces in lists for readability's sake.
        list-marker-space = false;

        # Ignore line-length since I exceed it sometimes for brevity's sake.
        line-length = false;

        # Allow inline HTML.
        no-inline-html = false;
      };

      excludes = [
        "archetypes/.*\.md"
      ];
    };

    treefmt = {
      enable = true;
      package = import ./treefmt.nix args;
    };
  };
}
