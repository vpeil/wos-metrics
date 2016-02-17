# wos-metrics

A small project to fetch *Times Cited* information from Web of Science

## Installation

Make sure all the dependencies are installed:

```bash
$ cpanm --installdeps .

# or equivalently

$ make install
```

## Usage

You need a file `data/ut.csv` which looks like
```csv
_id,ut,pmid,doi
1,000234329432,2345678,10.1103/PhysRevLett.104.121102
2,324230000983,87654321,10.1016/j.jedc.2009.09.007
3,000230293002,98765433,10.5194/acp-8-5221-2008
```

Run the following command via Makefile

(if make is not available on your system then run the commands defined in `Makefile`)

```bash
$ make

# or equivalently

$ make timescited
```
to fetch the data from the Web of Science.

Import the data in some database
```bash
$ make import
```

and clean up you directory, please:
```bash
$ make clean
```
