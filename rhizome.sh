#!/bin/sh

set -e

cat <<EOF
title: index
summary: a tumblelog apprehending multitudes

[url-trivium]: https://leahneukirchen.org/trivium/

**rhizome** is a tumblelog inspired by Leah Neukirchen's [Trivium][url-trivium].

it mostly features links I think are cool, but might on occasion be a place for sharing things I'm
up to that don't really warrant a more fleshed out discussion.

[subscribe](rhizome.atom) in your favorite RSS reader.

EOF

i=0
while [ $# -gt 0 ]; do
    i=$(( i + 1 ))
    b="${1%.html}"
    title="${b#rhizome-}"

    echo "[${title}](${1})"
    echo
    [ "${i}" -lt 10 ] && sed -E 's/^([^\[])/> &/' "${1%.html}.md"
    echo
    shift
done


