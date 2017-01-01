#' Cache the result of a file download
#'
#' This function wraps \code{\link[utils]{download.file}}. When
#' caching is enabled, \code{cachedDownload} will save a copy of the resulting
#' file to temporary storage and record that location in the query cache.
#' Subsequent download requests will just copy the cached file to the
#' destination path and not make a request across the network.
#'
#' @param url character URL to download
#' @param destfile character file path/name where the download should be saved
#' @param ... additional arguments, ultimately passed to \code{download.file}
#' @return From \code{\link[utils]{download.file}}: "An (invisible) integer
#' code, \code{0} for success and non-zero for failure.  For the \code{"wget"}
#' and \code{"curl"} methods this is the status code returned by the
#' external program.  The \code{"internal"} method can return \code{1}, but will
#' in most cases throw an error."
#' @export
#' @importFrom utils download.file
cachedDownload <- function (url, destfile, ...) {
    validateURL(url)
    if (caching()) {
        Call <- match.call(expand.dots = TRUE)
        cache.url <- buildCacheKey(url, query=eval.parent(Call$query),
            extras="DOWNLOAD")
        download.to <- getCache(cache.url)
        if (is.null(download.to)) {
            ## Fresh download. Generate tempfile to write to
            download.to <- tempfile()
        }

        if (file.exists(download.to)) {
            ## Great, we've already downloaded it, and our cached copy still
            ## exists. So we'll return success.
            ## From ?download.file: "An (invisible) integer code, 0 for
            ## success and non-zero for failure"
            exit.status <- 0
        } else {
            ## Else, download and record in cache.
            exit.status <- download.file(url, destfile=download.to, ...)
            success <- exit.status == 0
            logMessage("HTTP DOWNLOAD", url, ifelse(success, 200, 400))
            if (success) {
                setCache(cache.url, download.to)
            }
        }

        ## Requested file is definitely at `download.to` now. Copy it to the
        ## requested `destfile`
        file.copy(download.to, destfile)
        return(exit.status)
    } else {
        return(download.file(url, destfile, ...))
    }
}
