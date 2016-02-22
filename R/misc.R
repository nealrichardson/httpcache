##' Stop, log, and no call
##'
##' Wrapper around \code{stop} that logs the error message and then stops
##' with call.=FALSE by default.
##' @param ... arguments passed to \code{stop}
##' @param call. logical: print the call? Default is \code{FALSE}, unlike
##' \code{stop}
##' @return Nothing. Raises an error.
##' @export
halt <- function (..., call.=FALSE) {
    msg <- gsub("\n", " ", ..1)
    logMessage("ERROR", msg)
    stop(..., call.=call.)
}

## Borrowed from Hadley
"%||%" <- function (a, b) if (!is.null(a)) a else b
