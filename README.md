# httpcache

[![Build Status](https://travis-ci.org/nealrichardson/httpcache.png?branch=master)](https://travis-ci.org/nealrichardson/httpcache)

Query cache for HTTP clients, with tools for cache invalidation and request logging.

## Installing

`httpcache` can be installed from CRAN with

    install.packages("httpcache")

The pre-release version of the package can be pulled from GitHub using the [devtools](https://github.com/hadley/devtools) package:

    # install.packages("devtools")
    devtools::install_github("nealrichardson/httpcache", build_vignettes=TRUE)

## Getting started

## For developers

### Installing from a local checkout

    $ R --slave -e 'install.packages(c("httpcache", "codetools", "testthat"), repo="http://cran.at.r-project.org")'
    $ make test

This installs dependencies and then runs the tests, which installs `httpcache` from your local checkout in the process. If the dependencies fail to install, check the error message. You may need to install libcurl on your system before installing the R packages.

### Running tests

`$ make test` is all you need. Requires the `testthat` package for R. You can also specify a specific test file or files to run by adding a "file=" argument, like `$ make test file=auth`. `test_package` will do a regular-expression pattern match within the file names. See its documentation in the `testthat` package.

### Updating documentation

Run `$ make doc`. Requires the `roxygen2` package.
