all: hugo static

hugo: static FRC
	hugo --gc --minify

open: FRC
	hugo server --openBrowser --buildDrafts --minify

deploy: hugo
	rclone sync public/ fastmail:www/somas.is/

static: static/avatar.png
static/avatar.png: FRC
	curl -Lf \
	    --remote-time \
	    --time-cond $@ \
	    -o $@ \
	    "https://www.gravatar.com/avatar/a187e38560bb56f5231cd19e45ad80f6?s=512"

static: static/favicon.png static/favicon.ico
static/favicon.png static/favicon.ico: static/avatar.png
	magick $< -interpolative-resize 32x32 $@

FRC:
