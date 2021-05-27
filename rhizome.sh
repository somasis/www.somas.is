#!/bin/sh

export PATH="${PWD}":"${PATH}"
set -e

cat <<EOF
:doctitle: index
:description: a tumblelog apprehending multitudes

*rhizome* is a tumblelog inspired by Leah Neukirchen's
https://leahneukirchen.org/trivium/[Trivium].

it mostly features links I think are cool, but might on occasion be a place for sharing things I'm
up to that don’t really warrant a more fleshed out discussion.

link:rhizome.atom[subscribe] in your favorite RSS reader.

EOF

i=0
while [ $# -gt 0 ]; do
    i=$(( i + 1 ))
    b="${1%.html}"
    title="${b#rhizome-}"

    echo "link:${1}[${title}]::"
    [ "${i}" -lt 10 ] \
        && cat <<EOF
++++
<blockquote>$(asciidoctor -r asciidoctor-html5s -b html5s -s -o - "${1%.html}.adoc")</blockquote>
++++
EOF
    echo
    shift
done


