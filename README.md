# httpcache: Query Cache for HTTP Clients

[![Build Status](https://travis-ci.org/nealrichardson/httpcache.png?branch=master)](https://travis-ci.org/nealrichardson/httpcache) [![codecov.io](https://codecov.io/github/nealrichardson/httpcache/coverage.svg?branch=master)](https://codecov.io/github/nealrichardson/httpcache?branch=master) [![Build status](https://ci.appveyor.com/api/projects/status/twvekbpe3x2tk2g5?svg=true)](https://ci.appveyor.com/project/nealrichardson/httpcache) [![cran](https://www.r-pkg.org/badges/version-last-release/httpcache)](https://cran.r-project.org/package=httpcache)

In order to improve performance for HTTP API clients, `httpcache`
provides simple tools for caching and invalidating cache. It includes the
HTTP verb functions `GET`, `PUT`, `PATCH`, `POST`, and `DELETE`, which are drop-in
replacements for those in the [httr](http://httr.r-lib.org) package.
These functions are cache-aware and provide default settings
for cache invalidation suitable for RESTful APIs; the package also
enables custom cache-management strategies. Finally, `httpcache` includes
a basic logging framework to facilitate the measurement of HTTP request
time and cache performance.

## Installing

`httpcache` can be installed from CRAN with

    install.packages("httpcache")

The pre-release version of the package can be pulled from GitHub using the [devtools](https://github.com/r-lib/devtools) package:

    # install.packages("devtools")
    devtools::install_github("nealrichardson/httpcache")

## Getting started

Working with `httpcache` is as simple as loading the package in your interactive session or script instead of `httr`, or, in package development, importing the HTTP verb functions from `httpcache`. `GET()` responses are added to the local query cache; `PUT()`, `PATCH()`, `POST()`, and `DELETE()` requests trigger cache invalidation on the associated resources. You can override that default cache invalidation, and you can command the invalidation explicitly, with the invalidation functions `dropCache()`, `dropPattern()`, and `dropOnly()`. `clearCache()` wipes the cache completely.

See `vignette("httpcache")` for examples of the HTTP cache in practice.

## For developers

The repository includes a Makefile to facilitate some common tasks.

### Running tests

`$ make test`. Requires the [httptest](https://enpiar.com/r/httptest/) package. You can also specify a specific test file or files to run by adding a "file=" argument, like `$ make test file=logging`. `test_package` will do a regular-expression pattern match within the file names. See its documentation in the [testthat](http://testthat.r-lib.org) package.

### Updating documentation

`$ make doc`. Requires the [roxygen2](https://github.com/klutometis/roxygen) package.
