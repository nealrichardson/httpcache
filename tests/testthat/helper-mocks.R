currently_offline <- function (url="http://httpbin.org/") {
    inherits(try(uncached(GET(url)), silent=TRUE), "try-error")
}

skip_if_disconnected <- function (url="http://httpbin.org/") {
    if (currently_offline(url)) {
        skip(paste("Cannot reach", url))
    }
}

content <- httr::content
