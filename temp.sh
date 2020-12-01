#!/bin/sh

set -e

meta() {
    lowdown -T html -X "${1}" "${2}" 2>/dev/null
}

ahrefif() {
    href="$1"; shift
    n="$1"; shift
    if [ "${b}" = "${n}" ]; then
        echo ""
    else
        echo "<a href='${href}'>${n}</a>$*"
    fi
}

f="${1}"
b="${1%.md}"


title=$(meta title "${f}" || printf '%s\n' "${b#*-}")
summary=$(meta summary "${f}" || printf '')
date=$(meta date "${f}" || printf '')

img="<img src='https://www.gravatar.com/avatar/a187e38560bb56f5231cd19e45ad80f6?s=128' />"
header="<a href='index.html'>~somasis</a>"
site_title="~somasis"

case "${b}" in
    rhizome-*)
        site_title="${site_title}/rhizome"
        header="${header}/<a href='rhizome.html'>rhizome</a>"
        ;;
    note-*)
        site_title="${site_title}/notes"
        header="${header}/<a href='notes.html'>notes</a>"
        ;;
    notes|rhizome)
        site_title="${site_title}/${b}"
        title="${site_title}"
        header="${header}/${b}"
        ;;
    index)
        header='~somasis'
        ;;
    *) : ;;
esac

site_base_title="${site_title}"
[ "${title}" = "${site_title}" ] || site_title="${site_title} - ${title}"

cat <<EOF
<!DOCTYPE html>
<html lang="en-US" xmlns:og="http://opengraphprotocol.org/schema/">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>${site_title}</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/normalize.css@8.0.1/normalize.min.css" />
<link rel="stylesheet" href="style.css" />

<meta name="title" content="${site_title}" />
<meta property="og:site_name" content="${site_base_title}" />
<meta property="og:title" content="${title}" />
<meta name="description" content="${summary}" />
<meta property="og:description" content="${summary}" />
<meta property="twitter:site" content="@kyliesomasis" />

<link href="notes.atom" type="application/atom+xml" rel="alternate" title="~somasis/notes" />
<link href="rhizome.atom" type="application/atom+xml" rel="alternate" title="~somasis/rhizome" />

</head>
<body>
<header>
<h1>${img}${header}</h1>
</header>
<main>
EOF

case "${b}" in
    index|rhizome|notes) : ;;
    rhizome-*)
        printf '<header>\n'
        printf '<h1><time datetime="%s">%s</time></h1>\n' "${title}" "${title}"
        printf '</header>\n'
        ;;
    *)
        if [ -n "${title}" ]; then
            printf '<header>\n'
            printf '<h1>%s</h1>\n' "${title}"
            [ -n "${summary}" ] && printf '<p>%s</p>\n' "${summary}"
            [ -n "${date}" ] && printf '<time datetime="%s">%s</time>\n' "${date}" "${date}"
            printf '</header>\n'
        fi
        ;;
esac

cat <<EOF
<article>
$(lowdown -T html --html-no-escapehtml --html-no-skiphtml "${f}")
</article>
EOF

cat <<EOF
</main>
<footer>
<small>
<a href='https://git.mutiny.red/somasis/www.somas.is'>generated at $(TZ=UTC date +"%Y-%d-%mT%H:%M:%S%:z")</a>
- <a href='mailto:kylie@somas.is'>kylie@somas.is</a>
</small>
</footer>
</body>
</html>
EOF

