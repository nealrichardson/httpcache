## Create the cache env
cache <- NULL
initCache <- function () {
    cache <<- new.env(hash=TRUE)
}
initCache()

caching <- function () isTRUE(getOption("httpcache.on"))

cacheOn <- function () options(httpcache.on=TRUE)
cacheOff <- function () {
    options(httpcache.on=FALSE)
    clearCache()
}
clearCache <- function () {
    logMessage("CACHE CLEAR")
    rm(list=ls(all.names=TRUE, envir=cache), envir=cache)
}

##' Context manager to temporarily turn cache off if it is on
##'
##' If you don't want to store the response of a GET request in the cache,
##' wrap it in \code{uncached()}. Note that if the response is already found
##' in the cache, as from a previous request that was not uncached, you will
##' get the cached response. That is, this function prevents writing to cache,
##' but it does not prevent reading from cache.
##'
##' @param ... Things to evaluate with caching off
##' @return Whatever ... returns.
##' @examples
##' uncached(GET("http://httpbin.org/get"))
##' @export
uncached <- function (...) {
    old <- getOption("httpcache.on")
    on.exit(options(httpcache.on=old))
    options(httpcache.on=FALSE)
    eval.parent(...)
}

## deal with query params differently?
dropCache <- function (x) {
    ## Drop x and anything below it in the tree
    dropPattern(paste0("^", regexEscape(popQuery(x))))
}
dropOnly <- function (x) {
    logMessage("CACHE DROP", x)
    suppressWarnings(rm(list=x, envir=cache))
}
# dropBelow <- function (x) {
#     ## Don't drop x, just those below it in the tree. hence ".+"
#     dropPattern(paste0("^", regexEscape(popQuery(x)), ".+"))
# }
dropPattern <- function (x, escape=TRUE) {
    logMessage("CACHE DROP", x)
    rm(list=ls(envir=cache, pattern=x), envir=cache)
}

## TODO: write this?
regexEscape <- function (x) {
    ## Escape all reserved characters with \\
    return(x)
}

popQuery <- function (x) {
    ## Remove query parameters from a URL
    return(sub(".*(\\?.*)$", "", x))
}
