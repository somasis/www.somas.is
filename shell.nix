let
  sources = import ./npins;

  pkgs = import sources.nixpkgs { };

  git-hooks = import ./git-hooks.nix;
  treefmt = import ./treefmt.nix;
in
pkgs.mkShell {
  buildInputs = git-hooks.enabledPackages ++ [
    # keep-sorted start
    pkgs.asciidoctor-with-extensions
    pkgs.curlMinimal
    pkgs.devd
    pkgs.gitMinimal
    pkgs.gnumake
    pkgs.imagemagick
    pkgs.minify
    pkgs.npins
    pkgs.python3Packages.python-slugify
    pkgs.rsync
    pkgs.rwc
    pkgs.xe
    # keep-sorted end
    treefmt
  ];
}
