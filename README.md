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

`httpcache` provides two ways to use its query cache. If you're writing code/a package to wrap an API, load or import the HTTP verb functions from `httpcache` instead of `httr`--no other code changes are necessary.

Alternatively, if you're using someone else's package that wraps an API, you can't just change its HTTP request function to use `httpcache`, but you can still enable caching. Call `httpcache::enable()` and then all calls to `httr::GET()` will use the query cache. 

`GET()` responses are added to the local query cache; `PUT()`, `PATCH()`, `POST()`, and `DELETE()` requests trigger cache invalidation on the associated resources. You can override that default cache invalidation, and you can command the invalidation explicitly, with the invalidation functions `dropCache()`, `dropPattern()`, and `dropOnly()`. `clearCache()` wipes the cache completely.

See `vignette("httpcache")` for examples of the HTTP cache in practice.
