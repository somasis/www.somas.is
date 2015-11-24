all:	$(addsuffix .html,$(basename $(shell find -type f -name '*.md')))

clean:
	rm -f *.html

%.html:	%.md
	[[ -f "$*.temp" ]] && theme -t "$*.temp" < "$<" > "$@" || theme -t "main.temp" "$<" -o "$@"


