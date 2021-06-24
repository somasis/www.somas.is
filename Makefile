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
    note-beets-lossless-and-lossy.html \
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
    index-latest.jpg \
    index-major.jpg

FEEDS = \
    notes.atom \
    rhizome.atom

PDFS = \
    resume.pdf

CSS = \
    style.css

URL_MUSIC    = https://somasis.bandcamp.com/album/in-nature-together
COVER_LATEST = https://f4.bcbits.com/img/a1050589426_0.jpg
COVER_MAJOR  = https://f4.bcbits.com/img/a4175940610_0.jpg

INSTALLS = ${PAGES} ${NOTES} ${RHIZOMES} ${FEEDS} ${PDFS} ${CSS} ${ETC} feed.xml

DESTDIR ?= /srv/www/www.somas.is

all: FRC etc pages notes rhizomes feeds pdfs

etc: FRC ${ETC}
pages: FRC ${PAGES}
notes: FRC ${NOTES} notes.atom notes.adoc
rhizomes: FRC ${RHIZOMES} rhizome.atom rhizome.adoc
feeds: FRC ${FEEDS}
pdfs: FRC ${PDFS}

index-latest.jpg:
	curl -sf -o .tmp_$@ ${COVER_LATEST}
	convert .tmp_$@ \
	    -strip \
	    -resize 300x300 \
	    -sampling-factor 4:2:0 \
	    -quality 85 \
	    -interlace JPEG \
	    -colorspace sRGB \
	    $@
	rm -f .tmp_$@

index-major.jpg:
	curl -sf -o .tmp_$@ ${COVER_MAJOR}
	convert .tmp_$@ \
	    -strip \
	    -resize 300x300 \
	    -sampling-factor 4:2:0 \
	    -quality 85 \
	    -interlace JPEG \
	    -colorspace sRGB \
	    $@
	rm -f .tmp_$@

rhizome.html: rhizome.adoc
rhizome.adoc: rhizome.sh ${RHIZOMES}
	sh ./rhizome.sh ${RHIZOMES} > $@

notes.html: notes.adoc
notes.adoc: notes.sh ${NOTES}
	sh ./notes.sh ${NOTES} > $@

notes.atom: atom.sh ${NOTES}
	sh ./atom.sh \
	    -t '~somasis/notes' \
	    -u 'https://somas.is/notes.html' \
	    -s 'notes and other short-form writings.' \
	    ${NOTES} > $@

rhizome.atom: atom.sh ${RHIZOMES}
	sh ./atom.sh \
	    -t '~somasis/rhizome' \
	    -u 'https://somas.is/rhizome.html' \
	    -s 'tumblelog type... thing. ' \
	    ${RHIZOMES} > $@

resume.html: resume.adoc resume.yml
	asciidoctor -r asciidoctor-html5s -b html -o $@ $<

resume.pdf: resume.adoc resume.yml
	asciidoctor -r asciidoctor-pdf -b pdf -o $@ $<

.SUFFIXES: .adoc .html
.adoc.html:
	sh ./temp.sh $< > $@

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
	sh ./redirect.sh ${URL_MUSIC} \
	    music.html
	ln -sf music.html music

install: all redirects
	mkdir -p "${DESTDIR}"
	cp ${INSTALLS} ${DESTDIR}

clean: FRC
	rm -f ${ETC} ${PAGES} ${NOTES} ${RHIZOMES} ${FEEDS} ${PDFS} notes.adoc rhizome.adoc

note-new: FRC
	@[ -f note-current.adoc ] || cp note-template.adoc note-current.adoc
	@echo "${PWD}"/note-current.adoc

note-publish: FRC
	[ -f note-$$(date +%Y-%m-%d).adoc ] || mv note-current.adoc note-$$(date +%Y-%m-%d).adoc

rhizome-new: FRC
	@[ -f rhizome-current.adoc ] || cp rhizome-template.adoc rhizome-current.adoc
	@echo "${PWD}"/rhizome-current.adoc

rhizome-publish: FRC
	[ -f rhizome-$$(date +%Y-W%W).adoc ] || mv rhizome-current.adoc rhizome-$$(date +%Y-W%W).adoc

FRC:
