##' Log a message
##'
##' @param ... Strings to pass to \code{cat}
##' @return Nothing
##' @export
logMessage <- function (...) {
    logfile <- getOption("querycache.log")
    if (!is.null(logfile)) {
        cat(strftime(Sys.time(), "%Y-%m-%dT%H:%M:%S"), ..., "\n", file=logfile, append=TRUE)
    }
}

##' Enable logging
##'
##' @param filename character: a filename/path where the log can be written out.
##' If \code{""}, messages will print to stdout (the screen). See
##' \code{\link[base]{cat}}.
##' @param append logical: if the file already exists, append to it? Default
##' is \code{FALSE}, and if not in append mode, if the \code{filename} exists,
##' it will be deleted.
##' @return Nothing.
##' @export
startLog <- function (filename, append=FALSE) {
    options(querycache.log=filename)
    if (!append && file.exists(filename)) {
        file.remove(filename)
    }
}

##' @importFrom utils read.delim
loadLogfile <- function (filename, scope=c("CACHE", "HTTP", "BLOCK")) {
    df <- read.delim(filename, sep=" ", header=FALSE,
        stringsAsFactors=FALSE)[,1:6]
    names(df) <- c("timestamp", "scope", "verb", "url", "status", "time")
    df <- df[df$scope %in% scope,] ## Prune the errors and other crap
    df$timestamp <- strptime(df$timestamp, "%Y-%m-%dT%H:%M:%S")
    # df[c("scope", "verb")] <- lapply(df[c("scope", "verb")], as.factor)
    df[c("status", "time")] <- lapply(df[c("status", "time")], as.numeric)
    return(df)
}

cacheLogSummary <- function (logdf) {
    df <- logdf[logdf$scope == "CACHE",]
    counts <- table(df$verb)
    return(list(counts=counts,
        hit.rate=100*counts["HIT"]/sum(counts[c("HIT", "SET")])))
}

##' @importFrom utils head tail
requestLogSummary <- function (logdf) {
    total.time <- as.numeric(difftime(tail(logdf$timestamp, 1),
        head(logdf$timestamp, 1), units="secs"))
    df <- requestsFromLog(logdf)
    counts <- table(df$verb)
    req.time <- sum(df$time, na.rm=TRUE)
    pct.http.time <- 100*req.time/total.time
    return(list(counts=counts, req.time=req.time, total.time=total.time,
        pct.http.time=pct.http.time))
}

requestsFromLog <- function (logdf) {
    ## Remove cache hits from the GET logs. They're the next record
    hits <- which(logdf$verb == "HIT")
    ## If there are hits, drop the requests that are returned from cache
    if (length(hits)) {
        drophits <- intersect(hits + 1, which(logdf$verb == "GET"))
        logdf <- logdf[-drophits,]
    }
    df <- logdf[logdf$scope == "HTTP",]
    return(df)
}
