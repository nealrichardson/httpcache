autocacheTracer <- quote({
    rp <- request_perform
    request_perform <- function (req, handle, refresh) {
        Call <- match.call()
        cache.is.on <- getOption("httpcache.on", FALSE)
        if (cache.is.on) {
            url <- strsplit(req$url, "?", fixed=TRUE)[[1]]
            if (length(url) > 1) {
                query <- url[2]
            } else {
                query <- NULL
            }
            ## TODO: this may be different from how httpcache::GET gets a query
            ## bc that looks to use the list() form of the query. Consider
            ## standardizing.
            cache.url <- buildCacheKey(url[1], query=query)
            cached <- getCache(cache.url)
            if (!is.null(cached)) {
                ## Hit! Return that.
                return(cached)
            }
        }
        Call[[1]] <- rp
        out <- eval(Call)
        logMessage(responseStatusLog(out))
        if (cache.is.on && out$status_code == 200) {
            setCache(cache.url, out)
        }
        return(out)
    }
})

enable <- function () {
    options(httpcache.on=TRUE)
    invisible(
        quietly(
            trace(
                "GET",
                tracer=autocacheTracer,
                print=getOption("httpcache.debug", FALSE),
                where=httr::DELETE
            )
        )
    )
}

disable <- function () {
    safe_untrace("GET", httr::DELETE)
    options(httpcache.on=FALSE)
}

quietly <- function (expr) {
    env <- parent.frame()
    if (getOption("httpcache.debug", FALSE)) {
        eval(expr, env)
    } else {
        suppressMessages(eval(expr, env))
    }
}

safe_untrace <- function (what, where) {
    ## If you attempt to untrace a function (1) that isn't exported from
    ## whatever namespace it lives in and (2) that isn't currently traced,
    ## it errors. This prevents that so that it's always safe to call `untrace`
    if (inherits(get(what, environment(where)), "functionWithTrace")) {
        quietly(untrace(what, where=where))
    }
}
