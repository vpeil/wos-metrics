PROG=perl fetch_wos.pl

.PHONY: install clean timescited import

timescited: data/ut.csv
	$(PROG) --file data/ut.csv

data/ut.csv:
    mkdir -p data
	catmandu -L /srv/www/pub export backup --bag publication \
	to JSON --fix export.fix | egrep 'ut|doi|pmid' \
	| catmandu convert JSON to CSV --fields '_id,ut,pmid,doi' > data/ut.csv

import: data/wos_citations.json
	catmandu -L /srv/www/pub import JSON \
	to metrics --bag wos --fix "vacuum()" < data/wos_citations.json

export_cebitec:
    catmandu convert JSON to JSON --fix "select all_match(times_cited,'\d+'); vaccum()" \
    --array 1 < data/wos_citations.json > /home/bup/wos_cebitec/times_cited.json

install: cpanfile
	cpanm --installdeps .

clean:
	rm *.csv && rm *.log && rm data/*
