Oil
===

[![Build
Status](https://travis-ci.org/oilshell/oil.svg)](https://travis-ci.org/oilshell/oil)

Oil is a new Unix shell.  It's our upgrade path from bash!  ([Why
Create a New Unix Shell?][why] / [2019 FAQ][faq])

[why]: https://www.oilshell.org/blog/2018/01/28.html
[faq]: https://www.oilshell.org/blog/2019/06/17.html

To try it, follow the instructions below, and run `bin/osh` or `bin/oil`.

It's written in Python, but we deploy a native executable by including a subset
of the `Python-2.7.13/` dir the tarball.

Quick Start for Developers on Linux
-----------------------------------

Clone the repo, build the Python extension, and run `bin/osh`:

    bash$ build/dev.sh minimal
    ...
    # Now you should have a libc.so symlink in the repository root directory

    bash$ bin/osh
    osh$ name=world
    osh$ echo "hello $name"
    hello world

Most shell scripts should run, e.g. with `bin/osh myscript.sh`.

This is called the **developer build**, and is **very different** from the
release tarball.  See [Contributing][] for details.

The release tarballs are linked from the [home
page](https://www.oilshell.org/).  (This is the only way to try OSH on OS X.
Developer builds don't work on OS X.)

Running `bin/oil` will let you try the Oil language.  Send me feedback about
it!

Contributing
------------

If you'd like to contribute, please post a message on the `#oil-dev` channel of
[oilshell.zulipchat.com][].  Let us know what you're thinking, or let us know
if you're having problems getting started.

Make sure to check out the [Contributing][] page.  Let us know if anything
doesn't work.

[The blog][blog] has updates on the project status.

[Contributing]: https://github.com/oilshell/oil/wiki/Contributing
[oilshell.zulipchat.com]: https://oilshell.zulipchat.com/
[blog]: http://www.oilshell.org/blog/

Developer Docs
--------------

The [Wiki](https://github.com/oilshell/oil/wiki) has many developoer docs in
semi-organized state.  There are also READMEs in some subdirs, like `opy/`
and `mycpp/`.

If you're confused, the best thing to do is to ask on Zulip and someone
should produce a pointer and/or improve the docs.

Code Overview
-------------

Try this to show a summary of what's in the repo and their line counts:

    $ metrics/source-code.sh all

(Other functions in this file may be useful as well.)

Directory Structure
-------------------

    # Development Scripts

    benchmarks/       # Benchmarks should be run on multiple machines.
    metrics/          # Metrics don't change between machines (e.g. code size)
    build/            # Build automation
      oil-defs/       # Files that define our slice of CPython.
      dev.sh          # For development builds, running CPython
    devtools/         # For Oil developers (not end users)
      release.sh      # Documents the release process.
    misc/             # Other development scripts
    demo/             # Demonstrations of bash/shell features.  Could be
                      # moved to tests/ if automated.
    web/              # HTML/JS/CSS for tests and tools

    # Tests

    test/             # Test automation
      unit.sh         ## Types of test runner: unit, spec, wild, smoke
      spec.sh
      wild.sh
      smoke.sh
      sh_spec.py      # shell spec test framework
    testdata/
    gold/             # Gold Test cases.
    spec/             # spec test cases
      bin/            # tools used in many spec tests
      testdata/       # scripts for specific test cases
      errors/         # TODO: migrate these bad shell scripts
    types/            # Scripts for running MyPy and PyAnnotate, etc.

    # DSLs / Code Generators

    asdl/             # ASDL implementation, derived from CPython
    pgen2/            # Parser Generator, borrowed from CPython
    mycpp/            # Experimental translator from typed Python to C++.
                      # Depends on MyPy.
    opy/              # Python compiler in Python
      lib/            # Common code
      compiler2/      # Bytecode compiler
      byterun/        # Metacircular bytecode VM in Python
      gold/           # tests
      byterun/        # Unused bytecode interpreter

    # Oil Code

    Python-2.7.13/    # CPython is the initial basis for the Oil VM
    bin/              # Programs to run (bin/osh)
    core/             # Most of the Oil and OSH implementation.
    cpp/              # C++ code which complements the mycpp translation
    native/           # Python extension modules, e.g. libc.c
    frontend/         # Lexing/Parsing code common to Oil and OSH.
    oil_lang/         # Oil parser and evaluator.
    osh/              # OSH parser and evaluator.
    pylib/            # Borrowed from the Python standard library.
    tools/            # User-facing tools, e.g. the osh2oil translator

    # Temporary Directories

    _bin/             # Native executables are put here
    _build/           # Temporary build files
    _devbuild/        # Developer build files not deleted upon 'make clean'
      gen/            # Generated Python and C code
    _deps/            # build dependencies like re2c
    _tmp/             # Test suites and other temp files
      spec/
      wild/
        raw/
        www/
      osh-parser/
      osh-runtime/
      vm-baseline/
      oheap/
      startup/
      ...
    _release/         # Source release tarballs are put here
      VERSION/        # Published at oilshell.org/release/$VERSION/
        benchmarks/
        doc/
        metrics/
        test/
          spec.wwz
          wild.wwz
          ...
        web/          # Static files, copy of $REPO_ROOT/web
          table/

    # Docs
    doc/              # A mix of docs
    README.md         # For Oil developers

    LICENSE.txt       # For end users
    INSTALL.txt

    # End user build system

    Makefile
    configure
    install

Unit tests are named `foo_test.py` and live next to `foo.py`.

More info
---------

Right now we're using
[/r/oilshell on Reddit](https://www.reddit.com/r/oilshell/) for general discussion.


I have docs that need to be cleaned up and published.  For now, there is a fair
amount of design information on
the [blog at oilshell.org](http://www.oilshell.org/blog/).

