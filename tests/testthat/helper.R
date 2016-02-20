Sys.setlocale("LC_COLLATE", "C") ## What CRAN does

set.seed(999)

cacheOn()
# startLog("") ## prints to stdout
options(warn=1)

with_mock_HTTP <- function (expr) {
    with_mock(
        `httr::GET`=function (url, ...) list(response=nchar(url), status_code=200),
        `httr::PUT`=function (url, body=NULL, ...) message("PUT ", url, " ", body),
        `httr::PATCH`=function (url, body=NULL, ...) message("PATCH ", url, " ", body),
        `httr::POST`=function (url, body=NULL, ...) message("POST ", url, " ", body),
        `httr::DELETE`=function (url, ...) message("DELETE ", url,),
        eval.parent(expr)
    )
}

without_internet <- function (expr) {
    with_mock(
        `httr::GET`=function (url, ...) halt("GET ", url),
        `httr::PUT`=function (url, body, ...) halt("PUT ", url, " ", body),
        `httr::PATCH`=function (url, body, ...) halt("PATCH ", url, " ", body),
        `httr::POST`=function (url, body, ...) halt("POST ", url, " ", body),
        `httr::DELETE`=function (url, ...) halt("DELETE ", url),
        eval.parent(expr)
    )
}
