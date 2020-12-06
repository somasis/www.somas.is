#!/bin/sh

set -e

meta() {
    lowdown -T html -X "${1}" "${2}" 2>/dev/null
}

f="${1}"
b="${1%.md}"


title=$(meta title "${f}" || printf '%s\n' "${b#*-}")
summary=$(meta summary "${f}" || printf '')
date=$(meta date "${f}" || printf '')

site_name='~somasis' # Used for the beginning part of the ${header}, and the <title>.
header="<a href='index.html'>${site_name}</a>" # Header displayed on top of <body>.
page_title="${site_name}" # Passed directly to <title>.

header_image="<img src='https://www.gravatar.com/avatar/a187e38560bb56f5231cd19e45ad80f6?s=128' />"

case "${b}" in
    rhizome-*)
        site_name="${site_name}/rhizome"
        page_title="${page_title}/rhizome - ${title}"
        header="${header}/<a href='rhizome.html'>rhizome</a>"
        ;;
    note-*)
        site_name="${site_name}/notes"
        page_title="${page_title}/notes - ${title}"
        header="${header}/<a href='notes.html'>notes</a>"
        ;;
    notes|rhizome)
        site_name="${site_name}/${b}"
        page_title="${page_title}/${b}"
        header="${header}/${b}"
        ;;
    index)
        header='~somasis'
        ;;
    *)
        page_title="${page_title}${title:+ - $title}"
        ;;
esac

cat <<EOF
<!DOCTYPE html>
<html lang="en-US" xmlns:og="http://opengraphprotocol.org/schema/">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>${page_title}</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/normalize.css@8.0.1/normalize.min.css" />
<link rel="stylesheet" href="style.css" />

<meta name="title" content="${page_title}" />
<meta property="og:site_name" content="${site_name}" />
<meta property="og:title" content="${title}" />
<meta name="description" content="${summary}" />
<meta property="og:description" content="${summary}" />
<meta property="twitter:site" content="@kyliesomasis" />
<meta property="og:type" content="article" />

<link href="notes.atom" type="application/atom+xml" rel="alternate" title="~somasis/notes" />
<link href="rhizome.atom" type="application/atom+xml" rel="alternate" title="~somasis/rhizome" />

</head>
<body>
<header>
<h1>${header_image}${header}</h1>
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
<a href='https://git.mutiny.red/somasis/www.somas.is'>generated at $(TZ=UTC date +"%Y-%d-%mT%H:%M:%S%:z")</a>
- <a href='mailto:kylie@somas.is'>kylie@somas.is</a>
</footer>
</body>
</html>
EOF

