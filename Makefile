IMAGE=/srv/www/www.somasis.com

all:	$(addsuffix .html,$(basename $(shell find -type f -name '*.md')))

clean:
	rm -f *.html *.tmp

%.html:	%.md main.temp main.css
	[[ -f "$*.temp" ]] && theme -t "$*.temp" < "$<" > "$@" || theme -t "main.temp" "$<" -o "$@"
	tidy5 "$@" > "$@".tmp
	mv "$@".tmp "$@"

deploy: *.html
	rm -f $(IMAGE)/*.md $(IMAGE)/Makefile $(IMAGE)/*.temp $(IMAGE)/*.tmp
