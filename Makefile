SPEC=test/spec.txt
SPECVERSION=$(shell perl -ne 'print $$1 if /^version: *([0-9.]+)/' $(SPEC))
BENCHINP?=bench/samples/README.md
VERSION?=$(SPECVERSION)
JSMODULES=$(wildcard lib/*.js)
UGLIFYJS=node_modules/.bin/uglifyjs
LICENSETEXT="/* commonmark $(VERSION) https://github.com/commonmark/commonmark.js @license BSD3 */"

.PHONY: dingus dist test bench bench-detailed npm lint clean update-spec

lint:
	npm run lint

dist: dist/commonmark.js dist/commonmark.min.js

dist/commonmark.js: lib/index.js ${JSMODULES}
	npm run build
	(echo $(LICENSETEXT) && cat $@) > $@.tmp  && mv $@.tmp $@

dist/commonmark.min.js: dist/commonmark.js
	(echo $(LICENSETEXT) && cat $@) > $@.tmp  && mv $@.tmp $@

update-spec:
	curl 'https://raw.githubusercontent.com/jgm/CommonMark/master/spec.txt' > $(SPEC)

test: $(SPEC)
	npm test

bench:
	node bench/bench.js ${BENCHINP}

bench-detailed:
	sudo renice -10 $$$$; \
	for x in bench/samples/*.md; do echo $$x; node bench/bench.js $$x; done | \
	awk -f bench/format_benchmarks.awk

npm:
	cd js; npm publish

dingus:
	make -C dingus dingus

clean:
