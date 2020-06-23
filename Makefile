all: build

build:
	dune build @all

test:
	build
	dune runtest

clean:
	dune clean

watch:
	dune build @all --watch

doc:
	finch -root docs_src -output docs
