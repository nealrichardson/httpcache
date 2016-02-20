## Create the cache env
cache <- NULL
initCache <- function () cache <<- new.env(hash=TRUE)
initCache()

caching <- function () isTRUE(getOption("crest.cache"))

cacheOn <- function () options(crest.cache=TRUE)
cacheOff <- function () {
    options(crest.cache=FALSE)
    clearCache()
}
clearCache <- function () {
    logMessage("CACHE CLEAR")
    rm(list=ls(all.names=TRUE, envir=cache), envir=cache)
}

no.cache <- function () {
    ## Context manager to temporarily turn cache off if it is on
    temp.option(crest.cache=FALSE)
}

## deal with query params?
dropCache <- function (x) {
    ## Drop x and anything below it in the tree
    dropPattern(paste0("^", regexEscape(popQuery(x))))
}
dropOnly <- function (x) {
    logMessage("CACHE DROP", x)
    suppressWarnings(rm(list=x, envir=cache))
}
dropBelow <- function (x) {
    ## Don't drop x, just those below it in the tree. hence ".+"
    dropPattern(paste0("^", regexEscape(popQuery(x)), ".+"))
}
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
    if (caching() && x$status_code == 200) {
        logMessage("CACHE SET", cache.url)
        assign(cache.url, x, envir=cache)
    }
    return(x)
}

##' @importFrom httr PUT
PUT <- function (url, ..., drop=dropCache(url)) {
    x <- httr::PUT(url, ...)
    force(drop)
    return(x)
}

##' @importFrom httr POST
POST <- function (url, ..., drop=dropOnly(url)) {
    x <- httr::POST(url, ...)
    force(drop)
    return(x)
}

##' @importFrom httr PATCH
PATCH <- function (url, ..., drop=dropCache(url)) {
    x <- httr::PATCH(url, ...)
    force(drop)
    return(x)
}

##' @importFrom httr DELETE
DELETE <- function (url, ..., drop=dropCache(url)) {
    x <- httr::DELETE(url, ...)
    force(drop)
    return(x)
}
