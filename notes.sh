#!/usr/bin/env nix-shell
#! nix-shell -i bash -p bash pup

set -euo pipefail

export PATH="${PWD}":"${PATH}"

cat <<EOF
---
description: A place for me to get the thoughts out of my brain
breadcrumbs: <br/>notes
---

*notes* is a place for me to document and explain things so that I don't forget them, or to get
thoughts out of my head that are bouncing around incessantly.

[subscribe](notes.atom) in your favorite RSS reader.

EOF

i=0
while [[ $# -gt 0 ]]; do
        i=$((i + 1))
        b="${1%.html}"

        title=$(pup 'body header h1.title text{}' <"${1}")
        date=$(pup 'head meta[name="dcterms.date"] attr{content}' <"${1}")

        echo "${date:+${date} - }[$title](${1})"
        echo
        # if [[ "${i}" -lt 10 ]]; then
        #         [[ -n "${summary}" ]] && echo "> ${summary}"
        #         echo
        # fi
        shift
done
