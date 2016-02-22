Sys.setlocale("LC_COLLATE", "C") ## What CRAN does
set.seed(999)
options(warn=1)

cacheOn()

source("mocks.R")

public <- function (...) with(globalenv(), ...)

public({
    source("mocks.R")
    cacheKeys <- function () ls(envir=httpcache:::cache)
})
