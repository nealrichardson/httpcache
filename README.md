# httpcache

[![Build Status](https://travis-ci.org/nealrichardson/httpcache.png?branch=master)](https://travis-ci.org/nealrichardson/httpcache) [![codecov.io](https://codecov.io/github/nealrichardson/httpcache/coverage.svg?branch=master)](https://codecov.io/github/nealrichardson/httpcache?branch=master)

Query cache for HTTP clients, with tools for cache invalidation and request logging.

## Installing

`httpcache` is not yet on CRAN. But when it is, it can be installed from CRAN with

    install.packages("httpcache")

The pre-release version of the package can be pulled from GitHub using the [devtools](https://github.com/hadley/devtools) package:

    # install.packages("devtools")
    devtools::install_github("nealrichardson/httpcache", build_vignettes=TRUE)

## Getting started



## For developers

The repository includes a Makefile to facilitate some common tasks.

### Running tests

`$ make test`. Requires the `testthat` package. You can also specify a specific test file or files to run by adding a "file=" argument, like `$ make test file=logging`. `test_package` will do a regular-expression pattern match within the file names. See its documentation in the `testthat` package.

### Updating documentation

`$ make doc`. Requires the `roxygen2` package.
