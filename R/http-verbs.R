#' Cache-aware versions of httr verbs
#'
#' These functions set, read from, and bust the HTTP query cache. They wrap
#' the similarly named functions in the httr package and can be used as
#' drop-in replacements for them.
#'
#' `GET` checks the cache before making an HTTP request, and if there is a cache
#' miss, it sets the response from the request into the cache for future
#' requests. The other verbs, assuming a more or less RESTful API, would be
#' assumed to modify server state, and thus they should trigger cache
#' invalidation. They have default cache-invalidation strategies, but you can
#' override them as desired.
#'
#' @param url character URL of the request
#' @param ... additional arguments passed to the httr functions
#' @param drop For `PUT`, `PATCH`, `POST`, and `DELETE`,
#' code to be executed after the request. This is intended to be for supplying
#' cache-invalidation logic. By default, `POST` drops cache only for
#' the specified `url` (i.e. [dropOnly()]), while the other
#' verbs drop cache for the request URL and for any URLs nested below it
#' (i.e. [dropCache()]).
#' @return The corresponding httr response object, potentially read from cache
#' @importFrom httr GET
#' @importFrom digest digest
#' @aliases GET PUT POST PATCH DELETE
#' @name cached-http-verbs
#' @seealso [dropCache()] [cachedPOST()] [cachedDownload()]
#' @export
GET <- function (url, ...) {
    validateURL(url)

    cache.is.on <- caching()
    if (cache.is.on) {
        Call <- match.call(expand.dots = TRUE)
        cache.url <- buildCacheKey(url, query=eval.parent(Call$query))
        cached <- getCache(cache.url)
        if (!is.null(cached)) {
            ## Hit! Return that.
            return(cached)
        }
    }
    x <- httr::GET(url, ...)
    logMessage(responseStatusLog(x))
    if (cache.is.on && x$status_code == 200) {
        setCache(cache.url, x)
    }
    return(x)
}

#' @rdname cached-http-verbs
#' @export
#' @importFrom httr PUT
PUT <- function (url, ..., drop=dropCache(url)) {
    x <- httr::PUT(url, ...)
    logMessage(responseStatusLog(x))
    force(drop)
    return(x)
}

#' @rdname cached-http-verbs
#' @export
#' @importFrom httr POST
POST <- function (url, ..., drop=dropOnly(url)) {
    x <- httr::POST(url, ...)
    logMessage(responseStatusLog(x))
    force(drop)
    return(x)
}

#' Cache the response of a POST
#'
#' Some APIs have resources where a POST is used to send a command that returns
#' content and doesn't modify state. In this case, it's more like a GET. This
#' may occur where one might normally GET but the request URI would be too long
#' for the server to accept. `cachedPOST` thus behaves more like
#' `GET`, checking for a cached response before performing the request and
#' setting cache if the request is successful. It does no cache dropping, unlike
#' [httpcache::POST()].
#' @param url character URL of the request
#' @param ... additional arguments passed to the httr functions
#' @return The corresponding httr response object, potentially read from cache
#' @export
cachedPOST <- function (url, ...) {
    validateURL(url)

    cache.is.on <- caching()
    if (cache.is.on) {
        Call <- match.call(expand.dots = TRUE)
        cache.url <- buildCacheKey(url, body=eval.parent(Call$body), extras="POST")
        cached <- getCache(cache.url)
        if (!is.null(cached)) {
            ## Hit! Return that.
            return(cached)
        }
    }
    x <- httr::POST(url, ...)
    logMessage(responseStatusLog(x))
    if (cache.is.on && x$status_code < 400) {
        ## Cache any non-error response
        setCache(cache.url, x)
    }
    return(x)
}

#' @rdname cached-http-verbs
#' @export
#' @importFrom httr PATCH
PATCH <- function (url, ..., drop=dropCache(url)) {
    x <- httr::PATCH(url, ...)
    logMessage(responseStatusLog(x))
    force(drop)
    return(x)
}

#' @rdname cached-http-verbs
#' @export
#' @importFrom httr DELETE
DELETE <- function (url, ..., drop=dropCache(url)) {
    x <- httr::DELETE(url, ...)
    logMessage(responseStatusLog(x))
    force(drop)
    return(x)
}

validateURL <- function (url) {
    ## Make sure it's a string. Give a useful error if not.
    if (!is.character(url)) {
        ## Basic input validation
        stop("Invalid URL: ", deparse(url, control=NULL)[1])
    }
}
