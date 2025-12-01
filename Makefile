all: hugo static

hugo: static FRC
	hugo --gc --minify

open: FRC
	hugo server --openBrowser --buildDrafts --minify

static: static/avatar.png
static/avatar.png: FRC
	curl -Lfs --remote-time --time-cond $@ -o $@ \
	    "https://www.gravatar.com/avatar/a187e38560bb56f5231cd19e45ad80f6?s=512"

static: static/favicon.png static/favicon.ico
static/favicon.png static/favicon.ico: static/avatar.png
	magick $< -interpolative-resize 32x32 $@

static: static/doc/resume.pdf
static/doc/resume.pdf: FRC
	mkdir -p static/doc
	make -C ~/doc/resume
	cp ~/doc/resume/resume.pdf static/doc/resume.pdf

install: FRC deploy
deploy: FRC hugo
	rclone sync --update --refresh-times --progress public/ fastmail:www/somas.is/

FRC:
