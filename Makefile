THEME_FLAGS?= -c links,images,smarty,html,ext,superscript,emphasis,strikethrough,toc,autolink,header,divquote,alphalist,definitionlist,dldiscount,dlextra,footnote,style,fencedcode,githubtags,urlurlencodedanchor
IMAGE?=	/srv/www/www.somasis.com

all:	$(addsuffix .html,$(basename $(shell find -type f -name '*.md')))

clean:
	rm -f *.html *.tmp

%.html:	%.md main.temp main.css
	if [[ -f "$*.temp" ]];then \
		theme $(THEME_FLAGS) -t "$*.temp" < "$<" > "$@";	\
	else	\
		theme $(THEME_FLAGS) -t "main.temp" < "$<" > "$@";	\
	fi
	tidy -q -utf8 -language en -i -m -w 0 "$@" || true

deploy: $(wildcard *.html)
	rm -rf $(IMAGE)/*.md $(IMAGE)/Makefile $(IMAGE)/*.temp $(IMAGE)/*.tmp

.PHONY:	all clean deploy
