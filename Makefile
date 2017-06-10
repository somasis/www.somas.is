# requires discount's theme program, postcss-cli, cssnano, html-minifier, htmltidy (html5), and autoprefixer

SRCDIR          := $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
IMAGE           ?= /srv/www/www.somasis.com

USE_POSTCSS         ?= false
USE_HTML_MINIFIER   ?= false

all: $(addsuffix .html,$(basename $(shell find -type f -name '*.md')))
all: $(addsuffix .min.css,$(basename $(shell find -type f -name '*.css' -and -not -name '*.min.css')))

clean:
	find -type f -name '*.html' -delete -print
	find -type f -name '*.min.css' -delete -print
	find -type f -name '*.tmp' -delete -print

lint:
	@find -type f -name '*.md' -print0 | xargs -t0 mdl -s .mdlstyle.rb

# cssnano is ran separately because it likes to take out vendor prefixes we might still need
%.min.css: %.css
ifeq ($(USE_POSTCSS), true)
	-postcss -u cssnano "$*.css" -o "$*.css.tmp"
	-postcss -u autoprefixer "$*.css.tmp" -o "$*.min.css"
	-rm -f "$*.css.tmp"
else
	-cp "$*.css" "$*.min.css"
endif

%.html: %.md $(shell $(SRCDIR)/scripts/markdown.sh --template "$<" "$@")
	$(SRCDIR)/scripts/markdown.sh "$<" "$@"
	tidy -utf8 -language en -i -m --show-info no "$@"
ifeq ($(USE_HTML_MINIFIER), true)
	html-minifier --collapse-boolean-attributes --collapse-inline-tag-whitespace --collapse-whitespace --conservative-collapse --decode-entities --html5 --minify-css --minify-js --minify-ur-ls --process-conditional-comments --remove-attribute-quotes --remove-comments --remove-empty-attributes --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-style-link-type-attributes --sort-attributes --sort-class-name --trim-custom-fragments --use-short-doctype "$@" > "$@".tmp
	-[ -f "$@.tmp" ] && mv -f "$@".tmp "$@"
endif

watch:
	-pgrep ^devd || devd -Ll . &
	while true; do \
	    { find . -not -name '*.min.css' -and -not -name '*.tmp' -and -not -name '*.html'; } | entr sh -c '$(MAKE) $(MAKEFLAGS) lint && $(MAKE) $(MAKEFLAGS)'; \
	done

deploy: all
	rm -f $(IMAGE)/Makefile $(iMAGE)/scripts $(shell find "$(IMAGE)" -type f -name '*.css' -and -not -name '*.min.css') $(shell find "$(IMAGE)" -type f -name '*.md' -or -name '*.theme' -or -name '*.tmp')

.PHONY: all clean deploy lint watch
