OPENRING ?= openring

openring: _includes/webring_out.html

_includes/webring_out.html:
	${OPENRING} \
	    -s https://7596ff.com/rss.xml \
	    -s https://text.causal.agency/feed.atom \
	    -s https://1.0.168.192.in-addr.xyz/blag/index.atom \
	    -s https://leahneukirchen.org/blog/index.atom \
	    -s https://leahneukirchen.org/trivium/index.atom \
	    -s https://pikhq.com/index.xml \
	    -s https://ewontfix.com/feed.rss \
	    < _includes/webring_in.html \
	    > _includes/webring_out.html

resume.pdf: resume.adoc
	asciidoctor-pdf $< -o $@
