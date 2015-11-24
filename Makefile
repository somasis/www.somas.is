all:	$(addsuffix .html,$(basename $(shell find -type f -name '*.md')))

clean:
	rm -f *.html *.tmp

%.html:	%.md main.temp main.css
	[[ -f "$*.temp" ]] && theme -t "$*.temp" < "$<" > "$@" || theme -t "main.temp" "$<" -o "$@"


