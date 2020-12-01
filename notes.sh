#!/bin/sh

set -e

cat <<EOF
title: index

**notes** is a place for me to document and explain things so that I don't forget them, or to get
thoughts out of my head that are bouncing around incessantly.

[subscribe](notes.atom) in your favorite RSS reader.

EOF

i=0
while [ $# -gt 0 ]; do
    i=$(( i + 1 ))
    b="${1%.html}"

    title=$(lowdown -T html -X title "${b}".md)
    summary=$(lowdown -T html -X summary "${b}".md | tr '\n' ' ')
    date=$(lowdown -T html -X date "${b}".md 2>/dev/null || :)

    echo "${date:+$date - }[${title}](${1})"
    echo
    if [ "${i}" -lt 5 ]; then
        [ -n "${summary}" ] && echo "> ${summary}"
        echo
    fi
    shift
done

