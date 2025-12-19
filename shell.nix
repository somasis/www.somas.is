{
  sources ? import ./npins,
  nixpkgs ? sources.nixpkgs,

  pkgs ? import nixpkgs { },
  lib ? pkgs.lib,
}:
let
  git-hooks = import ./git-hooks.nix { };
  treefmt = import ./treefmt.nix { };

  npins-auto-update = pkgs.writeShellScript "npins-auto-update" ''
    edo() {
        local arg string
        string=
        for arg; do
            if [[ ''${arg@Q} == "'$arg'" ]] && ! [[ ''${arg} =~ [[:blank:]] ]]; then
                string+="''${string:+ }$arg"
            else
                string+="''${string:+ }''${arg@Q}"
            fi
        done

        printf '$ %s\n' "''${string}" >&2
        # alt: printf '$ %s\n' "$(condquote "$@")" >&2

        "$@"
    }

    PATH=${
      lib.makeBinPath (
        with pkgs;
        [
          dateutils
          gitMinimal
          npins
          nix
        ]
      )
    }"''${PATH:+:$PATH}"

    if ! git diff-index --quiet --cached HEAD --; then
        printf 'npins-auto-update: Git repository is dirty, not updating\n' >&2
        exit 1
    fi

    last_npins_change=$(
        stat -c '%Y' npins/* | sort -nr | head -n1
    )
    days_since_change=$(datediff -i '%s' -f '%d' -- "$last_npins_change" now)
    if [ "$days_since_change" -gt 1 ]; then
        edo npins update
        edo git commit -m 'npins: update' npins/
    fi

    exit 0
  '';
in
pkgs.mkShell {
  shellHook = git-hooks.shellHook + ''
    ${npins-auto-update}
  '';

  buildInputs = git-hooks.enabledPackages ++ [
    # keep-sorted start
    pkgs.curlMinimal
    pkgs.gitMinimal
    pkgs.gnumake
    pkgs.hugo
    pkgs.imagemagick
    pkgs.npins
    pkgs.optipng
    pkgs.rclone
    # keep-sorted end
    treefmt
  ];
}
