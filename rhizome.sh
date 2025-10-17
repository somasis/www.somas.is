#!/bin/sh

export PATH="${PWD}":"${PATH}"
set -e

cat <<EOF
---
author: Kylie McClain
description: a tumblelog apprehending multitudes
breadcrumbs: <br />rhizome
---

*rhizome* is a tumblelog inspired by Leah Neukirchen's
https://leahneukirchen.org/trivium/[Trivium].

it mostly features links I think are cool, but might on occasion be a place
for sharing things I'm up to that don’t really warrant a more fleshed out
discussion.

[subscribe](rhizome.atom) in your favorite RSS reader.

EOF

i=0
while [ $# -gt 0 ]; do
        i=$((i + 1))
        b="${1%.html}"
        title="${b#rhizome-}"

        echo "[${title}](${1})"
        [ "${i}" -lt 10 ] &&
                cat <<EOF
<blockquote>$(pandoc -t markdown -o - "${b}.md")</blockquote>
EOF
        echo
        shift
done
