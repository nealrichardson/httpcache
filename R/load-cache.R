cache <- function() {
  cache_env <- getOption("httpcache.env")
  if (!inherits(cache_env, "environment")) {
    # No/invalid cache object; create one now
    cache_env <- new.env(hash = TRUE)
    options(httpcache.env = cache_env)
  }
  cache_env
}

#' Save and load cache state
#'
#' Warm your query cache from a previous session by saving out the cache and
#' loading it back in. `withCache()` wraps `loadCache()` and restores the
#' previous cache after evaluating the code
#' @param x for `loadCache()` and `withCache()`, either an `environment` or a
#' string path to one saved in an `.rds` file
#' @param file character file path to write the cache data to, in `.rds` format
#' @param ... code to evaluate using the cache in `x`
#' @return `withCache()` returns the value of `...`. `saveCache()` and
#' `loadCache()` return nothing.
#' @export
saveCache <- function(file) {
  saveRDS(cache(), file = file)
}

#' @rdname saveCache
#' @export
loadCache <- function(x) {
  if (is.character(x)) {
    x <- readRDS(x)
  }
  if (!is.environment(x)) {
    halt("'loadCache' requires an .rds file containing an environment")
  }
  options(httpcache.env = x)
  invisible(NULL)
}

#' @rdname saveCache
#' @export
withCache <- function(x, ...) {
  old <- getOption("httpcache.env")
  on.exit(options(httpcache.env = old))
  loadCache(x)
  eval.parent(...)
}