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

uncached <- function (...) {
    ## Context manager to temporarily turn cache off if it is on
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

## TODO: write this
regexEscape <- function (x) {
    ## Escape all reserved characters with \\
    return(x)
}

popQuery <- function (x) {
    ## Remove query parameters from a URL
    return(sub(".*(\\?.*)$", "", x))
}

##' @importFrom httr GET
##' @importFrom digest digest
GET <- function (url, ...) {
    # Always check cache. Just don't write to cache if cache is off

    Call <- match.call(expand.dots = TRUE)
    cache.url <- url
    if (!is.null(Call[["query"]])) {
        cache.url <- paste0(url, "?HASHED_QUERY=",
            digest(eval.parent(Call$query)))
    }
    if (exists(cache.url, envir=cache)) {
        logMessage("CACHE HIT", cache.url)
        return(get(cache.url, envir=cache))
    }
    x <- httr::GET(url, ...)
    logMessage(responseStatusLog(x))
    if (caching() && x$status_code == 200) {
        logMessage("CACHE SET", cache.url)
        assign(cache.url, x, envir=cache)
    }
    return(x)
}

##' @importFrom httr PUT
PUT <- function (url, ..., drop=dropCache(url)) {
    x <- httr::PUT(url, ...)
    logMessage(responseStatusLog(x))
    force(drop)
    return(x)
}

##' @importFrom httr POST
POST <- function (url, ..., drop=dropOnly(url)) {
    x <- httr::POST(url, ...)
    logMessage(responseStatusLog(x))
    force(drop)
    return(x)
}

##' @importFrom httr PATCH
PATCH <- function (url, ..., drop=dropCache(url)) {
    x <- httr::PATCH(url, ...)
    logMessage(responseStatusLog(x))
    force(drop)
    return(x)
}

##' @importFrom httr DELETE
DELETE <- function (url, ..., drop=dropCache(url)) {
    x <- httr::DELETE(url, ...)
    logMessage(responseStatusLog(x))
    force(drop)
    return(x)
}

responseStatusLog <- function (response) {
    req <- response$request
    return(paste("HTTP",
        req$method,
        req$url,
        response$status_code,
        response$times["total"]))
}
