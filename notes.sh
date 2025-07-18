#!/usr/bin/env nix-shell
#! nix-shell -i bash -p bash

set -euo pipefail

export PATH="${PWD}":"${PATH}"

cat <<EOF
:doctitle: index
:description: a place for me to get the thoughts out of my brain

*notes* is a place for me to document and explain things so that I don't forget them, or to get
thoughts out of my head that are bouncing around incessantly.

link:notes.atom[subscribe] in your favorite RSS reader.

EOF

i=0
while [[ $# -gt 0 ]]; do
    i=$((i + 1))
    b="${1%.html}"

    title=$(asciidoctor-query "${b}".adoc doctitle)
    summary=$(asciidoctor-query "${b}".adoc description | tr '\n' ' ')
    date=$(asciidoctor-query "${b}".adoc docdate 2>/dev/null || :)

    echo "${date:+${date} - }link:${1}[${title}]"
    echo
    if [[ "${i}" -lt 10 ]]; then
        [[ -n "${summary}" ]] && echo "> ${summary}"
        echo
    fi
    shift
done
