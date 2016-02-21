halt <- function (...) {
    msg <- gsub("\n", " ", ..1)
    logMessage("ERROR", msg)
    stop(..., call.=FALSE)
}

## Borrowed from Hadley
"%||%" <- function (a, b) if (!is.null(a)) a else b
