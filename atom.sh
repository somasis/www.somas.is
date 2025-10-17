#!/bin/sh

export PATH="${PWD}:${PATH}"
set -e

title='somas.is'

root='https://somas.is'
site="${root}"
updated=$(TZ=UTC date +'%Y-%m-%dT%H:%M:%SZ')

while getopts :t:r:s:u: arg >/dev/null 2>&1; do
    case "${arg}" in
        t)
            title="${OPTARG}"
            ;;
        r)
            root="${OPTARG}"
            ;;
        u)
            site="${OPTARG}"
            ;;
        s)
            subtitle="${OPTARG}"
            ;;
        *)
            printf 'unknown option -- %s\n' "${arg}" >&2
            printf 'atom.sh [-t TITLE] [-r ROOT] [-u MAIN_URL] [-s SUBTITLE] ITEMS...\n' >&2
            exit 69
            ;;
    esac
done
shift $((OPTIND - 1))

cat <<EOF
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
<title>${title}</title>
${subtitle:+<subtitle>${subtitle}</subtitle>}
<author><name>Kylie McClain</name><email>kylie@somas.is</email></author>
<link rel="alternate" href="${site}" />
<id>${root}/</id>
<updated>${updated}</updated>
EOF

while [ $# -gt 0 ]; do
    b="${1%.html}"

    url="${root}"/"${1}"
    title=$(pup 'body header h1.title text{}' <"${1}" || printf '%s\n' "${b#*-}")
    updated=$(LC_ALL=C TZ=UTC stat -c '%y' "${1}" | sed -E 's/\.[0-9]+ //; s/ /T/; s/([0-9]{2})([0-9]{2})$/\1:\2/')

    case "${1}" in
        rhizome-*)
            date="${b#*-}"
            ;;
        *)
            date=$(pup 'head meta[name="dcterms.date"] attr{content}' <"${1}")
            ;;
    esac

    cat <<EOF
<entry>
<title type="html">${title}</title>
<summary>${summary}</summary>
<link rel="alternate" href="${url}" type="text/html" title="${title}" />
<id>${url}</id>
<published>${date}T00:00:00+00:00</published>
<updated>${updated}</updated>
<content type="html">
$(pandoc -t html "$1" -o - | sed 's/</\&lt;/g; s/>/\&gt;/g')
</content>
</entry>
EOF

    shift
done

echo "</feed>"
