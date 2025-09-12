.POSIX:
.SUFFIXES:
.DELETE_ON_ERROR:

PAGES = \
    index.html \
    notes.html \
    rhizome.html \
    cv.html \
    resume.html

# newest to oldest
NOTES = \
    note-tgirl-ghosts.html \
    note-beets-lossless-and-lossy.html \
    note-2021-04-06.html \
    note-2020-12-05.html \
    note-2020-12-01.html \
    note-2020-02-11.html \
    note-2019-12-06.html \
    note-2019-11-14.html

RHIZOMES = \
    rhizome-2021-W26.html \
    rhizome-2021-W02.html \
    rhizome-2020-W47.html

ETC = \

FEEDS = \
    notes.atom \
    rhizome.atom

PDFS = \
    cv.pdf \
    resume.pdf

CSS = \
    cv.css \
    style.css

CV_DEPS = \
    cv.css \
    cv.yml \
    cv/education.adoc \
    cv/jobs.adoc \
    cv/languages.adoc \
    cv/memberships.adoc \
    cv/skills.adoc \
    cv/presentations.adoc \
    cv/volunteer.adoc

INSTALLS = ${PAGES} ${NOTES} ${RHIZOMES} ${FEEDS} ${PDFS} ${CSS} ${ETC} feed.xml

DESTDIR ?= ~/mnt/fastmail/www/somas.is

all: FRC etc pages notes rhizomes feeds pdfs

etc: FRC ${ETC}
pages: FRC ${PAGES}
notes: FRC ${NOTES} notes.atom notes.adoc
rhizomes: FRC ${RHIZOMES} rhizome.atom rhizome.adoc
feeds: FRC ${FEEDS}
pdfs: FRC ${PDFS}

GNUMAKEFLAGS = --no-print-directory
watch: FRC all Makefile
	git ls-files -z --cached --others --no-ignored --exclude-standard \
	    | rwc -0cdp \
	    | xe -0s make

rhizome.html: rhizome.adoc
rhizome.adoc: rhizome.sh ${RHIZOMES}
	./rhizome.sh ${RHIZOMES} > $@

notes.html: notes.adoc
notes.adoc: notes.sh ${NOTES}
	./notes.sh ${NOTES} > $@

notes.atom: atom.sh ${NOTES}
	./atom.sh \
	    -t '~somasis/notes' \
	    -u 'https://somas.is/notes.html' \
	    -s 'notes and other short-form writings.' \
	    ${NOTES} > $@

rhizome.atom: atom.sh ${RHIZOMES}
	./atom.sh \
	    -t '~somasis/rhizome' \
	    -u 'https://somas.is/rhizome.html' \
	    -s 'tumblelog type... thing. ' \
	    ${RHIZOMES} > $@

cv.html: $(CV_DEPS) cv.adoc cv.yml cv.css
	asciidoctor \
	    -a '!subtitle' \
	    -a stylesheet=cv.css \
	    -a linkcss \
	    -o $@ cv.adoc

cv.pdf: $(CV_DEPS) cv.adoc cv.yml
	asciidoctor-pdf \
	    -a pdf-themesdir=$(PWD) \
	    -a pdf-fontsdir=$(PWD) \
	    -a pdf-theme=cv.yml \
	    -o $@ cv.adoc

resume.html: $(CV_DEPS) resume.adoc cv.yml cv.css
	asciidoctor \
	    -a '!subtitle' \
	    -a stylesheet=cv.css \
	    -a linkcss \
	    -o $@ resume.adoc

resume.pdf: $(CV_DEPS) resume.adoc cv.yml
	asciidoctor-pdf \
	    -a pdf-themesdir=$(PWD) \
	    -a pdf-fontsdir=$(PWD) \
	    -a pdf-theme=cv.yml \
	    -o $@ resume.adoc

.SUFFIXES: .adoc .html
.adoc.html:
	./temp.sh $< > $@

redirects: FRC redirect.sh
	./redirect.sh /note-2019-11-14.html \
	    2019/11/14/transness-and-philosophy-exclusive.html \
	    blog/2019/11/14/transness-and-philosophy-exclusive.html
	./redirect.sh /note-2019-12-06.html \
	    2019/12/06/reflection-on-therapeutic-philosophy.html \
	    blog/2019/12/06/reflection-on-therapeutic-philosophy.html
	./redirect.sh /note-2020-02-11.html \
	    2020/02/11/memory-fades-but-our-words-are-forever.html \
	    blog/2020/02/11/memory-fades-but-our-words-are-forever.html
	./redirect.sh ${URL_MUSIC} music.html
	# ./redirect.sh /cv.html resume.html

install: all redirects
	#mkdir -p "${DESTDIR}"
	rsync -ru ${INSTALLS} ${DESTDIR}/

clean: FRC
	rm -f ${ETC} ${PAGES} ${NOTES} ${RHIZOMES} ${FEEDS} ${PDFS} notes.adoc rhizome.adoc

note-new: FRC
	@[ -f note-current.adoc ] || cp note-template.adoc note-current.adoc
	@echo "${PWD}"/note-current.adoc

note-publish: FRC
	@date=$$(date +%Y-%m-%d) \
	    && slug=$$(asciidoctor-query title note-current.adoc | slugify --stdin --max-length 48 --word-boundary --save-order || :) \
	    && if ! [ -e "note-$date.adoc" ]; then mv -v note-current.adoc "note-$date${slug:+-$slug}.adoc"; fi

rhizome-new: FRC
	@[ -f rhizome-current.adoc ] || cp rhizome-template.adoc rhizome-current.adoc
	@echo "${PWD}"/rhizome-current.adoc

rhizome-publish: FRC
	[ -f rhizome-$$(date +%Y-W%W).adoc ] || mv rhizome-current.adoc rhizome-$$(date +%Y-W%W).adoc

FRC:
