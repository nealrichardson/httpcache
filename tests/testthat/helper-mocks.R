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

fakeResponse <- function (url="", verb="GET", status_code=200, headers=list(), content=NULL) {
    ## Return something that looks enough like an httr 'response'
    base.headers <- list()
    if (is.null(content)) {
        if (status_code != 204) {
            ## Echo back the URL as the content
            content <- url
            base.headers <- list(`Content-Type`="text/plain")
        }
    } else {
        ## We have content supplied, so JSON it
        content <- jsonlite::toJSON(content, auto_unbox=TRUE, null="null",
            na="null", force=TRUE)
        base.headers <- list(`Content-Type`="application/json")
    }
    if (!is.null(content)) {
        base.headers[["content-length"]] <- nchar(content)
        content <- charToRaw(content)
    }

    structure(list(
        url=url,
        status_code=status_code,
        times=structure(c(rep(0, 5), nchar(url)),
            .Names=c("redirect", "namelookup", "connect", "pretransfer",
                    "starttransfer", "total")),
        request=list(method=verb, url=url),
        headers=modifyList(base.headers, headers),
        content=content
    ), class="response")
}

fakeGET <- function (url, query=NULL, ...) {
    fakeResponse(url, content=query)
}

fakePUT <- function (url, body=NULL, ...) {
    message("PUT ", url, " ", body)
    return(fakeResponse(url, verb="PUT", status_code=204))
}

fakePATCH <- function (url, body=NULL, ...) {
    message("PATCH ", url, " ", body)
    return(fakeResponse(url, verb="PATCH", status_code=204))
}

fakePOST <- function (url, body=NULL, ...) {
    message("POST ", url, " ", body)
    return(fakeResponse(url, verb="POST", status_code=201, content=body))
}

fakeDELETE <- function (url, body=NULL, ...) {
    message("DELETE ", url, " ", body)
    return(fakeResponse(url, verb="DELETE", status_code=204))
}

fakeDownload <- function (url, destfile, ...) {
    file.copy(url, destfile)
    return(0)
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
