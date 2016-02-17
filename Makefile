PROG=perl fetch_wos.pl

.PHONY: install clean timescited import

timescited: data/ut.csv
	$(PROG) --file data/ut.csv

data/ut.csv:
	catmandu -L /srv/www/pub export backup --bag publication \
	to JSON --fix export.fix | egrep 'ut|doi|pmid' \
	| catmandu convert to CSV --fields '_id,ut,pmid,doi' > data/ut.csv

import: data/wos_citations.json
	catmandu -L /srv/www/pub import JSON \
	to metrics --bag wos --fix "vacuum()" < data/wos_citations.json

install: cpanfile
	cpanm --installdeps .

clean:
	rm *.csv && rm *.log && rm data/*
