IMAGE?=	/srv/www/www.somasis.com

all:	$(addsuffix .html,$(basename $(shell find -type f -name '*.md')))

clean:
	rm -f *.html *.tmp

%.html:	%.md main.temp main.css
	if [[ -f "$*.temp" ]];then \
		theme -t "$*.temp" < "$<" > "$@";	\
	else	\
		theme -t "main.temp" < "$<" > "$@";	\
	fi
	tidy -q -utf8 -language en -i -m -w 0 "$@" || true

deploy: $(wildcard *.html)
	rm -rf $(IMAGE)/*.md $(IMAGE)/Makefile $(IMAGE)/*.temp $(IMAGE)/*.tmp

.PHONY:	all clean deploy
