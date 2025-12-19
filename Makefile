all: hugo static

hugo: static FRC
	hugo --gc --minify

open: FRC
	hugo server --openBrowser --buildDrafts --minify

clean: FRC
	rm -f static/avatar.png static/favicon.png static/favicon.ico static/doc/resume.pdf

static: static/avatar.png
static/avatar.png: FRC
	curl -Lfs --remote-time --time-cond $@ -o $@ \
	    "https://www.gravatar.com/avatar/a187e38560bb56f5231cd19e45ad80f6?s=512"

static: static/favicon.png
static/favicon.png: static/avatar.png
	magick $< -interpolative-resize 32x32 $@
	optipng -o7 $@

static: static/favicon.ico
static/favicon.ico: static/favicon.png
	magick $< $@

static: static/doc/resume.pdf
static/doc/resume.pdf: FRC
	mkdir -p static/doc
	make -C ~/doc/resume
	cp ~/doc/resume/resume.pdf static/doc/resume.pdf

install: FRC deploy
deploy: FRC hugo
	rclone sync --update --refresh-times --progress public/ fastmail:www/somas.is/

FRC:
