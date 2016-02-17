PROG=perl fetch_wos.pl

.PHONY: install clean timescited

timescited: ut.csv
	$(PROG) --initial_file ut.csv

ut.csv:
	catmandu -L /srv/www/pub export backup --bag publication \
	to JSON --fix export.fix | egrep 'ut|doi|pmid' \
	| catmandu convert to CSV --fields '_id,ut,pmid,doi' > ut.csv

install:
	cpanm --installdeps .

clean:
	rm *.csv && rm *.log
