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
    note-music-library-organization.html \
    note-2021-04-06.html \
    note-2020-12-05.html \
    note-2020-12-01.html \
    note-2020-02-11.html \
    note-2019-12-06.html \
    note-2019-11-14.html

RHIZOMES = \
    rhizome-2021-W02.html \
    rhizome-2020-W47.html

ETC = \
    index-latest-major.jpg \
    index-latest-release.jpg

FEEDS = \
    notes.atom \
    rhizome.atom

PDFS = \
    resume.pdf

CSS = \
    style.css

INSTALLS = ${PAGES} ${NOTES} ${RHIZOMES} ${FEEDS} ${PDFS} ${CSS} ${ETC} feed.xml

DESTDIR ?= /srv/www/www.somas.is

TIDYFLAGS ?= -q --wrap 0 --warn-proprietary-attributes false --vertical-space auto

all: FRC pages notes rhizomes feeds pdfs

pages: FRC ${PAGES}
notes: FRC ${NOTES} notes.atom notes.md
rhizomes: FRC ${RHIZOMES} rhizome.atom rhizome.md
feeds: FRC ${FEEDS}
pdfs: FRC ${PDFS}

rhizome.html: rhizome.md
rhizome.md: ${RHIZOMES} rhizome.sh
	sh ./rhizome.sh ${RHIZOMES} > $@

notes.html: notes.md
notes.md: notes.sh ${NOTES}
	sh ./notes.sh ${NOTES} > $@

notes.atom: atom.sh ${NOTES}
	sh ./atom.sh \
	    -t '~somasis/notes' \
	    -u 'https://somas.is/notes.html' \
	    -s 'notes and other short-form writings.' \
	    ${NOTES} \
	    | tidy -xml ${TIDYFLAGS} > $@

rhizome.atom: atom.sh ${RHIZOMES}
	sh ./atom.sh \
	    -t '~somasis/rhizome' \
	    -u 'https://somas.is/rhizome.html' \
	    -s 'tumblelog type... thing. ' \
	    ${RHIZOMES} \
	    | tidy -xml ${TIDYFLAGS} > $@

resume.html: resume.adoc
	asciidoctor -r asciidoctor-html5s -b html5s -o $@ $<

resume.pdf: resume.adoc resume.yml
	asciidoctor -r asciidoctor-pdf -b pdf -o $@ $<

.SUFFIXES: .md .html
.md.html:
	sh ./temp.sh $< | tidy ${TIDYFLAGS} > $@

redirects: FRC redirect.sh
	sh ./redirect.sh /note-2019-11-14.html \
	    2019/11/14/transness-and-philosophy-exclusive.html \
	    blog/2019/11/14/transness-and-philosophy-exclusive.html
	sh ./redirect.sh /note-2019-12-06.html \
	    2019/12/06/reflection-on-therapeutic-philosophy.html \
	    blog/2019/12/06/reflection-on-therapeutic-philosophy.html
	sh ./redirect.sh /note-2020-02-11.html \
	    2020/02/11/memory-fades-but-our-words-are-forever.html \
	    blog/2020/02/11/memory-fades-but-our-words-are-forever.html

install: all redirects
	mkdir -p "${DESTDIR}"
	cp ${INSTALLS} ${DESTDIR}

clean: FRC
	rm -f ${PAGES} ${NOTES} ${RHIZOMES} ${FEEDS} ${PDFS} notes.md rhizome.md

note-new: FRC
	@[ -f note-current.md ] || cp note-template.md note-current.md
	@echo "${PWD}"/note-current.md

note-publish: FRC
	[ -f note-$$(date +%Y-%m-%d).md ] || mv note-current.md note-$$(date +%Y-%m-%d).md

rhizome-new: FRC
	@[ -f rhizome-current.md ] || cp rhizome-template.md rhizome-current.md
	@echo "${PWD}"/rhizome-current.md

rhizome-publish: FRC
	[ -f rhizome-$$(date +%Y-W%W).md ] || mv rhizome-current.md rhizome-$$(date +%Y-W%W).md

FRC:
