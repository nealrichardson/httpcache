# httpcache: Query Cache for HTTP Clients

[![Build Status](https://travis-ci.org/nealrichardson/httpcache.png?branch=master)](https://travis-ci.org/nealrichardson/httpcache) [![codecov.io](https://codecov.io/github/nealrichardson/httpcache/coverage.svg?branch=master)](https://codecov.io/github/nealrichardson/httpcache?branch=master)

In order to improve performance for HTTP API clients, `httpcache`
provides simple tools for caching and invalidating cache. It includes the
HTTP verb functions `GET`, `PUT`, `PATCH`, `POST`, and `DELETE`, which are drop-in
replacements for those in the `httr` package. These functions are cache-aware and provide default settings
for cache invalidation suitable for RESTful APIs; the package also
enables custom cache-management strategies. Finally, `httpcache` includes
a basic logging framework to facilitate the measurement of HTTP request
time and cache performance.

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
