### httpcache 0.1.8
* Include milliseconds in timestamps

### httpcache 0.1.6
* Improve error message for when a non-character input is given to `GET`

### httpcache 0.1.4

* Ensure that caching is on by default
* Change `GET` not to check cache if an uncached request is made. Previously, `uncached` checked cache but did not write to the cache.
* Fix regular expression matching in popQuery
* Improve escaping of characters in URLs for dropping cache by pattern
* Add vignette

### httpcache 0.1.2

* Revise and resubmit to CRAN

## httpcache 0.1.0

* Extract code and tests from `crunch` package
* Document and export functions for caching, invalidating, and logging
