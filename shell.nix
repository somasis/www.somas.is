let
  sources = import ./npins;

  pkgs = import sources.nixpkgs { };

  git-hooks = import ./git-hooks.nix;
  treefmt = import ./treefmt.nix;
in
pkgs.mkShell {
  buildInputs = git-hooks.enabledPackages ++ [
    pkgs.devd
    pkgs.minify
    pkgs.gnumake
    pkgs.npins
    treefmt
  ];
}
