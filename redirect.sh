#!/bin/sh

set -ex

dest="${1}"; shift

while [ "$#" -gt 0 ]; do
    mkdir -p "${DESTDIR:-}$(dirname "${1}")"

    cat >"${DESTDIR:-}${1}" <<EOF
<!DOCTYPE html>
<html lang="en-US">
<meta charset="utf-8">
<title>redirecting...</title>
<link rel="canonical" href="${dest}" />
<meta http-equiv="refresh" content="0; url=${dest}" />
<meta name="robots" content="noindex" />
<a href="${dest}">click here if you are not redirected.</a>
</html>
EOF
    shift
done
