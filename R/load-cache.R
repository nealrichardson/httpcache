## Create the cache env
cache <- NULL
initCache <- function () {
    cache <<- new.env(hash=TRUE)
}
initCache()

#' Save and load cache state
#'
#' Warm your query cache from a previous session by saving out the cache and
#' loading it back in.
#' @param file character file path to write the cache data to, in .rds format
#' @return Nothing; called for side effects.
#' @export
saveCache <- function (file) {
    saveRDS(cache, file=file)
}

#' @rdname saveCache
#' @export
loadCache <- function (file) {
    env <- readRDS(file)
    if (!is.environment(env)) {
        halt("'loadCache' requires an .rds file containing an environment")
    }
    ## Copy the values over
    for (key in ls(all.names=TRUE, envir=env)) {
        setCache(key, get(key, env))
    }
    invisible(NULL)
}
