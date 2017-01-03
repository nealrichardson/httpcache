# httpcache 1.0.0

New cached request functions:

* `cachedPOST` to cache results of a POST request for resources where a POST gets content and does not alter server state.
* `cachedDownload` to cache the result of `download.file`.

Functions to access the cache API:

* `hitCache` to check for the existence of a cache entry
* `getCache` to read it
* `setCache` to set a cache value
* `buildCacheKey` to construct a cache key that incorporates the request's query parameters and body.

Tools to save and restore cached queries across R sessions:

* `saveCache`
* `loadCache`

Logging improvements:

* Add content-length and all curl request timings (not just "total") to log messages.
* Trim trailing whitespace in log messages
* Fix `loadLogfile` for when reading a log with only CACHE messages

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
