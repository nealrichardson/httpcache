#' Log a message
#'
#' @param ... Strings to pass to [base::cat()]
#' @return Nothing
#' @export
logMessage <- function (...) {
    logfile <- getOption("httpcache.log")
    if (!is.null(logfile)) {
        msg <- paste(strftime(Sys.time(), "%Y-%m-%dT%H:%M:%OS3"), ...)
        cat(msg, "\n", sep="", file=logfile, append=TRUE)
    }
}

responseStatusLog <- function (response) {
    ## Log message content for a HTTP response
    req <- response$request
    return(paste("HTTP",
        req$method,
        req$url,
        response$status_code,
        response$headers[["content-length"]] %||% "NA",
        paste(round(response$times, 3), collapse=" ")))
}

#' Stop, log, and no call
#'
#' Wrapper around [base::stop()] that logs the error message and then stops
#' with call.=FALSE by default.
#' @param ... arguments passed to `stop`
#' @param call. logical: print the call? Default is `FALSE`, unlike `stop`
#' @return Nothing. Raises an error.
#' @export
halt <- function (..., call.=FALSE) {
    msg <- gsub("\n", " ", ..1)
    logMessage("ERROR", msg)
    stop(..., call.=call.)
}

#' Enable logging
#'
#' @param filename character: a filename/path where the log can be written out.
#' If `""`, messages will print to stdout (the screen). See [base::cat()].
#' @param append logical: if the file already exists, append to it? Default
#' is `FALSE`, and if not in append mode, if the `filename` exists,
#' it will be deleted.
#' @return Nothing.
#' @export
startLog <- function (filename="", append=FALSE) {
    options(httpcache.log=filename)
    if (!append && nchar(filename) && file.exists(filename)) {
        file.remove(filename)
    }
}

#' Read in a httpcache log file
#'
#' @param filename character name of the log file, passed to
#' [utils::read.delim()]
#' @param scope character optional means of selecting only certain log
#' messages. By default, only "CACHE" and "HTTP" log messages are kept. Other
#' logged messages, such as "ERROR" messages from [halt()], will be
#' dropped from the resulting data.frame.
#' @return A data.frame of log results.
#' @export
#' @importFrom utils read.delim
loadLogfile <- function (filename, scope=c("CACHE", "HTTP")) {
    df <- read.delim(filename, sep=" ", header=FALSE, stringsAsFactors=FALSE)

    numeric.cols <- c("status", "content_length", "redirect", "namelookup",
        "connect", "pretransfer", "starttransfer", "total")
    all.cols <- c("timestamp", "scope", "verb", "url", numeric.cols)
    ## Don't let long error message lines distort our data.frame
    ## But don't let a log that is only cache hits (and thus no status and
    ## timing entries) break for being too short
    dfcols <- 1:min(ncol(df), length(all.cols))
    df <- df[,dfcols]
    names(df) <- all.cols[dfcols]
    df <- df[df$scope %in% scope,] ## Prune out-of-scope things
    df$timestamp <- strptime(df$timestamp, "%Y-%m-%dT%H:%M:%OS")
    numerics <- intersect(c("status", numeric.cols), names(df))
    df[numerics] <- lapply(df[numerics], as.numeric)
    return(df)
}

#' Summarize cache performance from a log
#'
#' @param logdf A logging data.frame, as loaded by [loadLogfile()].
#' @return A list containing counts of cache hit/set/drop events, plus a
#' cache hit rate.
#' @export
cacheLogSummary <- function (logdf) {
    df <- logdf[logdf$scope == "CACHE",]
    counts <- table(df$verb)
    return(list(counts=counts,
        hit.rate=100*counts["HIT"]/sum(counts[c("HIT", "SET")])))
}

#' Summarize HTTP requests from a log
#'
#' @param logdf A logging data.frame, as loaded by [loadLogfile()].
#' @return A list containing counts of HTTP requests by verb, as well as
#' summaries of time spent waiting on HTTP requests.
#' @export
#' @importFrom utils head tail
requestLogSummary <- function (logdf) {
    total.time <- as.numeric(difftime(tail(logdf$timestamp, 1),
        head(logdf$timestamp, 1), units="secs"))
    df <- logdf[logdf$scope == "HTTP",]
    counts <- table(df$verb)
    req.time <- sum(df$total, na.rm=TRUE)
    pct.http.time <- 100*req.time/total.time
    return(list(counts=counts, req.time=req.time, total.time=total.time,
        pct.http.time=pct.http.time))
}

## Borrowed from Hadley
"%||%" <- function (a, b) if (!is.null(a)) a else b
