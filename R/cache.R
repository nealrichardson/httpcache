caching <- function () {
    ## Default should be on, so if httpcache.on isn't set, return TRUE
    opt <- getOption("httpcache.on")
    return(is.null(opt) || isTRUE(opt))
}
#' Manage the HTTP cache
#'
#' These functions turn the cache on and off and clear the contents of the
#' query cache.
#' @return Nothing. Functions are run for their side effects.
#' @aliases cacheOn cacheOff clearCache
#' @name cache-management
#' @export
cacheOn <- function () options(httpcache.on=TRUE)

#' @rdname cache-management
#' @export
cacheOff <- function () {
    options(httpcache.on=FALSE)
    clearCache()
}

#' @rdname cache-management
#' @export
clearCache <- function () {
    logMessage("CACHE CLEAR")
    rm(list=cacheKeys(), envir=cache)
}

#' HTTP Cache API
#'
#' These functions provide access to what's stored in the cache.
#' @param key character, typically a URL or similar
#' @param value For `setCache`, an R object to set in the cache for `key`.
#' @return `hitCache` returns logical whether `key` exists in the
#' cache. `getCache` returns the value stored in the cache, or `NULL`
#' if there is nothing cached. `setCache` is called for its side effects.
#' @name cache-api
#' @export
hitCache <- function (key) {
    exists(key, envir=cache)
}

#' @rdname cache-api
#' @export
getCache <- function (key) {
    if (hitCache(key)) {
        logMessage("CACHE HIT", key)
        return(get(key, envir=cache))
    } else {
        return(NULL)
    }
}

#' @rdname cache-api
#' @export
setCache <- function (key, value) {
    logMessage("CACHE SET", key)
    assign(key, value, envir=cache)
}

cacheKeys <- function () ls(all.names=TRUE, envir=cache)

#' Construct a unique cache key for a request
#'
#' This function encapsulates the logic of making a cache key, allowing other
#' code or libraries to access the HTTP cache programatically.
#'
#' @param url character request URL
#' @param query Optional query parameters for the request
#' @param body Optional request body
#' @param extras character Optional additional annotations to include in the
#' cache key.
#' @return Character value, starting with \code{url} and including hashed query
#' and body values if provided, to be used as the cache key for this request.
#' @export
buildCacheKey <- function (url, query=NULL, body=NULL, extras=c()) {
    if (!is.null(query)) {
        extras <- c(extras, paste0("QUERY=", digest(query)))
    }
    if (!is.null(body)) {
        extras <- c(extras, paste0("BODY=", digest(body)))
    }
    if (length(extras)) {
        url <- paste(url, paste0(extras, collapse="&"), sep="?")
    }
    return(url)
}

#' Context manager to temporarily turn cache off if it is on
#'
#' If you don't want to store the response of a GET request in the cache,
#' wrap it in `uncached()`. It will neither read from nor write to cache.
#'
#' `uncached` will not invalidate cache records, if present. It only ignores
#' them.
#'
#' @param ... Things to evaluate with caching off
#' @return Whatever ... returns.
#' @examples
#' uncached(GET("http://httpbin.org/get"))
#' @export
uncached <- function (...) {
    old <- getOption("httpcache.on")
    on.exit(options(httpcache.on=old))
    options(httpcache.on=FALSE)
    eval.parent(...)
}

#' Invalidate cache
#'
#' These functions let you control cache invalidation. `dropOnly`
#' invalidates cache only for the specified URL. `dropPattern` uses
#' regular expression matching to invalidate cache. `dropCache` is a
#' convenience wrapper around `dropPattern` that invalidates cache for
#' any resources that start with the given URL.
#' @param x character URL or regular expression
#' @return Nothing. Functions are run for their side effects.
#' @export
dropCache <- function (x) {
    ## Drop x and anything below it in the tree
    dropPattern(paste0("^", regexEscape(popQuery(x))))
}

#' @rdname dropCache
#' @export
dropOnly <- function (x) {
    logMessage("CACHE DROP", x)
    suppressWarnings(rm(list=x, envir=cache))
}

#' @rdname dropCache
#' @export
dropPattern <- function (x) {
    logMessage("CACHE DROP", x)
    rm(list=ls(envir=cache, pattern=x), envir=cache)
}

# dropBelow <- function (x) {
#     ## Don't drop x, just those below it in the tree. hence ".+"
#     dropPattern(paste0("^", regexEscape(popQuery(x)), ".+"))
# }

regexEscape <- function (x) {
    ## Escape all reserved characters that are valid URL chars with \\
    for (i in unlist(strsplit(".+?*", ""))) {
        x <- gsub(paste0("(\\", i, ")"), "[\\1]", x)
    }
    return(x)
}

popQuery <- function (x) {
    ## Remove query parameters from a URL
    return(sub("\\?.*$", "", x))
}
