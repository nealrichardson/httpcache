with_mock_HTTP <- function (expr) {
    with_mock(
        `httr::GET`=fakeGET,
        `httr::PUT`=fakePUT,
        `httr::PATCH`=fakePATCH,
        `httr::POST`=fakePOST,
        `httr::DELETE`=fakeDELETE,
        `utils::download.file`=fakeDownload,
        eval.parent(expr)
    )
}

without_internet <- function (expr) {
    with_mock(
        `httr::GET`=function (url, ...) halt("GET ", url),
        `httr::PUT`=function (url, body=NULL, ...) halt("PUT ", url, " ", body),
        `httr::PATCH`=function (url, body=NULL, ...) halt("PATCH ", url, " ", body),
        `httr::POST`=function (url, body=NULL, ...) halt("POST ", url, " ", body),
        `httr::DELETE`=function (url, ...) halt("DELETE ", url),
        `utils::download.file`=function (url, ...) halt("DOWNLOAD ", url),
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

content <- httr::content
