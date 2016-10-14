#' Cache the result of a file download
#'
#' This function wraps \code{\link[downloader]{download}}, which itself wraps
#' \code{\link[utils]{download.file}} for cross-platform compatibility. When
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
#' and \code{"curl"} methods [which \code{\link[downloader]{download}} will
#' appropriately select for you] this is the status code returned by the
#' external program.  The \code{"internal"} method can return \code{1}, but will
#' in most cases throw an error."
#' @export
#' @importFrom downloader download
cachedDownload <- function (url, destfile, ...) {
    validateURL(url)
    cache.is.on <- caching()
    if (cache.is.on) {
        Call <- match.call(expand.dots = TRUE)
        cache.url <- paste0(url, "?DOWNLOAD")
        if (exists(cache.url, envir=cache)) {
            logMessage("CACHE HIT", cache.url)
            ## Find where we've already downloaded the file
            download.to <- get(cache.url, envir=cache)
        } else {
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
            exit.status <- download(url, destfile=download.to, ...)
            success <- exit.status == 0
            logMessage("HTTP DOWNLOAD", url, ifelse(success, 200, 400))
            if (success) {
                logMessage("CACHE SET", cache.url)
                assign(cache.url, download.to, envir=cache)
            }
        }

        ## Requested file is definitely at `download.to` now. Copy it to the
        ## requested `destfile`
        file.copy(download.to, destfile)
        return(exit.status)
    } else {
        return(download(url, destfile, ...))
    }
}
