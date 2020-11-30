#!/bin/sh

set -e

cat <<EOF
title: index

[subscribe](notes.atom) in your favorite RSS reader.

EOF

while [ $# -gt 0 ]; do
    b="${1%.html}"

    title=$(lowdown -T html -X title "${b}".md)
    summary=$(lowdown -T html -X summary "${b}".md | tr '\n' ' ')
    date=$(lowdown -T html -X date "${b}".md 2>/dev/null || :)

    echo "${date:+$date - }[${title}](${1})"
    [ -n "${summary}" ] && echo ": ${summary}"
    echo
    shift
done

