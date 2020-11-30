.POSIX:
.SUFFIXES:
.DELETE_ON_ERROR:

PAGES = \
    index.html \
    notes.html \
    rhizome.html \
    resume.html

# newest to oldest
NOTES = \
    note-mutiny.html \
    note-2020-02-11.html \
    note-2019-12-06.html \
    note-2019-11-14.html \

ETC = \
    index-latest-album.jpg \
    index-latest-release.jpg

FEEDS = \
    notes.atom

PDFS = \
    resume.pdf

CSS = \
    style.css

OUTPUTS = ${PAGES} ${NOTES} ${FEEDS} ${PDFS} ${CSS} ${ETC}

DESTDIR ?= /srv/www/www.somas.is

all: FRC pages notes feeds pdfs

pages: FRC ${PAGES}
notes: FRC ${NOTES} notes.atom notes.md
feeds: FRC ${FEEDS}
pdfs: FRC ${PDFS}

notes.html: notes.md
notes.md: ${NOTES} notes.sh
	sh ./notes.sh ${NOTES} > $@

notes.atom: ${NOTES}
	sh ./atom.sh \
	    -t '~somasis/notes' \
	    -u 'https://somas.is/notes.html' \
	    -s 'notes and other short-form writings.' \
	    ${NOTES} > $@

resume.html: resume.adoc
	asciidoctor -r asciidoctor-html5s -b html5s -o $@ $<

resume.pdf: resume.adoc resume.yml
	asciidoctor -r asciidoctor-pdf -b pdf -o $@ $<

.SUFFIXES: .md .html
.md.html:
	sh ./temp.sh $< > $@

install: all
	mkdir -p "${DESTDIR}"
	cp ${OUTPUTS} ${DESTDIR}

clean: FRC
	rm -f ${PAGES} ${NOTES} ${FEEDS} ${PDFS} notes.md rhizome.md

FRC:
