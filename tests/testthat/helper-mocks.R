with_mock_HTTP <- function (expr) {
    with_mock(
        `httr::GET`=fakeGET,
        `httr::PUT`=fakePUT,
        `httr::PATCH`=fakePATCH,
        `httr::POST`=fakePOST,
        `httr::DELETE`=fakeDELETE,
        `downloader::download`=fakeDownload,
        eval.parent(expr)
    )
}

fakeGET <- function (url, ...) {
    ## Return something shaped enough like an httr response object for log tests
    return(list(
        status_code=200,
        times=structure(nchar(url), .Names="total"),
        request=list(method="GET", url=url),
        response=nchar(url)
    ))
}

fakePUT <- function (url, body=NULL, ...) {
    message("PUT ", url, " ", body)
    return(list(
        status_code=204,
        times=structure(nchar(url), .Names="total"),
        request=list(method="PUT", url=url)
    ))
}

fakePATCH <- function (url, body=NULL, ...) {
    message("PATCH ", url, " ", body)
    return(list(
        status_code=204,
        times=structure(nchar(url), .Names="total"),
        request=list(method="PATCH", url=url)
    ))
}

fakePOST <- function (url, body=NULL, ...) {
    message("POST ", url, " ", body)
    return(list(
        status_code=201,
        times=structure(nchar(url), .Names="total"),
        request=list(method="POST", url=url)
    ))
}

fakeDELETE <- function (url, body=NULL, ...) {
    message("DELETE ", url, " ", body)
    return(list(
        status_code=204,
        times=structure(nchar(url), .Names="total"),
        request=list(method="DELETE", url=url)
    ))
}

fakeDownload <- function (url, destfile, ...) {
    file.copy(url, destfile)
    return(0)
}

without_internet <- function (expr) {
    with_mock(
        `httr::GET`=function (url, ...) halt("GET ", url),
        `httr::PUT`=function (url, body, ...) halt("PUT ", url, " ", body),
        `httr::PATCH`=function (url, body, ...) halt("PATCH ", url, " ", body),
        `httr::POST`=function (url, body, ...) halt("POST ", url, " ", body),
        `httr::DELETE`=function (url, ...) halt("DELETE ", url),
        `downloader::download`=function (url, ...) halt("DOWNLOAD ", url),
        eval.parent(expr)
    )
}

currently_offline <- function (url="http://httpbin.org/") {
    inherits(try(uncached(GET(url)), silent=TRUE), "try-error")
}

skip_if_disconnected <- function (url="http://httpbin.org/") {
    if (currently_offline(url)) {
        skip(paste("Cannot reach", url))
    }
}
